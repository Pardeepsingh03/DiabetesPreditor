//
//  Welcome.swift
//  DiabetesPreditor
//
//  Created by Parry  on 15/07/2025.
//
import SwiftUI

struct WelcomeView: View {
    var body: some View {
       
        NavigationView {
            VStack(spacing: 0) {
                // Top gradient
                ZStack {
                    LinearGradient(
                        gradient: Gradient(colors: [Color(red: 0.0, green: 0.4, blue: 0.7),
                                                    Color(red: 0.6, green: 0.8, blue: 1.0)]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 350)
                    .edgesIgnoringSafeArea(.top)
                    
                    VStack(spacing: 20) {
                        Image(systemName: "drop.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.white)
                            .opacity(0.5)
                        
                        Text("Diabix")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                
                // Main content
                VStack(spacing: 16) {
                    Text("Welcome to DiabIX")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                    
                    Text("Your smart health partner powered by AI and personalized data to help you understand your diabetes risk. Start your journey to better health today.")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Spacer()
                    
                    NavigationLink(destination: SignUpView()) {
                        Text("Get Started")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                            .padding(.horizontal, 24)
                    }
                    .padding(.bottom, 40)
                }
                .padding(.top, 32)
                
            }
        }
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}


