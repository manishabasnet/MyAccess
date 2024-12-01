//
//  UserService.swift
//  MyAccess
//
//  Created by Manisha Basnet on 11/27/24.
//
import Foundation
import FirebaseFirestore
import FirebaseAuth

class UserService {
    private let db = Firestore.firestore()
    
    // Create a new user in Firestore
    func createUser(userId: String, email: String, name: String, profileImageURL: String? = nil, completion: @escaping (Result<Void, Error>) -> Void) {
        // Set default image URL if none is provided
        let defaultImageURL = "https://firebasestorage.googleapis.com/v0/b/myaccessfinal.firebasestorage.app/o/profile_images%2Fdefault_user_image.png?alt=media&token=b0a22669-56e4-4b8a-a6f3-f76f33e31fbd"
        let imageURL = profileImageURL ?? defaultImageURL
        
        // User data with the resolved image URL
        let userData: [String: Any] = [
            "userId": userId,
            "email": email,
            "name": name,
            "dateJoined": Timestamp(date: Date()),
            "profileImageURL": imageURL // Always set a value for profileImageURL
        ]
        
        // Save user data to Firestore
        db.collection("users").document(userId).setData(userData) { error in
            if let error = error {
                print("Error: Failed to save user to Firestore - \(error.localizedDescription)")
                completion(.failure(error))
            } else {
                print("Success: User saved to Firestore with profileImageURL.")
                completion(.success(()))
            }
        }
    }
    
    // Fetch user by ID
    func fetchUser(userId: String, completion: @escaping (Result<User, Error>) -> Void) {
        db.collection("users").document(userId).getDocument { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let snapshot = snapshot, snapshot.exists,
                  let user = try? snapshot.data(as: User.self) else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not found"])))
                return
            }
            
            completion(.success(user))
        }
    }
    
    // Update user contribution
    func addContribution(userId: String, contributionId: String, points: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        let userRef = db.collection("users").document(userId)
        
        userRef.updateData([
            "contributions": FieldValue.arrayUnion([contributionId]),
            "totalContributionPoints": FieldValue.increment(Int64(points))
        ]) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    // Add liked post
    func addLikedPost(userId: String, postId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let userRef = db.collection("users").document(userId)
        
        userRef.updateData([
            "likedPosts": FieldValue.arrayUnion([postId])
        ]) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
}
