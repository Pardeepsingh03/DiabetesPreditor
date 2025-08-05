import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Privacy Policy")
                    .font(.largeTitle)
                    .bold()

                Text("This application respects your privacy. All health data entered in the app remains on your device and is not stored permanently or shared with any third-party services.")
                
                Text("Data Usage")
                    .font(.headline)

                Text("• Your health data is used solely to generate predictions and explanations locally or via secure API calls.\n• No personal identifiers are stored.\n• Data is processed only for the purpose of generating real-time insights.")

                Text("Audit & Logs")
                    .font(.headline)

                Text("Prediction requests are locally logged for audit and transparency purposes. No sensitive or identifiable information is stored.")

                Text("Security")
                    .font(.headline)

                Text("• Secure communication between app and backend\n• No data is permanently stored\n• All predictions are generated in real-time using anonymized inputs")

                Text("For more information, contact the developer team at: support@diabix.app")

                Text("Last Updated: August 2025")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding()
        }
        .navigationTitle("Privacy Policy")
    }
}
