//
//  PrivacyPolicyView.swift
//  DiabetesPredictor
//
//  Created by Parry on 05/08/2025.
//

import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                // MARK: - Introduction
                
                
                Text("""
Diabix is committed to protecting your personal information. This application respects your privacy and ensures that all health data entered remains secure and private. Your data is not permanently stored or shared with any third-party services.
""")

                // MARK: - Data Usage
                Text("Data Usage")
                    .font(.headline)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("• Health data is used exclusively for generating real-time predictions and explanations.")
                    Text("• No personal identifiers are collected or stored.")
                    Text("• All data is processed securely through local or encrypted API communication.")
                }

                // MARK: - Audit & Logging
                Text("Audit & Logging")
                    .font(.headline)

                Text("""
Prediction requests are optionally logged on-device to provide transparency and auditing capabilities. These logs do not contain any sensitive or identifiable data.
""")

                // MARK: - Security
                Text("Security")
                    .font(.headline)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("• All communication with backend services is encrypted.")
                    Text("• No data is permanently stored on external servers.")
                    Text("• Predictions are processed in real time using anonymized input features.")
                }

                // MARK: - Contact Information
                Text("Contact Us")
                    .font(.headline)
                
                Text("If you have any questions regarding this policy, please contact our support team at:")
                Text("support@diabix.app")
                    .foregroundColor(.blue)
                    .underline()

                // MARK: - Last Updated
                Text("Last Updated: August 2025")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding()
        }
        .navigationTitle("Privacy Policy")
    }
}
