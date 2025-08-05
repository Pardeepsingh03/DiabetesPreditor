//
//  AboutAppView.swift
//  DiabetesPreditor
//
//  Created by Parry  on 05/08/2025.
//


import SwiftUI

struct AboutAppView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                Text("Diabix is a smart health companion designed to help predict the risk of diabetes using explainable machine learning models. It integrates clinical data with AI-powered predictions, causal reasoning, and intuitive visualizations to support proactive health management.")
                
                Text("Core Features")
                    .font(.headline)

                VStack(alignment: .leading, spacing: 8) {
                    Text("• Real-time diabetes prediction using XGBoost")
                    Text("• Explainable AI with SHAP and Anchor rules")
                    Text("• Causal inference using DoWhy")
                    Text("• Visual feedback for personalized interventions")
                    Text("• iOS frontend with a clean, accessible UI")
                }

                Text("Version 1.0.0")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding()
        }
        .navigationTitle("About App")
    }
}
