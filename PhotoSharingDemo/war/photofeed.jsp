<%@ page contentType="text/html;charset=UTF-8" language="java"
  isELIgnored="false"%>

<%@ page import="java.util.ArrayList"%>
<%@ page import="com.google.cloud.demo.*"%>
<%@ page import="com.google.cloud.demo.model.*"%>
<%@ page import="com.google.appengine.api.users.*"%>
<%@ page import="com.google.appengine.api.datastore.DatastoreNeedIndexException"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
  UserService userService = UserServiceFactory.getUserService();
  AppContext appContext = AppContext.getAppContext();
  ConfigManager configManager = appContext.getConfigManager();
  DemoUser currentUser = appContext.getCurrentUser();
  PhotoServiceManager serviceManager = appContext.getPhotoServiceManager();
  PhotoManager photoManager = appContext.getPhotoManager();
  CommentManager commentManager = appContext.getCommentManager();
  AlbumManager albumManager = appContext.getAlbumManager();
%>
<!DOCTYPE html>

<head>
<script type="text/javascript">
var tabLinks = new Array();
var contentDivs = new Array();

function init() {

    // Grab the tab links and content divs from the page
    var tabListItems = document.getElementById('tabs').childNodes;
    for ( var i = 0; i < tabListItems.length; i++ ) {
      if ( tabListItems[i].nodeName == "LI" ) {
        var tabLink = getFirstChildWithTagName( tabListItems[i], 'A' );
        var id = getHash( tabLink.getAttribute('href') );
        tabLinks[id] = tabLink;
        contentDivs[id] = document.getElementById( id );
      }
    }

    // Assign onclick events to the tab links, and
    // highlight the first tab
	
    for ( var id in tabLinks ) {
      tabLinks[id].onclick = showTab;
      tabLinks[id].onfocus = function() { this.blur() };
    }
    
    var tabId = window.location.href;
    var hashPos = tabId.lastIndexOf ( '#' );
	if (hashPos != -1) {
		tabId = getHash(tabId);
	}
	else {
		tabId = getUrlVars()["tabId"];
		if (!tabId || tabId.length === 0)
			tabId = "managestream";
	}
	
    for ( var id in tabLinks ) {
        if ( id == tabId ) tabLinks[id].className = 'selected';
    }

    // Hide all content divs except the first
     for ( var id in contentDivs ) {
      if ( id != tabId ) contentDivs[id].className = 'tabContent hide';
    }
  }

  function getUrlVars() {
    var vars = {};
    var parts = window.location.href.replace(/[?&]+([^=&]+)=([^&]*)/gi, function(m,key,value) {
        vars[key] = value;
    });
    return vars;
  }

  function pageShow() {
		//alert("We got a pageShow call!...");  
		var element = document.getElementById("imm");
		var color = element.style.visibility;
		if (color == "visible")
			element.style.visibility = "hidden";			
		else
			element.style.visibility = "visible";
  }
  
  function showTab() {
    var selectedId = getHash( this.getAttribute('href') );

    // Highlight the selected tab, and dim all others.
    // Also show the selected content div, and hide all others.
    for ( var id in contentDivs ) {
      if ( id == selectedId ) {
        tabLinks[id].className = 'selected';
        contentDivs[id].className = 'tabContent';
      } else {
        tabLinks[id].className = '';
        contentDivs[id].className = 'tabContent hide';
      }
    }
    
    var url1 = window.location.href;    
    var url2 = url1.split("#", 2);
    var url3 = url2[0].split("?", 2);
    var newUrl = url3[0].concat(this.getAttribute('href')); // + window.location.hash;
	window.location.replace(newUrl);
    // Stop the browser following the link
    return false;
  }

  function getFirstChildWithTagName( element, tagName ) {
    for ( var i = 0; i < element.childNodes.length; i++ ) {
      if ( element.childNodes[i].nodeName == tagName ) return element.childNodes[i];
    }
  }

  function getHash( url ) {
    var hashPos = url.lastIndexOf ( '#' );
    return url.substring( hashPos + 1 );
  }


function onFileSelected() {
  filename = document.getElementById("input-file").value;
  if (filename == null || filename == "") {
    document.getElementById("btn-post").setAttribute("class", "inactive btn");
    document.getElementById("btn-post").disabled = true;
  } else {
    document.getElementById("btn-post").setAttribute("class", "active btn");
    document.getElementById("btn-post").disabled = false;
  }
}

