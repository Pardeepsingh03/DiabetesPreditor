import SwiftUI
import GoogleSignIn
import FirebaseAuth

struct ProfileView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    
                    // Profile Header
                   
                    
                    // Settings Section
                    VStack(spacing: 10) {
                        NavigationLink(destination: Text("Prediction History Screen")) {
                            ProfileRowView(icon: "clock", title: "Prediction History")
                        }
                        
                        NavigationLink(destination: Text("About App Screen")) {
                            ProfileRowView(icon: "info.circle", title: "About App")
                        }
                        
                        NavigationLink(destination: Text("Privacy Policy Screen")) {
                            ProfileRowView(icon: "lock.shield", title: "Privacy Policy")
                        }
                        
                        Button(action: {
                            // Handle logout logic here
                            signOutUser()
                        }) {
                            ProfileRowView(icon: "arrow.right.square", title: "Sign Out", isDestructive: true)
                        }
                    }
                    .padding(.horizontal)
                }
                .navigationTitle("Profile")
            }
        }
    }
}

struct ProfileRowView: View {
    let icon: String
    let title: String
    var isDestructive: Bool = false
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .frame(width: 24, height: 24)
                .foregroundColor(isDestructive ? .red : .blue)
            
            Text(title)
                .foregroundColor(isDestructive ? .red : .primary)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}


func signOutUser() {
    do {
        // Sign out from Firebase
        try Auth.auth().signOut()
        UserDefaults.standard.removeObject(forKey: "uid")
        // Also sign out from Google if used
        if let user = Auth.auth().currentUser, user.providerData.contains(where: { $0.providerID == "google.com" }) {
            GIDSignIn.sharedInstance.signOut()
        }

        print("User signed out")
        // Navigate to login screen or update UI state
    } catch let signOutError as NSError {
        print("Error signing out: %@", signOutError)
    }
}
