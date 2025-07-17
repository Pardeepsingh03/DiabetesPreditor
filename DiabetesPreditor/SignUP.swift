import SwiftUI
import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import GoogleSignInSwift
import AuthenticationServices

struct SignUpView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var signUpError: String?
    @State private var navigateToHealthInput = false
    @State private var navigateToPrediction = false


    var body: some View {
        ScrollView{
            VStack(spacing: 24) {
                Spacer()
                
                Text("Create Your Account")
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                // Email
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
                
                // Password
                SecureField("Password", text: $password)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
                
                // Sign Up Button
                Button(action: {
                    signUpWithEmail(email: email, password: password) { result in
                        switch result {
                        case .success():
                            print("✅ Sign up successful")
                            navigateToHealthInput = true
                            
                        case .failure(let error):
                            signUpError = error.localizedDescription
                        }
                    }
                }) {
                    Text("Sign Up")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                        .padding(.horizontal, 24)
                }
                
                // Show error if exists
                if let error = signUpError {
                    Text(error)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                }
                
                // OR Divider
                HStack {
                    Rectangle().frame(height: 1).foregroundColor(.gray)
                    Text("or")
                        .foregroundColor(.gray)
                    Rectangle().frame(height: 1).foregroundColor(.gray)
                }
                .padding(.horizontal)
                
                // Google Sign-In Button
                Button(action: {
                    signInWithGoogle()
                }) {
                    HStack {
                        Image(systemName: "globe")
                        Text("Sign up with Google")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.black)
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                    )
                    .padding(.horizontal)
                }
                
                Spacer()
                
                HStack {
                    Text("Already have an account?")
                    Button("Sign In") {
                        // Navigate to Sign In screen
                    }
                    .foregroundColor(.blue)
                }
                .font(.footnote)
                .padding(.bottom)
            }
            // Navigation to HealthDataInputView
            NavigationLink(destination: HealthDataInputView(), isActive: $navigateToHealthInput) {
                EmptyView()
            }

            // Navigation to PredictionGraphView
            NavigationLink(
                destination: MainTabView(),
                isActive: $navigateToPrediction
            ) {
                EmptyView()
            }

        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Firebase Email SignUp
    func signUpWithEmail(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(.failure(error))
            } else {
                if let user = authResult?.user {
                           UserDefaults.standard.set(user.uid, forKey: "uid")
                           print("✅ Saved user UID to UserDefaults: \(user.uid)")
                       }
                completion(.success(()))
            }
        }
    }

    // MARK: - Google SignIn
    func signInWithGoogle() {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            print("❌ Missing Google client ID.")
            return
        }

        let config = GIDConfiguration(clientID: clientID)

        guard let rootViewController = UIApplication.shared.rootVC else {
            print("❌ Could not find root VC")
            return
        }

        GIDSignIn.sharedInstance.configuration = config
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { result, error in
            if let error = error {
                print("❌ Google sign-in error:", error)
                return
            }

            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                print("❌ Failed to get Google ID token.")
                return
            }

            let accessToken = user.accessToken.tokenString

            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)

            Auth.auth().signIn(with: credential) { result, error in
                if let error = error {
                    print("❌ Firebase sign-in with Google failed:", error)
                } else {
                    print("✅ Google Sign-In successful!")
                    if let user = result?.user {
                               UserDefaults.standard.set(user.uid, forKey: "uid")
                               print("✅ Google UID saved to UserDefaults: \(user.uid)")
                           }
                    if let isNewUser = result?.additionalUserInfo?.isNewUser, isNewUser {
                               navigateToHealthInput = true
                           } else {
                               navigateToPrediction = true
                           }
                
                }
            }
        }
    }
    
   
}

// MARK: - Helper to get root VC
extension UIApplication {
    var rootVC: UIViewController? {
        connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?.rootViewController
    }
}
