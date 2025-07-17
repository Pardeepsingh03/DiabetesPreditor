import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct YourApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    // Watch userId in UserDefaults
    @AppStorage("uid") var userId: String?
    @StateObject var viewModel = PredictionViewModel()

    var body: some Scene {
        WindowGroup {
           
                if let _ = userId {
                    // ✅ User is logged in, go to Prediction View
                    MainTabView()
                        .environmentObject(viewModel)
                } else {
                    // 🔐 No userId, show SignUpView
                    WelcomeView()
                }
            
        }
    }
}
