import SwiftUI
import Firebase
import GoogleSignIn
import FirebaseAuth

@MainActor
class AuthenticationViewModel: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var userEmail: String = ""
    @Published var errorMessage: String = ""
    
    // For email sign-up/login
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var name: String = ""
    private let userService = UserService()
    
    var currentUserID: String {
            return Auth.auth().currentUser?.uid ?? ""
        }
    
    func signUpWithEmail(image: UIImage?, completion: @escaping (Bool) -> Void) {
        Task {
            do {
                // Create the user in Firebase Authentication
                let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
                let userId = authResult.user.uid
                
                // Update display name
                let changeRequest = authResult.user.createProfileChangeRequest()
                changeRequest.displayName = name
                try await changeRequest.commitChanges()
                
                // Upload profile image if provided
                if let image = image {
                    ImageUploader.uploadImage(image: image) { imageUrl in
                        // Save user to Firestore with image URL
                        self.userService.createUser(userId: userId, email: self.email, name: self.name, profileImageURL: imageUrl) { result in
                            self.handleFirestoreResult(result, authResult: authResult, completion: completion)
                        }
                    }
                } else {
                    // Save user to Firestore without image URL
                    
                    userService.createUser(userId: userId, email: email, name: name) { result in
                        self.handleFirestoreResult(result, authResult: authResult, completion: completion)
                    }
                }
            } catch {
                Task { @MainActor in
                    self.errorMessage = error.localizedDescription
                    completion(false)
                }
            }
        }
    }

    private func handleFirestoreResult(_ result: Result<Void, Error>, authResult: AuthDataResult, completion: @escaping (Bool) -> Void) {
        switch result {
        case .success:
            Task { @MainActor in
                self.isLoggedIn = true
                self.userEmail = authResult.user.email ?? "No Email"
                completion(true)
            }
        case .failure(let error):
            Task { @MainActor in
                self.errorMessage = "Failed to save user: \(error.localizedDescription)"
                completion(false)
            }
        }
    }



    func loginWithEmail(completion: @escaping (Bool) -> Void) {
            Task {
                do {
                    // Log in user in Firebase
                    print("Attempting sign-up with email: \(email), password: \(password)")
                    let authResult = try await Auth.auth().signIn(withEmail: email, password: password)
                    await MainActor.run {
                        self.isLoggedIn = true
                        self.userEmail = authResult.user.email ?? "No Email"
                        print("Login successful for user: \(authResult.user.email ?? "Unknown")")
                        completion(true)
                    }
                } catch {
                    await MainActor.run {
                        self.errorMessage = error.localizedDescription
                        print("Error during email login: \(error.localizedDescription)")
                        completion(false)
                    }
                }
            }
        }

    func signInWithGoogle(completion: @escaping (Bool) -> Void) {
        guard let presentingViewController = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController else {
            completion(false)
            return
        }

        GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { [weak self] user, error in
            guard let self = self else { return } // Explicitly capture `self` safely

            if let error = error {
                self.errorMessage = error.localizedDescription
                completion(false)
                return
            }

            guard let idToken = user?.user.idToken?.tokenString else {
                completion(false)
                return
            }

            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user?.user.accessToken.tokenString ?? "")

            Task {
                do {
                    let authResult = try await Auth.auth().signIn(with: credential)
                    let userId = authResult.user.uid
                    let email = authResult.user.email ?? ""
                    let name = authResult.user.displayName ?? ""

                    // Save user to Firestore
                    self.userService.createUser(userId: userId, email: email, name: name) { result in
                        switch result {
                        case .success:
                            print("User saved in Firestore.")
                            Task { @MainActor in
                                self.isLoggedIn = true
                                self.userEmail = email
                                completion(true)
                            }
                        case .failure(let error):
                            Task { @MainActor in
                                self.errorMessage = "Failed to save user: \(error.localizedDescription)"
                                completion(false)
                            }
                        }
                    }
                } catch {
                    Task { @MainActor in
                        self.errorMessage = error.localizedDescription
                        completion(false)
                    }
                }
            }
        }
    }

    
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            GIDSignIn.sharedInstance.signOut()
            self.isLoggedIn = false
            self.userEmail = ""
            print("User signed out.")
        } catch {
            self.errorMessage = error.localizedDescription
            print("Error during sign out: \(error.localizedDescription)")
        }
    }
}
