import SwiftUI
import FirebaseAuth
import GoogleSignIn

struct LogIn: View {
    @StateObject private var viewModel = AuthenticationViewModel()
    @State private var isSignUp: Bool = false
    @State private var isLoggedIn = false  // State to track login
    @State private var hasNoAccount = false

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var name: String = ""

    let backgroundColors = Color(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1))
    
    var body: some View {
        NavigationStack {
            VStack {
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
                    SecureField("••••••••", text: $viewModel.password)
                        .foregroundColor(.black)
                        .padding()
                        .background(backgroundColors)
                        .cornerRadius(8)
                }
                .padding(.horizontal)

                // Login with password button
                Button(action: {
                    viewModel.loginWithEmail { success in
                        if success {
                            isLoggedIn = true
                        }
                    }
                }) {
                    Text("Log in")
                        .foregroundColor(.white)
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .padding(.horizontal)

                Spacer()
                // Sign in with Google button
                Button(action: {
                    viewModel.signInWithGoogle { success in
                        if success {
                            isLoggedIn = true
                        }
                    }
                }) {
                    HStack {
                        Image("Google")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .padding(.trailing, 8)
                        
                        Text("Sign in with Google")
                            .foregroundColor(.black)
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                    }
                    .padding()
                    .background(backgroundColors)
                    .cornerRadius(8)
                }
                .padding(.horizontal)

                // Signup navigation
                HStack {
                    Text("Don't have an account?")
                    NavigationLink(destination: SignUp()) {
                        Text("Sign Up")
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.top, 16)
            }
            .padding(.vertical, 32)  // Add some vertical padding
            .navigationTitle("")
            .navigationDestination(isPresented: $isLoggedIn) {
                MainView()
            }
        }
        
    }
}

#Preview {
    LogIn()
}
