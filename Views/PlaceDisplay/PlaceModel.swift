import Foundation
import FirebaseFirestore

struct Place: Codable, Identifiable {
    @DocumentID var id: String?
    var placeName: String
    var description: String
    var location: String
    var city: String
    var features: [String: [String]] // Dictionary of userID to array of features
    var images: [String]
    var likes: [String] // Array of user IDs who liked the place
    var dislikes: [String] // Array of user IDs who disliked the place
    var comments: [String: [String]] // Dictionary of userID to array of comments
    var userID: String
    
    @ServerTimestamp var dateAdded: Timestamp?

    // Custom coding keys to handle potential naming differences
    enum CodingKeys: String, CodingKey {
        case id
        case placeName
        case description
        case location
        case city
        case features
        case images
        case likes
        case dislikes
        case comments
        case userID
        case dateAdded
    }

    // Initializer with fallback values
    init(
        id: String? = nil,
        placeName: String,
        description: String,
        location: String,
        city: String,
        features: [String: [String]] = [:],
        images: [String] = [],
        likes: [String] = [],
        dislikes: [String] = [],
        comments: [String: [String]] = [:],
        userID: String,
        dateAdded: Timestamp? = nil
    ) {
        self.id = id
        self.placeName = placeName
        self.description = description
        self.location = location
        self.city = city
        self.features = features
        self.images = images
        self.likes = likes
        self.dislikes = dislikes
        self.comments = comments
        self.userID = userID
        self.dateAdded = dateAdded
    }

    // Custom init for manual initialization
    init(from data: [String: Any]) throws {
        self.id = data["id"] as? String
        
        guard let placeName = data["placeName"] as? String,
              let description = data["description"] as? String,
              let location = data["location"] as? String,
              let city = data["city"] as? String,
              let userID = data["userID"] as? String else {
            throw NSError(domain: "PlaceInitError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Missing required fields"])
        }
        
        self.placeName = placeName
        self.description = description
        self.location = location
        self.city = city
        self.userID = userID
        
        self.features = data["features"] as? [String: [String]] ?? [:]
        self.images = data["images"] as? [String] ?? []
        self.likes = data["likes"] as? [String] ?? []
        self.dislikes = data["dislikes"] as? [String] ?? []
        self.comments = data["comments"] as? [String: [String]] ?? [:]
        
        // Handle dateAdded
        self.dateAdded = data["dateAdded"] as? Timestamp ?? data["dateCreated"] as? Timestamp
    }
}
