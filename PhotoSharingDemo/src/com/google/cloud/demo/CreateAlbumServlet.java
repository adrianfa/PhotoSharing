package com.google.cloud.demo;

import java.io.IOException;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.cloud.demo.model.Album;
import com.google.cloud.demo.model.AlbumManager;
import com.google.cloud.demo.model.Comment;
import com.google.cloud.demo.model.CommentManager;
import com.google.cloud.demo.model.DemoUser;
import com.google.cloud.demo.model.Photo;
import com.google.cloud.demo.model.PhotoManager;

public class CreateAlbumServlet extends HttpServlet {
	
 /**
	 * 
	 */
	private static final long serialVersionUID = 518284167764359702L;

@Override
  protected void doPost(HttpServletRequest req, HttpServletResponse res) throws IOException {
    AppContext appContext = AppContext.getAppContext();
    DemoUser currentUser = appContext.getCurrentUser();
    String content = req.getParameter(ServletUtils.REQUEST_PARAM_NAME_STREAM);
    String subscribers = req.getParameter(ServletUtils.REQUEST_PARAM_NAME_SUBSCRIBERS);
    String tags = req.getParameter(ServletUtils.REQUEST_PARAM_NAME_TAGS);
    String coverImageUrl = req.getParameter(ServletUtils.REQUEST_PARAM_NAME_COVER_IMAGE_URL);
    boolean succeeded = false;
    StringBuilder builder = new StringBuilder();
    if (currentUser != null && content != null) {
      content = content.trim();
      if (!content.isEmpty()) {
          AlbumManager albumManager = appContext.getAlbumManager();
          Album album = albumManager.newAlbum(currentUser.getUserId());
          album.setTitle(content);
          album.setOwnerNickname(ServletUtils.getProtectedUserNickname(currentUser.getNickname()));
          album.setSubscribers(subscribers);
          album.setTags(tags);
          album.setViews((long)1);          
          album.setUploadTime(System.currentTimeMillis());
        
          albumManager.upsertEntity(album);
          succeeded = true;
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
