/*
 * Copyright (c) 2012 Google Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License. You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software distributed under the License
 * is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express
 * or implied. See the License for the specific language governing permissions and limitations under
 * the License.
 */
package com.google.cloud.demo.model;

/**
 * The photo entity manager interface.
 *
 * @author Michael Tang (ntang@google.com)
 */
public interface PhotoManager extends DemoEntityManager<Photo> {
  /**
   * Lookups a specific photo.
   *
   * @param userId the owner's user id.
   * @param id the photo id.
   *
   * @return the photo entity; return null if photo is not found.
   */
  Photo getPhoto(String userId, long id);

  /**
   * Queries an {@code Iterable} collection of photos owned by the user.
   *
   * @param userId the user id.
   * @return an {@code Iterable} collection of photos.
   */
  Iterable<Photo> getOwnedPhotos(String userId);

  /**
   * Queries an {@code Iterable} collection of photos owned by the user.
   *
   * @param userId the user id.
   * @return an {@code Iterable} collection of photos.
   */
  Iterable<Photo> getOwnedAlbumPhotos(String userId, String albumId);

  /**
   * Queries all photos shared to a user with specific user id. The result set
   * does not include photos owned by the user.
   *
   * @param userId the user id.
   *
   * @return an {@code Iterable} collection of photos shared to the user.
   */
  Iterable<Photo> getSubsetOwnedAlbumPhotos(String userId, String albumId, int how_many,int offset);
  /**
   * Queries all photos shared to a user with specific user id. The result set
   * does not include photos owned by the user.
   *
   * @param userId the user id.
   *
   * @oaram how_many is the number of photos to be returned
   * 
   * @param offset starting with which position in the list to allow next chunk of photos
   * 
   * @return an {@code Iterable} collection of photos shared to the user.
   */
	  
  Iterable<Photo> getSharedPhotos(String userId);

  /**
   * Gets all deactived photos.
   *
   * @return an {@code Iterable} collection of deactived photos.
   */
  Iterable<Photo> getDeactivedPhotos();

  /**
   * Gets all active photos.
   *
   * @return an {@code Iterable} collection of active photos.
   */
  Iterable<Photo> getActivePhotos();

  /**
   * Creates a new photo object based on user id. The object is not yet
   * serialized to datastore yet.
   *
   * @param userId the user id.
   *
   * @return a photo object.
   */
  Photo newPhoto(String userId);

  /**
   * Marks a photo inactive so that the photo is ready for delete.
   *
   * @return the deactived photo object; null if operation failed.
   */
  Photo deactivePhoto(String userId, long id);

  /**
   * Marks a photo inactive so that the photo is ready for delete.
   *
   * @return the deactived photo object; null if operation failed.
   */
  Photo toggleCoverPhoto(String userId, long id);

/**
 * Marks a album photos inactive so that the photo is ready for delete.
 *
 * @return the deactived photo object; null if operation failed.
 */
void deactivateAlbumPhotos(String userId, long id);

/**
 * provides the number of photos in an album
 * 
 * @param userId
 * @param albumId
 * @return String containing the number of photos in the album
 */

String getAlbumSize(String userId, String albumId);

/** provides the timestamp of the photo added last
 * 
 * @param serId
 * @param albumId
 * @return the string with when was the last photo added
 */
 
long getNewestPhotoTimestamp(String userId, String albumId);

}
