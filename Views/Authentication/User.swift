import Foundation
import FirebaseFirestore

struct User: Codable, Identifiable {
    @DocumentID var id: String?
    let userId: String
    let email: String
    let name: String
    let dateJoined: Date
    var totalContributionPoints: Int
    var contributions: [String]
    var likedPosts: [String]

    // Initializer for new user registration
    init(userId: String, email: String, name: String) {
        self.userId = userId
        self.email = email
        self.name = name
        self.dateJoined = Date() // Automatically set to current date and time
        self.totalContributionPoints = 0
        self.contributions = []
        self.likedPosts = []
    }

    // Optional initializer for decoding from Firestore
    init(id: String? = nil, userId: String, email: String, name: String, dateJoined: Date, totalContributionPoints: Int, contributions: [String], likedPosts: [String]) {
        self.id = id
        self.userId = userId
        self.email = email
        self.name = name
        self.dateJoined = dateJoined
        self.totalContributionPoints = totalContributionPoints
        self.contributions = contributions
        self.likedPosts = likedPosts
    }
}

// Extension to help with Firestore operations
extension User {
    // Convert user to dictionary for Firestore
    var dictionary: [String: Any] {
        return [
            "userId": userId,
            "email": email,
            "name": name,
            "dateJoined": dateJoined,
            "totalContributionPoints": totalContributionPoints,
            "contributions": contributions,
            "likedPosts": likedPosts
        ]
    }
}
