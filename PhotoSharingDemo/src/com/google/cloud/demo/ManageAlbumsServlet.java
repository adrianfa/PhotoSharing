package com.google.cloud.demo;

import java.io.IOException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.appengine.api.datastore.DatastoreNeedIndexException;
import com.google.cloud.demo.model.Album;
import com.google.cloud.demo.model.AlbumManager;
import com.google.cloud.demo.model.DemoUser;

public class ManageAlbumsServlet extends HttpServlet {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	@Override
	  protected void doPost(HttpServletRequest req, HttpServletResponse res) throws IOException {
	    AppContext appContext = AppContext.getAppContext();
	    DemoUser currentUser = appContext.getCurrentUser();
	    String[] values = req.getParameterValues(ServletUtils.REQUEST_PARAM_NAME_CHECKBOX_GROUP);

 	    boolean succeeded = false;
	    StringBuilder builder = new StringBuilder();
	    if (currentUser != null) {
	          AlbumManager albumManager = appContext.getAlbumManager();
		      Iterable<Album> albumIter = albumManager.getOwnedAlbums(currentUser.getUserId());
		      try {
		        for (Album album : albumIter) {
		            for(int i=0; i<values.length; i++) {
		            	String val = values[i];
		            	String albumId = album.getId().toString();
		                if(val.equals(albumId))
		                	albumManager.deactiveAlbum(currentUser.getUserId(), album.getId());
		            }
		        }
		      } catch (DatastoreNeedIndexException e) {
		    	  builder.append(ConfigManager.ERROR_CODE_DATASTORE_INDEX_NOT_READY);
		      }

	          
	          succeeded = true;
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