function togglePhotoPost(expanded) {
  onFileSelected();
  if (expanded) {
    document.getElementById("btn-choose-image").style.display="none";
    document.getElementById("upload-form").style.display="block";
  } else {
    document.getElementById("btn-choose-image").style.display="inline-block";
    document.getElementById("upload-form").style.display="none";
  }
}

function onCommentChanged(id) {
  comment = document.getElementById("comment-input-" + id).value;
  if (comment == null || comment.trim() == "") {
    document.getElementById("comment-submit-" + id).setAttribute("class", "inactive btn");
    document.getElementById("comment-submit-" + id).disabled = true;
  } else {
    document.getElementById("comment-submit-" + id).setAttribute("class", "active btn");
    document.getElementById("comment-submit-" + id).disabled = false;
  }
}

function toggleCommentPost(id, expanded) {
  onCommentChanged(id);
  if (expanded) {
    document.getElementById("comment-input-" + id).setAttribute("class", "post-comment expanded");
    document.getElementById("comment-submit-" + id).style.display="inline-block";
    document.getElementById("comment-cancel-" + id).style.display="inline-block";
  } else {
    document.getElementById("comment-input-" + id).value = ""
    document.getElementById("comment-input-" + id).setAttribute("class", "post-comment collapsed");
    document.getElementById("comment-submit-" + id).style.display="none";
    document.getElementById("comment-cancel-" + id).style.display="none";
  }
}
</script>

 <%-- MCM: this is a "huge" page divided into divs. 
    The server sends all the "pages" the client might want to look at as a single page 
    with several divs. The client runs an application that allows him to pick a view
    which will end up being a div he wants to look at from the whole page. 
    This enables the fast switch between choices. --%>

<title>Photofeed</title>
<link rel="stylesheet" type="text/css" href="photofeed.css" />
</head>

 <%-- ************************************************************* --%>
 <%-- MCM: All the tabs of the "views" the client might choose from --%>
 <%-- ************************************************************* --%>


