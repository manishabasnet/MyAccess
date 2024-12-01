//
//  PlaceModel.swift
//  MyAccess
//
//  Created by Manisha Basnet on 11/30/24.
//

import Foundation
import FirebaseFirestore

struct Place: Codable, Identifiable {
    @DocumentID var id: String? // Firestore document ID, used as the unique buildingID
    var buildingID: String {
        id ?? "" // Use the Firestore document ID as the buildingID
    }
    let placeName: String
    let address: String
    let description: String
    var likes: [String]
    var dislikes: [String]
    var images: [String]
    var comments: [String: String] // userID: comment
    var features: [String: String] // feature: description
    let userID: String // User who added the place
    let dateAdded: Date // Timestamp for when the place was added

    // Initializer for new place creation
    init(placeName: String, address: String, description: String, userID: String) {
        self.placeName = placeName
        self.address = address
        self.description = description
        self.likes = []
        self.dislikes = []
        self.images = []
        self.comments = [:]
        self.features = [:]
        self.userID = userID
        self.dateAdded = Date() // Automatically set to the current date and time
    }

    // Optional initializer for decoding from Firestore
    init(id: String? = nil, placeName: String, address: String, description: String, likes: [String], dislikes: [String], images: [String], comments: [String: String], features: [String: String], userID: String, dateAdded: Date) {
        self.id = id
        self.placeName = placeName
        self.address = address
        self.description = description
        self.likes = likes
        self.dislikes = dislikes
        self.images = images
        self.comments = comments
        self.features = features
        self.userID = userID
        self.dateAdded = dateAdded
    }
}

// Extension to help with Firestore operations
extension Place {
    // Convert place to dictionary for Firestore
    var dictionary: [String: Any] {
        return [
            "placeName": placeName,
            "address": address,
            "description": description,
            "likes": likes,
            "dislikes": dislikes,
            "images": images,
            "comments": comments,
            "features": features,
            "userID": userID,
            "dateAdded": dateAdded
        ]
    }
}
