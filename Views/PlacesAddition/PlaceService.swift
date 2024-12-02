//
//  PlaceService.swift
//  MyAccess
//
//  Created by Manisha Basnet on 11/30/24.
//

import FirebaseFirestore
import FirebaseAuth

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
      city: String,
      completion: @escaping (Result<Void, Error>) -> Void
    ) {
      if let images = images, !images.isEmpty {
        ImageUploader.uploadMultipleImages(images: images) { uploadedImageURLs in
          // Update placeData with uploaded image URLs
          let placeData: [String: Any] = [
            "placeName": placeName,
            "description": description,
            "location": location,
            "city": city,
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
          "city": city,
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
        
    func fetch_place(placeID: String, completion: @escaping (Result<Place, Error>) -> Void) {
        let db = Firestore.firestore()
        let placeRef = db.collection("places").document(placeID)

        placeRef.getDocument { (document, error) in
            if let error = error {
                completion(.failure(error))
            } else if let document = document, document.exists,
                      let data = document.data() {
                // Log the data before initializing
                print("Fetched Place Data: \(data)")

                do {
                    var place = try Place(from: data)
                    place.id = document.documentID // Set the document ID
                    print("Successfully initialized Place: \(place)")  // Log after successful initialization
                    completion(.success(place))
                } catch {
                    print("Error initializing Place: \(error.localizedDescription)")  // Detailed error logging
                    completion(.failure(error))
                }
            } else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Document not found"])))
            }
        }
    }


    
    func fetchPlaces(completion: @escaping (Result<[Place], Error>) -> Void) {
            db.collection("places")
                .getDocuments { (snapshot, error) in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        var places: [Place] = []
                        for document in snapshot?.documents ?? [] {
                            do {
                                let place = try document.data(as: Place.self)
                                places.append(place)
                            } catch {
                                print("Error decoding place: \(error)")
                            }
                        }
                        completion(.success(places))
                    }
                }
        }
    
    // Add comment to a place
    func addComment(to place: Place, comment: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            completion(.failure(NSError(domain: "NoUserLoggedIn", code: -1, userInfo: [NSLocalizedDescriptionKey: "User must be logged in."])))
            return
        }

        guard let placeID = place.id else {
            completion(.failure(NSError(domain: "MissingPlaceID", code: -1, userInfo: [NSLocalizedDescriptionKey: "Place ID is missing."])))
            return
        }

        let userID = currentUser.uid
        let placeRef = Firestore.firestore().collection("places").document(placeID)

        // Copy current comments
        var updatedComments = place.comments
        if updatedComments[userID] == nil {
            updatedComments[userID] = [] // Initialize the array if not already present
        }
        updatedComments[userID]?.append(comment) // Add the new comment

        // Update the Firestore document with the new comments data
        placeRef.updateData([
            "comments": updatedComments
        ]) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

    
    // Add a new feature to a place
    func addFeature(to place: Place, feature: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            completion(.failure(NSError(domain: "NoUserLoggedIn", code: -1, userInfo: [NSLocalizedDescriptionKey: "User must be logged in."])))
            return
        }
        
        guard let placeID = place.id else {
            completion(.failure(NSError(domain: "MissingPlaceID", code: -1, userInfo: [NSLocalizedDescriptionKey: "Place ID is missing."])))
            return
        }
        
        let userID = currentUser.uid
        let placeRef = Firestore.firestore().collection("places").document(placeID)

        // Copy current features
        var updatedFeatures = place.features
        if updatedFeatures[userID] == nil {
            updatedFeatures[userID] = [] // Initialize the array if not already present
        }
        updatedFeatures[userID]?.append(feature) // Add the new feature

        // Update the Firestore document with the new features data
        placeRef.updateData([
            "features": updatedFeatures
        ]) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

    
    // Add like or dislike to a place
    func addLikeDislike(to place: Place, type: LikeDislikeType, completion: @escaping (Result<Void, Error>) -> Void) {
        let db = Firestore.firestore()
        guard let currentUser = Auth.auth().currentUser else {
            completion(.failure(NSError(domain: "NoUserLoggedIn", code: -1, userInfo: [NSLocalizedDescriptionKey: "User must be logged in."])))
            return
        }
        let userID = currentUser.uid
        
        // Reference to the specific place document
        guard let placeID = place.id else {
            completion(.failure(NSError(domain: "Place ID is missing", code: -1, userInfo: nil)))
            return
        }
        
        let placeRef = db.collection("places").document(placeID)
        
        placeRef.getDocument { document, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let document = document, document.exists else {
                completion(.failure(NSError(domain: "Place not found", code: -1, userInfo: nil)))
                return
            }
            
            var likes = place.likes
            var dislikes = place.dislikes
            
            // Remove the user from both likes and dislikes before adding a new one
            if likes.contains(userID) {
                likes.removeAll { $0 == userID }
            }
            
            if dislikes.contains(userID) {
                dislikes.removeAll { $0 == userID }
            }
            
            // Add the user to the appropriate list (like or dislike)
            if type == .like {
                likes.append(userID)
            } else if type == .dislike {
                dislikes.append(userID)
            }
            
            // Update the Firestore document with the new likes and dislikes data
            placeRef.updateData(["likes": likes, "dislikes": dislikes]) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        }
    }

    // Enum for Like/Dislike type
    enum LikeDislikeType {
        case like
        case dislike
    }



    }




