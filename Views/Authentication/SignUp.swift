import SwiftUI

struct SignUp: View {
    @StateObject private var viewModel = AuthenticationViewModel()
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var selectedImage: UIImage? = nil
    @State private var showImagePicker: Bool = false
    @State private var errorMessage: String = ""
    @State private var isSignUpSuccessful = false
    
    let backgroundColors = Color(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1))

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Create new account")
                    .foregroundColor(Color.blue)
                    .fontWeight(.bold)

                // Name field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Enter your name")
                    TextField("John Doe", text: $viewModel.name)
                        .foregroundColor(.black)
                        .padding()
                        .background(backgroundColors)
                        .cornerRadius(8)
                }
                .padding(.horizontal)

                // Email field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Enter your email")
                    TextField("johndoe@gmail.com", text: $viewModel.email)
                        .foregroundColor(.black)
                        .padding()
                        .background(backgroundColors)
                        .cornerRadius(8)
                }
                .padding(.horizontal)

                // Password field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Enter your password")
                    SecureField("••••••••", text: $password)
                        .foregroundColor(.black)
                        .padding()
                        .background(backgroundColors)
                        .cornerRadius(8)
                        .onChange(of: password) { oldValue, newValue in
                            validatePasswords()
                        }
                }
                .padding(.horizontal)

                // Confirm Password field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Confirm your password")
                    SecureField("••••••••", text: $confirmPassword)
                        .foregroundColor(.black)
                        .padding()
                        .background(backgroundColors)
                        .cornerRadius(8)
                        .onChange(of: confirmPassword) { oldValue, newValue in
                            validatePasswords()
                        }
                }
                .padding(.horizontal)

                // Optional Image Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Upload your profile image (optional)")
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .padding(.top, 8)
                    } else {
                        Button(action: {
                            showImagePicker = true
                        }) {
                            Text("Select Image")
                                .foregroundColor(.blue)
                        }
                    }
                }
                .padding(.horizontal)

                // Display error message if any
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                }

                // Sign Up button
                Button(action: {
                    guard errorMessage.isEmpty else {
                        return // Prevent sign-up if there's an error
                    }
                    viewModel.password = password
                    viewModel.signUpWithEmail(image: selectedImage) { success in
                        if success {
                            isSignUpSuccessful = true
                        } else {
                            errorMessage = viewModel.errorMessage
                        }
                    }
                }) {
                    HStack {
                        Text("Sign Up")
                            .foregroundColor(.white)
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                    }
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
                }
                .padding(.horizontal)

                Spacer()

                // Navigation to login page
                HStack {
                    Text("Already have an account?")
                    NavigationLink(destination: LogIn()) {
                        Text("Log In")
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.top, 16)
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $selectedImage)
            }
            .padding(.vertical, 32)
            .navigationTitle("")
            .navigationDestination(isPresented: $isSignUpSuccessful) {
                MainView()
            }
        }
    }

    /// Validates passwords and updates the error message dynamically
    private func validatePasswords() {
        if password.isEmpty || confirmPassword.isEmpty {
            errorMessage = "Password fields cannot be empty."
        } else if password.count < 6 {
            errorMessage = "Password must be at least 6 characters long."
        } else if password != confirmPassword {
            errorMessage = "Passwords do not match."
        } else {
            errorMessage = "" // No error
        }
    }
}
