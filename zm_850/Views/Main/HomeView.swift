//
//  HomeView.swift
//  MindSpark
//
//  Created on 2026-01-25.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState: AppStateManager
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var quizViewModel = QuizViewModel()
    @StateObject private var puzzleViewModel = PuzzleViewModel()
    @StateObject private var challengeViewModel = ChallengeViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    // Welcome Header
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Welcome back,")
                                .font(.system(size: 18))
                                .foregroundColor(themeManager.textSecondary)
                            
                            Text(appState.userProfile.username)
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(themeManager.textPrimary)
                        }
                        
                        Spacer()
                        
                        // Streak Badge
                        VStack(spacing: 4) {
                            Image(systemName: "flame.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.orange)
                            
                            Text("\(appState.userProfile.streak)")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(themeManager.textPrimary)
                            
                            Text("Day Streak")
                                .font(.system(size: 10))
                                .foregroundColor(themeManager.textSecondary)
                        }
                        .padding()
                        .background(themeManager.cardColor)
                        .cornerRadius(16)
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    // Stats Cards
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            StatCard(
                                icon: "brain.head.profile",
                                title: "Total Points",
                                value: "\(appState.userProfile.totalPoints)",
                                color: ThemeManager.accentYellow
                            )
                            
                            StatCard(
                                icon: "checkmark.circle.fill",
                                title: "Quizzes",
                                value: "\(appState.userProfile.statistics.totalQuizzesCompleted)",
                                color: ThemeManager.accentBlue
                            )
                            
                            StatCard(
                                icon: "puzzlepiece.fill",
                                title: "Puzzles",
                                value: "\(appState.userProfile.statistics.totalPuzzlesSolved)",
                                color: .green
                            )
                            
                            StatCard(
                                icon: "star.fill",
                                title: "Perfect Scores",
                                value: "\(appState.userProfile.statistics.perfectScores)",
                                color: .purple
                            )
                        }
                        .padding(.horizontal)
                    }
                    
                    // Daily Challenges Section
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            Text("Today's Challenges")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(themeManager.textPrimary)
                            
                            Spacer()
                            
                            NavigationLink(destination: ChallengesView()) {
                                Text("View All")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(ThemeManager.accentBlue)
                            }
                        }
                        .padding(.horizontal)
                        
                        if challengeViewModel.dailyChallenges.isEmpty {
                            EmptyStateView(
                                icon: "trophy.fill",
                                message: "No challenges today",
                                color: ThemeManager.accentYellow
                            )
                        } else {
                            ForEach(challengeViewModel.dailyChallenges.prefix(3)) { challenge in
                                DailyChallengeCard(challenge: challenge)
                                    .padding(.horizontal)
                            }
                        }
                    }
                    
                    // Quick Actions
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Quick Start")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(themeManager.textPrimary)
                            .padding(.horizontal)
                        
                        HStack(spacing: 15) {
                            QuickActionButton(
                                icon: "questionmark.circle.fill",
                                title: "Take Quiz",
                                color: ThemeManager.accentYellow
                            ) {
                                appState.selectedTab = .quizzes
                            }
                            
                            QuickActionButton(
                                icon: "puzzlepiece.fill",
                                title: "Solve Puzzle",
                                color: ThemeManager.accentBlue
                            ) {
                                appState.selectedTab = .puzzles
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer(minLength: 30)
                }
            }
            .background(themeManager.backgroundColor.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(themeManager.textPrimary)
                    }
                }
            }
        }
    }
}

struct StatCard: View {
    @EnvironmentObject var themeManager: ThemeManager
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(themeManager.textPrimary)
            
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(themeManager.textSecondary)
        }
        .frame(width: 120, height: 120)
        .background(themeManager.cardColor)
        .cornerRadius(20)
    }
}

struct DailyChallengeCard: View {
    @EnvironmentObject var themeManager: ThemeManager
    let challenge: DailyChallenge
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: challenge.type.icon)
                    .font(.system(size: 24))
                    .foregroundColor(ThemeManager.accentYellow)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(challenge.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(themeManager.textPrimary)
                    
                    Text(challenge.description)
                        .font(.system(size: 14))
                        .foregroundColor(themeManager.textSecondary)
                }
                
                Spacer()
                
                if challenge.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.green)
                }
            }
            
            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                        .cornerRadius(4)
                    
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [ThemeManager.accentYellow, ThemeManager.accentBlue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * challenge.progressPercentage, height: 8)
                        .cornerRadius(4)
                }
            }
            .frame(height: 8)
            
            HStack {
                Text("\(challenge.currentProgress)/\(challenge.targetValue)")
                    .font(.system(size: 12))
                    .foregroundColor(themeManager.textSecondary)
                
                Spacer()
                
                Text("+\(challenge.reward.points) pts")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(ThemeManager.accentYellow)
            }
        }
        .padding()
        .background(themeManager.cardColor)
        .cornerRadius(16)
    }
}

struct QuickActionButton: View {
    @EnvironmentObject var themeManager: ThemeManager
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 40))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(themeManager.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 30)
            .background(themeManager.cardColor)
            .cornerRadius(20)
        }
    }
}

struct EmptyStateView: View {
    @EnvironmentObject var themeManager: ThemeManager
    let icon: String
    let message: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 50))
                .foregroundColor(color.opacity(0.5))
            
            Text(message)
                .font(.system(size: 16))
                .foregroundColor(themeManager.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(themeManager.cardColor)
        .cornerRadius(16)
    }
}
