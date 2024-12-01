//
//  PlaceService.swift
//  MyAccess
//
//  Created by Manisha Basnet on 11/30/24.
//

import FirebaseFirestore

class PlaceService {
    
    private let db = Firestore.firestore()
    
    /// Adds a new place to Firestore
    func addPlace(
      placeName: String,
      description: String,
      location: String,
      features: [String: [String]],
      images: [UIImage]? = nil,  // Array of images provided by user
      userID: String,
      completion: @escaping (Result<Void, Error>) -> Void
    ) {
      if let images = images, !images.isEmpty {
        ImageUploader.uploadMultipleImages(images: images) { uploadedImageURLs in
          // Update placeData with uploaded image URLs
          let placeData: [String: Any] = [
            "placeName": placeName,
            "description": description,
            "location": location,
            "features": features,
            "images": uploadedImageURLs,  // Use uploaded URLs here
            "likes": [],
            "dislikes": [],
            "comments": [:],
            "userID": userID,
            "dateCreated": Timestamp(date: Date())
          ]

            self.db.collection("places").addDocument(data: placeData) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    print("Success: Place added to Firestore.")
                    completion(.success(()))
                }
            }
        }
      } else {
        // No images to upload, proceed with regular place data addition
        let placeData: [String: Any] = [
          "placeName": placeName,
          "description": description,
          "location": location,
          "features": features,
          "images": [],  // Empty image array if no images uploaded
          "likes": [],
          "dislikes": [],
          "comments": [:],
          "userID": userID,
          "dateCreated": Timestamp(date: Date())
        ]

        // Add place data to Firestore
        db.collection("places").addDocument(data: placeData) { error in
          if let error = error {
            completion(.failure(error))
          } else {
            print("Success: Place added to Firestore.")
            completion(.success(()))
          }
        }
      }
    }
        
        //    /// Fetches a place from Firestore by ID
        //    /// - Parameter id: The Firestore document ID of the place
        //    /// - Parameter completion: Completion handler with fetched place or error
        //    func fetchPlace(by id: String, completion: @escaping (Result<Place, Error>) -> Void) {
        //        db.collection("places").document(id).getDocument { snapshot, error in
        //            if let error = error {
        //                completion(.failure(error)) // Return error if fetch fails
        //                return
        //            }
        //
        //            guard let snapshot = snapshot, snapshot.exists else {
        //                completion(.failure(NSError(domain: "PlaceService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Place not found."])))
        //                return
        //            }
        //
        //            do {
        //                // Decode the document data into a `Place` object
        //                let place = try snapshot.data(as: Place.self)
        //            } catch {
        //                completion(.failure(error)) // Handle decoding errors
        //            }
        //        }
        //    }
    }