<body onload="init()">
  <div class="wrap">

    <div class="header group">
      <h1>
        <img src="img/photofeed.png" alt="Photofeed" />
      </h1>
    </div>
      
	<ul class="header group" id="tabs">
     		<li><a href="#managestream">Manage</a></li>
     		<li><a href="#createstream">Create</a></li>
     		<li><a href="#viewstream">View</a></li>
     		<li><a href="#searchstream">Search</a></li>
     		<li><a href="#trendingstream">Trending</a></li>
     		<li><a href="#socialstream">Social</a></li>
	</ul>    
     <%-- ******************************************************************* --%>
     <%-- MCM here starts the div shown if the client chooses the MANAGE view --%>
     <%-- ******************************************************************* --%>
         
   
    <div class="glow"></div>
  	<div class="tabContent" id="managestream">
      <div class="manage-own">
        <form action="<%= configManager.getManageAlbumsUrl() %>"
              method="post">     
	        <p>MANAGE STREAMS</p>
	        <p>Streams I own:</p>
	        <table border="1">
			 <tr>
			 	<th>Name</th>
			 	<th>Last New Picture</th>
			 	<th>Number of Pictures</th>
			 	<th>Delete</th>
			 </tr>
			 <tr>
			 	<td>Adnan's World</td>
			 	<td>8/19/2013</td>
			 	<td>314</td>
				<td><input type="checkbox" name="delete-box" value="Erase"></td>
			 </tr>
		    <%
		      Iterable<Album> albumIter = albumManager.getOwnedAlbums(currentUser.getUserId());
		      ArrayList<Album> albums = new ArrayList<Album>();
		      try {
		        for (Album album : albumIter) {
		        	albums.add(album);
		        }
		      } catch (DatastoreNeedIndexException e) {
		        pageContext.forward(configManager.getErrorPageUrl(
		          ConfigManager.ERROR_CODE_DATASTORE_INDEX_NOT_READY));
		      }
		
		      for (Album album : albums) {
		    %>
				 <tr>
				 	<td><a href=<%= serviceManager.getRedirectUrl(null, currentUser.getUserId(), null, 
				 			album.getId().toString(), 
				 			 ServletUtils.REQUEST_PARAM_NAME_VIEW_STREAM, null) %>> <%= album.getTitle() %></a></td>
				 	<td><%= album.getSubscribers()%></td>
				 	<td><%= album.getTags()%></td>
					<td><input type="checkbox" name="delete-box" value=<%= album.getId().toString() %>></td>
				 </tr>
			 <%	} %>
			 </table> 
	        <input id="delete-streams" class="active btn" type="submit" value="Delete Checked">
 	    </form>      
      </div>
      <div class="manage-own">
        <form action="<%= configManager.getManageAlbumsUrl() %>"
              method="post">
                <p>Streams I subscribe to:</p>
                <table border="1">
                         <tr>
                                <th>Name</th>
                                <th>Last New Picture</th>
                                <th>Number of Pictures</th>
                                <th>Views</th>
                                <th>Unsubscribe</th>
                         </tr>
                         <tr>
                                <td>The grateful dead Berkely 1969</td>
                                <td>8/20/2013</td>
                                <td>314</td>
                                <td>10M</td>
                                <td><input type="checkbox" name="unsubscribe-box" value="Unsubscribe"></td>
                         </tr>
                         <tr>
                                <td>Van Hallen</td>
                                <td>7/4/2013</td>
                                <td>56</td>
                                <td>3141</td>
                                <td><input type="checkbox" name="unsubscribe-box" value="Unsubscribe"></td>
                         </tr>

                    <%
                      Iterable<Album> sub_albumsIter = albumManager.getOwnedAlbums(currentUser.getUserId());
                      ArrayList<Album> sub_albums = new ArrayList<Album>();
                      try {
                        for (Album sub_album : sub_albumsIter) {
                                sub_albums.add(sub_album);
                        }
                      } catch (DatastoreNeedIndexException e) {
                        pageContext.forward(configManager.getErrorPageUrl(
                          ConfigManager.ERROR_CODE_DATASTORE_INDEX_NOT_READY));
                      }

                      for (Album sub_album : sub_albums) {
                    %>
                                 <tr>
                                        <td><a href=<%= serviceManager.getRedirectUrl(null, currentUser.getUserId(), null,
                                                        sub_album.getId().toString(),
                                                         ServletUtils.REQUEST_PARAM_NAME_VIEW_STREAM, null) %>> <%= sub_album.getTitle() %></a></td>
                                        <td><%= sub_album.getSubscribers()%></td>
                                        <td><%= sub_album.getTags()%></td>
                                        <%-- MCM should replace the next line <td><%= Long.valueOf((Long)sub_album.getViews())%></td> --%>
                                        <td><%= sub_album.getTags()%></td>
                                        <td><input type="checkbox" name="unsubscribe-box" value=<%= sub_album.getId().toString() %>></td>
                                 </tr>
                         <%     } %>
                         </table>
                <input id="unsubscribe-streams" class="active btn" type="submit" value="Unsubscribe Checked">
            </form>     
      </div>



    </div>
    
     <%-- ******************************************************************* --%>
     <%-- MCM here starts the div shown if the client chooses the CREATE view --%>
     <%-- ******************************************************************* --%>


	<div class="tabContent" id="createstream">
      <div class="create">
        <p>CREATE STREAMS</p>
        <form action="<%= configManager.getCreateAlbumUrl() %>"
              method="post">     
	        <input id="stream-name" class="input text" name="stream" type="text" value="Stream name here...">
	        <p>Name your stream</p>
	        <textarea name="subscribers" placeholder="Add subscribers using comma as a separator..."></textarea>
	        <textarea name="message" placeholder="Optional message for invite..."></textarea>
	        <p>Add subscribers</p>
	        <input id="btn-post" class="active btn" type="submit" value="Create Stream">
		     <div class="tags">
		     	<textarea name="tags" placeholder="Add tags using comma as a separator..."></textarea>
		     	<p>Tag your stream</p>
		     	<input id="cover-url" class="input text" name="streamCoverUrl" type="text" value="URL here...">
		     	<p>URL to cover image</p>
		     	<p>(Can be empty)</p>        
		     </div>
	    </form>
     </div>
     </div>

     <%-- ******************************************************************* --%>
     <%-- MCM here starts the div shown if the client chooses the VIEW view --%>
     <%-- ******************************************************************* --%>

	<div class="tabContent" id="viewstream">
    
    <%-- MM: Here it prints the name and the owner of the album which we are showing --%>
    
	<%
	String streamId = request.getParameter(ServletUtils.REQUEST_PARAM_NAME_ALBUM_ID); 
	String which_photos = request.getParameter(ServletUtils.REQUEST_PARAM_NAME_PHOTO_LOC);
	int start_with_photo =1;
	if (which_photos != null) start_with_photo = Integer.valueOf(which_photos); 
	if(streamId != null && !streamId.isEmpty())
	{
		String streamUserId = request.getParameter(ServletUtils.REQUEST_PARAM_NAME_PHOTO_OWNER_ID);
	%>
		<div class="page-title">
		<%
		Album albm = albumManager.getAlbum(streamUserId, Long.parseLong(streamId));
		if (albm != null) {	
		%>
			<p>Stream Name: "<%= albm.getTitle()%>"
	  		for user: "<%= albm.getOwnerNickname() %>" </p>
		<%
		}
		%>
		</div>
		<%-- MM: we enable the user to pick up a picture to add to the stream --%>
		
    	<div id="upload-wrap">
      		<div id="upload">
        		<div class="account group">
          			<div id="account-thumb">
            			<img
              				src="<%= ServletUtils.getUserIconImageUrl(currentUser.getUserId()) %>"
              				alt="Unknown User Icon" />
       				</div>
          			<!-- /#account-thumb -->
          			<div id="account-name">
            			<h2><%= ServletUtils.getProtectedUserNickname(currentUser.getNickname()) %></h2>
            			<p><%= currentUser.getEmail() %>
             | 				<a href=<%= userService.createLogoutURL(configManager.getMainPageUrl())%>>Sign out</a>
            			</p>
          			</div>
          		<!-- /#account-name -->
        		</div>
        		<!-- /.account -->
        		<a id="btn-choose-image" class="active btn" onclick="togglePhotoPost(true)">Choose an image</a>
        		<div id="upload-form" style="display:none">
          			<form action="<%= serviceManager.getUploadUrl() + "?stream-id=" + streamId %>" method="post" 
            			enctype="multipart/form-data">
            			<input id="input-file" class="inactive file btn" type="file" name="photo"
              				onchange="onFileSelected()">
            			<textarea name="title" placeholder="Write a description"></textarea>
            			<input id="btn-post" class="active btn" type="submit" value="Post">
            			<a class="cancel" onclick="togglePhotoPost(false)">Cancel</a>
          			</form>
        		</div>
      		</div>
      		<!-- /#upload -->
    	</div>
    	<!-- /#upload-wrap -->

    <%-- MM: adds the new picture to the album  --%>
    	<!-- KK -->
    	<%
      	//Iterable<Photo> photoIter = photoManager.getActivePhotos();
      	Iterable<Photo> photoIter = photoManager.getSubsetOwnedAlbumPhotos(currentUser.getUserId(), streamId, 3, start_with_photo-1);
      	ArrayList<Photo> photos = new ArrayList<Photo>();
      	int count=0;
      	try {
      		
        	for (Photo photo : photoIter) {
          		{ 
          			photos.add(photo); 
          			count++; 
          			}
        	}
      	} catch (DatastoreNeedIndexException e) {
        	pageContext.forward(configManager.getErrorPageUrl(
          		ConfigManager.ERROR_CODE_DATASTORE_INDEX_NOT_READY));
      	}

      // goes over the pictures, one by one, to be shown to the public
      	count = 0;
      	for (Photo photo : photos) {
        	String firstClass = "";
        	String lastClass = "";
        	if (count == 0) {
          		firstClass = "first";
        	}
        	if (count == photos.size() - 1) {
          		lastClass = "last";
        	}
    	%>
    		<div class="feed <%= firstClass %> <%= lastClass %>"  onclick="pageShow()">
      			<div class="post group">
        			<div class="image-wrap">
          				<img class="photo-image"
            				src="<%= serviceManager.getImageDownloadUrl(photo)%>"
            				alt="Photo Image" />
        			</div>
        			<div class="owner group">
          			<!-- MM: took out here code for cats images -->
          				<div class="desc">
           				<h3>
            					<%= ServletUtils.getProtectedUserNickname(photo.getOwnerNickname()) %></h3>          
            				<p class="timestamp"><%= ServletUtils.formatTimestamp(photo.getUploadTime()) %></p>
            				<p>
            				<p><c:out value="<%= photo.getTitle() %>" escapeXml="true"/>
           					<img class="check" src="img/check.png" id="imm" />         				
          			</div>
       				<!-- /.desc -->
        		</div>
        		<!-- /.usr -->
      		</div>
      		<!-- /.post -->
      
      		<%
        	Iterable<Comment> comments = commentManager.getComments(photo);
        	for (Comment comment : comments) {
        	}
      		%>
      		<!-- MM: took out here code for last comment -->   
    	</div>
    	<!-- /.feed -->
   	<%
        	count++;
      	}
    %>
      	<%-- MM:the More pictures button after the 3 shown pictures --%>
        <div class="next-3-pict">
        	<form action="<%= serviceManager.getRedirectUrl(null, currentUser.getUserId(), null, 
		 			                                       albm.getId().toString(), 
		 			                                       ServletUtils.REQUEST_PARAM_NAME_VIEW_STREAM, String.valueOf(start_with_photo+3))
		 			 %>"
                 method="post">    
                   <input id="btn-post" class="active btn" type="submit" value="More pictures">
            </form>
        </div>

      <%-- MM: the box to ADD AN IMAGE --%> 
        <div class="box">
          <div class="image-wrap">
          <form action="<%= configManager.getCreateAlbumUrl() %>"
                 method="post">    
               <input id="file_to_load" class="input text" name="stream" type="text" value="File name">
               <input id="comments" class="input text" name="stream" type="text" value="Comments...">
                   <input id="btn-post" class="active btn" type="submit" value="Upload file">
                   <strong> "Add an Image" </strong>
              </form>
              </div>
        </div>

      <%-- MM: the subscribe button --%> 
          <div class="create">
          <form action="<%= configManager.getCreateAlbumUrl() %>"
                 method="post">    
                   <input id="btn-post" class="active btn" type="submit" value="Subscribe">
              </form>

        </div> 

   <%
	}
	else {
    	albumIter = albumManager.getActiveAlbums();
      	albums = new ArrayList<Album>();
      	try {
        	for (Album album : albumIter) {
	        	albums.add(album);
	        }
      	} catch (DatastoreNeedIndexException e) {
	        pageContext.forward(configManager.getErrorPageUrl(
	          ConfigManager.ERROR_CODE_DATASTORE_INDEX_NOT_READY));
      	}

      	int count = 0;
      	for (Album album : albums) {
	    	  
	%>
     		<div class="feed">
	      		<div class="post group">
		        	<div class="image-wrap">
		        		<a href="<%= serviceManager.getRedirectUrl(null, currentUser.getUserId(), null, 
				 				album.getId().toString(), 
				 			 	ServletUtils.REQUEST_PARAM_NAME_VIEW_STREAM, null) %>"> 
		          		<img class="photo-image"
		            		src="<%= ServletUtils.getUserIconImageUrl(album.getOwnerId())%>"
			 			 	alt="Photo Image" /></a>
	        		</div>
		        	<div class="owner group">
		          		<div class="desc">
		            		<h3><%= ServletUtils.getProtectedUserNickname(album.getOwnerNickname()) %></h3>	            
		            		<p class="timestamp"><%= ServletUtils.formatTimestamp(album.getUploadTime()) %></p>
		            		<p>
		            		<p><c:out value="<%= album.getTitle() %>" escapeXml="true"/>
		          		</div>
		          		<!-- /.desc -->
        			</div>
		        	<!-- /.usr -->
	      		</div>
	      		<!-- /.post -->
		      
     <%
	        	//Iterable<Comment> comments = commentManager.getComments(photo);
	        	//for (Comment comment : comments) {}
     %>
   			</div>
    		<!-- /.feed -->
	<%	
			count++;
      	}
	}
    %>
 	</div>
	<!-- /.view -->  


     <%-- ******************************************************************* --%>
     <%-- MCM here starts the div shown if the client chooses the SEARCH view --%>
     <%-- ******************************************************************* --%>

    <div class="tabContent" id="searchstream">
    <%--MM: should ask for what to search and allow the push of the "Search" button --%>
      <div class="create">
        <p>SEARCH STREAMS</p>
          <form action="<%= configManager.getCreateAlbumUrl() %>"
             method="post">
               <input id="search-name" class="input text" name="stream" type="text" value="search name here...">
               <input id="btn-post" class="active btn" type="submit" value="Search">
          </form>
     </div>
    <%-- MM: should appear as a result of the above search up to 5 streams --%>
    <div>

  </div>
  </div>

     <%-- ******************************************************************* --%>
     <%-- MCM here starts the div shown if the client chooses the TRENDING view --%>
     <%-- ******************************************************************* --%>


 	<div class="tabContent" id="trendingstream">
      <div class="create">
        <p>TOP 3 TRENDING STREAMS</p>
      </div>
    </div>

     <%-- ******************************************************************* --%>
     <%-- MCM here starts the div shown if the client chooses the SOCIAL view --%>
     <%-- ******************************************************************* --%>

    
 	<div class="tabContent" id="socialstream">
      <div class="create">
        <p>SOCIAL STREAMS</p>
      </div>
    </div>
    
  
  </div>
  <!-- /.wrap -->
</body>
</html>
