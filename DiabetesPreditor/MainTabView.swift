//
//  MainTabView.swift
//  DiabetesPreditor
//
//  Created by Parry  on 16/07/2025.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var viewModel: PredictionViewModel
    var body: some View {
        TabView {
            PredictionGraphView()
            .tabItem {
                Image(systemName: "waveform.path.ecg")
                Text("Prediction")
            }
            HistoryView()
                            .tabItem {
                                Image(systemName: "clock.arrow.circlepath")
                                Text("History")
                            }

            ProfileView()
                           .tabItem {
                               Image(systemName: "person.crop.circle")
                               Text("Profile")
                           }

        
        }
    }
}

struct MainTableView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
