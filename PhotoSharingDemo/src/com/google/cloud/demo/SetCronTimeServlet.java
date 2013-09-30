package com.google.cloud.demo;

import java.io.IOException;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.appengine.api.datastore.EntityNotFoundException;

public class SetCronTimeServlet extends HttpServlet {


/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

@Override
  protected void doPost(HttpServletRequest req, HttpServletResponse res) throws IOException {
    AppContext appContext = AppContext.getAppContext();
    //String[] values = req.getParameterValues("course");
    String search_txt = req.getParameter("course");
    
	try {
	    if(search_txt == null)
				search_txt = appContext.getReportInterval();
		else 
				appContext.setReportInterval(search_txt);
	} catch (EntityNotFoundException e1) {
		// TODO Auto-generated catch block
		e1.printStackTrace();
	}
    res.sendRedirect(appContext.getPhotoServiceManager().getSearchUrl(
              req.getParameter(ServletUtils.REQUEST_PARAM_NAME_TARGET_URL),null, null, null, "trendingstream", null, search_txt));
  }

}

