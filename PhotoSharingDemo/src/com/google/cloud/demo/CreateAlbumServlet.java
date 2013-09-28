package com.google.cloud.demo;

import java.io.IOException;
import java.util.Properties;
import java.util.logging.Logger;

import javax.mail.Message;
import javax.mail.MessagingException;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.AddressException;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;


import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.cloud.demo.model.Album;
import com.google.cloud.demo.model.AlbumManager;
import com.google.cloud.demo.model.DemoUser;



public class CreateAlbumServlet extends HttpServlet {
	
 /**
	 * 
	 */
	private static final Logger logger =
		      Logger.getLogger(PhotoServiceManager.class.getCanonicalName());
	
	private static final long serialVersionUID = 518284167764359702L;

@Override
  protected void doPost(HttpServletRequest req, HttpServletResponse res) throws IOException {
    AppContext appContext = AppContext.getAppContext();
    DemoUser currentUser = appContext.getCurrentUser();
    String content = req.getParameter(ServletUtils.REQUEST_PARAM_NAME_STREAM);
    String subscribers = req.getParameter(ServletUtils.REQUEST_PARAM_NAME_SUBSCRIBERS);
    String tags = req.getParameter(ServletUtils.REQUEST_PARAM_NAME_TAGS);
    //String coverImageUrl = req.getParameter(ServletUtils.REQUEST_PARAM_NAME_COVER_IMAGE_URL);
    boolean succeeded = false;
    StringBuilder builder = new StringBuilder();
    if (currentUser != null && content != null) {
      content = content.trim();
      if (!content.isEmpty()) {
          AlbumManager albumManager = appContext.getAlbumManager();
          Album album = albumManager.newAlbum(currentUser.getUserId());
          album.setTitle(content);
          album.setOwnerNickname(ServletUtils.getProtectedUserNickname(currentUser.getNickname()));         
          album.setTags(tags);
          long views = 1;
          album.setViews(views);          
          album.setUploadTime(System.currentTimeMillis());
        
          albumManager.upsertEntity(album);
          succeeded = true;
          
          // MM : Sends email to subscribers to invite them
          album.setSubscribers(subscribers);
  		
          Properties props = new Properties();
          Session session = Session.getDefaultInstance(props, null);

          String msgBody = (album.getOwnerNickname()).concat(" invites you to see a new stream in connexus: ").concat(album.getTitle());

          try {
              Message msg = new MimeMessage(session);
              msg.setFrom(new InternetAddress(currentUser.getEmail(),"Connexus"));
              msg.addRecipient(Message.RecipientType.TO,
                               new InternetAddress(album.getSubscribers(),"Mr. User"));
              msg.setSubject("Connexus invitation");
              msg.setText(msgBody);
              Transport.send(msg);
              logger.info(currentUser.getEmail() + " MCM sent email to " + album.getSubscribers());
          } catch (AddressException e) {
              // ...
          } catch (MessagingException e) {
              // ...
          }
           // MM: finished sending email

      } else {
        builder.append("Comment could not be empty");
      }
    } else {;
      builder.append("Bad parameters");
    }
    if (succeeded) {
      res.sendRedirect(appContext.getPhotoServiceManager().getRedirectUrl(
              req.getParameter(ServletUtils.REQUEST_PARAM_NAME_TARGET_URL), appContext.getCurrentUser().getUserId(), null, null, "managestream", null));
    } else {
      res.sendError(400, builder.toString());
    }
  }

}
