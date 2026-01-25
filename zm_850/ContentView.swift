//
//  ContentView.swift
//  MindSpark
//
//  Created on 2026-01-25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppStateManager
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        ZStack {
            if appState.hasCompletedOnboarding {
                MainTabView()
            } else {
                OnboardingFlowView()
            }
        }
        .animation(.easeInOut, value: appState.hasCompletedOnboarding)
    }
}
