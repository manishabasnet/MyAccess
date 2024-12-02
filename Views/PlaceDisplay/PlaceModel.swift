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
    var dateAdded: Date // Timestamp for when the place was added

    init(from data: [String: Any]) throws {
        print("Attempting to initialize Place with data: \(data)")

        // Handle placeName
        guard let placeName = data["placeName"] as? String else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Missing or invalid placeName"])
        }
        self.placeName = placeName

        // Handle description
        guard let description = data["description"] as? String else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Missing or invalid description"])
        }
        self.description = description

        // Handle location
        guard let location = data["location"] as? String else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Missing or invalid location"])
        }
        self.location = location

        // Handle city
        guard let city = data["city"] as? String else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Missing or invalid city"])
        }
        self.city = city

        // Handle userID
        guard let userID = data["userID"] as? String else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Missing or invalid userID"])
        }
        self.userID = userID

        // Handle features (with fallback to empty dictionary)
        self.features = data["features"] as? [String: [String]] ?? [:]

        // Handle images (with fallback to empty array)
        self.images = data["images"] as? [String] ?? []

        // Handle likes (with fallback to empty array)
        self.likes = data["likes"] as? [String] ?? []

        // Handle dislikes (with fallback to empty array)
        self.dislikes = data["dislikes"] as? [String] ?? []

        // Handle comments (with fallback to empty dictionary)
        self.comments = data["comments"] as? [String: [String]] ?? [:]

        // Handle dateAdded
        guard let dateAddedTimestamp = data["dateCreated"] as? Timestamp ?? data["dateAdded"] as? Timestamp else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Missing or invalid dateAdded"])
        }
        self.dateAdded = dateAddedTimestamp.dateValue()

        print("Place initialized successfully with data: \(self)")
    }
}
