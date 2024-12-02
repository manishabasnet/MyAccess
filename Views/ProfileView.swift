//
//  ProfileView.swift
//  SwiftfulThinking
//
//  Created by Manisha Basnet on 10/6/24.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

class ProfileViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var dateJoined: String = ""
    @Published var contributions: [String] = []
    @Published var contributionPoints: Int = 0
    @Published var profileImageURL: String? = nil  // Use URL for images
    @Published var isLoading: Bool = true
    
    private let defaultImageURL = "https://firebasestorage.googleapis.com/v0/b/myaccessfinal.firebasestorage.app/o/profile_images%2Fdefault_user_image.png?alt=media&token=b0a22669-56e4-4b8a-a6f3-f76f33e31fbd"

    
    private let db = Firestore.firestore()
    
    func fetchUserProfile() {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("No current user is logged in.")
            self.isLoading = false
            return
        }
        
        db.collection("users").document(userID).getDocument { document, error in
            if let error = error {
                print("Error fetching user profile: \(error)")
                self.isLoading = false
                return
            }
            
            guard let data = document?.data() else {
                print("No data found for user ID: \(userID)")
                self.isLoading = false
                return
            }
            
            print("Fetched Data: \(data)")

            DispatchQueue.main.async {
                self.name = data["name"] as? String ?? "Unknown"
                
                // Convert Firebase Timestamp to String
                if let timestamp = data["dateJoined"] as? Timestamp {
                    let date = timestamp.dateValue()
                    let formatter = DateFormatter()
                    formatter.dateStyle = .medium
                    self.dateJoined = formatter.string(from: date)
                } else {
                    self.dateJoined = "N/A"
                }
                
                self.contributions = data["contributions"] as? [String] ?? []
                self.contributionPoints = self.contributions.count
                self.profileImageURL = data["profileImageURL"] as? String ?? self.defaultImageURL
                self.isLoading = false
            }
        }
    }
}

struct ProfileView: View {
    
    let name: String
    let dateJoined: String
    let contributionPoints: Int
    let contributions: [String]
    let profileImageURL: String
    
    var body: some View {
        GeometryReader {
            geometry in
                    VStack{
                        AsyncImage(url: URL(string: profileImageURL)) { phase in
                                           switch phase {
                                           case .empty:
                                               // Show a placeholder while loading
                                               ProgressView()
                                                   .frame(width: geometry.size.height * 0.3, height: geometry.size.height * 0.3)
                                                   .background(Color.gray.opacity(0.3))
                                                   .cornerRadius(geometry.size.height * 0.15)
                                           case .success(let image):
                                               // Successfully loaded image
                                               image
                                                   .resizable()
                                                   .scaledToFit()
                                                   .frame(width: geometry.size.height * 0.3, height: geometry.size.height * 0.3)
                                                   .cornerRadius(geometry.size.height * 0.15)
                                           case .failure:
                                               // Fallback to a local default image if loading fails
                                               Image("default_user_image")
                                                   .resizable()
                                                   .scaledToFit()
                                                   .frame(width: geometry.size.height * 0.3, height: geometry.size.height * 0.3)
                                                   .cornerRadius(geometry.size.height * 0.15)
                                           @unknown default:
                                               Image("default_user_image")
                                                   .resizable()
                                                   .scaledToFit()
                                                   .frame(width: geometry.size.height * 0.3, height: geometry.size.height * 0.3)
                                                   .cornerRadius(geometry.size.height * 0.15)
                                           }
                                       }
                                       .padding(.top, geometry.size.height * 0.03)
                        VStack{
                            Text(name)
                                .font(.title)
                                .fontWeight(.bold)
                            Text("Joined on \(dateJoined)")
                                .font(.title3)
                            Text("Contribution points \(contributionPoints)")
                                .font(.title3)
                        }
                        .padding(geometry.size.height * 0.05)
                        
                        // User Contributions
                        VStack {
                            Text("Your Contributions")
                                .font(.title)
                                .fontWeight(.semibold)
                                .padding(.bottom, 10)
                            
                            // Iterate over contributions
                            ForEach(contributions, id: \.self) { contribution in
                                Text(contribution)
                                    .font(.body) // Adjust font style here
                                    .padding(.vertical, 2)
                                    .foregroundColor(.primary)
                            }
                            
                            // Handle case where there are no contributions
                            if contributions.isEmpty {
                                Text("You have no contributions yet.")
                                    .font(.body)
                                    .foregroundColor(.gray)
                                    .padding(.top, 10)
                            }
                        }
                        .padding(.horizontal, 20)
                        .frame(maxWidth: .infinity, alignment: .center)
            }
                    .frame(maxWidth: .infinity, alignment: .center)
            
        }
    }
}

struct DynamicProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Loading Profile...") // Loading indicator
            } else {
                ProfileView(
                    name: viewModel.name,
                    dateJoined: viewModel.dateJoined,
                    contributionPoints: viewModel.contributionPoints,
                    contributions: viewModel.contributions,
                    profileImageURL: viewModel.profileImageURL ?? "https://firebasestorage.googleapis.com/v0/b/myaccessfinal.firebasestorage.app/o/profile_images%2Fdefault_user_image.png?alt=media&token=b0a22669-56e4-4b8a-a6f3-f76f33e31fbd"
                )
            }
        }
        .onAppear {
            if viewModel.isLoading {
                viewModel.fetchUserProfile()
            }
        }
    }
}


#Preview {
    DynamicProfileView()
}

