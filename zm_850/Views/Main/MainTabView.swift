//
//  MainTabView.swift
//  MindSpark
//
//  Created on 2026-01-25.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var appState: AppStateManager
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        TabView(selection: $appState.selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: MainTab.home.icon)
                }
                .tag(MainTab.home)
            
            QuizzesView()
                .tabItem {
                    Label("Quizzes", systemImage: MainTab.quizzes.icon)
                }
                .tag(MainTab.quizzes)
            
            PuzzlesView()
                .tabItem {
                    Label("Puzzles", systemImage: MainTab.puzzles.icon)
                }
                .tag(MainTab.puzzles)
            
            ChallengesView()
                .tabItem {
                    Label("Challenges", systemImage: MainTab.challenges.icon)
                }
                .tag(MainTab.challenges)
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: MainTab.profile.icon)
                }
                .tag(MainTab.profile)
        }
        .accentColor(ThemeManager.accentYellow)
    }
}
