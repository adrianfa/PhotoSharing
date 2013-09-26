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

public class SearchAlbumServlet extends HttpServlet {
	

@Override
  protected void doPost(HttpServletRequest req, HttpServletResponse res) throws IOException {
    AppContext appContext = AppContext.getAppContext();
    DemoUser currentUser = appContext.getCurrentUser();
    String search_txt = req.getParameter(ServletUtils.REQUEST_PARAM_NAME_STREAM);
    
      res.sendRedirect(appContext.getPhotoServiceManager().getRedirectUrl1(
              req.getParameter(ServletUtils.REQUEST_PARAM_NAME_TARGET_URL), appContext.getCurrentUser().getUserId(), null, null, "searchstream", null,search_txt));
  }

}
