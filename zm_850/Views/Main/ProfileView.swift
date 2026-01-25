//
//  ProfileView.swift
//  MindSpark
//
//  Created on 2026-01-25.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var appState: AppStateManager
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showingSettings = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    // Profile Header
                    VStack(spacing: 15) {
                        // Avatar
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [ThemeManager.accentYellow, ThemeManager.accentBlue],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 100, height: 100)
                            
                            Text(String(appState.userProfile.username.prefix(1)).uppercased())
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(.white)
                        }
                        
                        Text(appState.userProfile.username)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(themeManager.textPrimary)
                        
                        // Points & Streak
                        HStack(spacing: 30) {
                            VStack(spacing: 4) {
                                Text("\(appState.userProfile.totalPoints)")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(ThemeManager.accentYellow)
                                
                                Text("Points")
                                    .font(.system(size: 12))
                                    .foregroundColor(themeManager.textSecondary)
                            }
                            
                            VStack(spacing: 4) {
                                HStack(spacing: 4) {
                                    Image(systemName: "flame.fill")
                                        .foregroundColor(.orange)
                                    Text("\(appState.userProfile.streak)")
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(themeManager.textPrimary)
                                }
                                
                                Text("Day Streak")
                                    .font(.system(size: 12))
                                    .foregroundColor(themeManager.textSecondary)
                            }
                            
                            VStack(spacing: 4) {
                                Text("\(appState.userProfile.longestStreak)")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(themeManager.textPrimary)
                                
                                Text("Best Streak")
                                    .font(.system(size: 12))
                                    .foregroundColor(themeManager.textSecondary)
                            }
                        }
                    }
                    .padding()
                    .background(themeManager.cardColor)
                    .cornerRadius(20)
                    .padding(.horizontal)
                    .padding(.top)
                    
                    // Statistics
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Statistics")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(themeManager.textPrimary)
                            .padding(.horizontal)
                        
                        VStack(spacing: 12) {
                            StatRow(
                                icon: "checkmark.circle.fill",
                                title: "Quizzes Completed",
                                value: "\(appState.userProfile.statistics.totalQuizzesCompleted)",
                                color: ThemeManager.accentYellow
                            )
                            
                            StatRow(
                                icon: "puzzlepiece.fill",
                                title: "Puzzles Solved",
                                value: "\(appState.userProfile.statistics.totalPuzzlesSolved)",
                                color: ThemeManager.accentBlue
                            )
                            
                            StatRow(
                                icon: "star.fill",
                                title: "Perfect Scores",
                                value: "\(appState.userProfile.statistics.perfectScores)",
                                color: .purple
                            )
                            
                            StatRow(
                                icon: "chart.line.uptrend.xyaxis",
                                title: "Average Quiz Score",
                                value: String(format: "%.1f%%", appState.userProfile.statistics.averageQuizScore),
                                color: .green
                            )
                            
                            StatRow(
                                icon: "trophy.fill",
                                title: "Challenges Completed",
                                value: "\(appState.userProfile.statistics.totalChallengesCompleted)",
                                color: .orange
                            )
                        }
                        .padding()
                        .background(themeManager.cardColor)
                        .cornerRadius(20)
                        .padding(.horizontal)
                    }
                    
                    // Achievements
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Achievements")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(themeManager.textPrimary)
                            .padding(.horizontal)
                        
                        if appState.userProfile.achievements.isEmpty {
                            EmptyStateView(
                                icon: "medal.fill",
                                message: "No achievements yet\nKeep learning to unlock badges!",
                                color: ThemeManager.accentYellow
                            )
                            .padding(.horizontal)
                        } else {
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                                ForEach(appState.userProfile.achievements) { achievement in
                                    AchievementCard(achievement: achievement)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    Spacer(minLength: 30)
                }
            }
            .background(themeManager.backgroundColor.ignoresSafeArea())
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingSettings = true
                    }) {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(themeManager.textPrimary)
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
        }
    }
}

struct StatRow: View {
    @EnvironmentObject var themeManager: ThemeManager
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
                .frame(width: 30)
            
            Text(title)
                .font(.system(size: 16))
                .foregroundColor(themeManager.textPrimary)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(themeManager.textPrimary)
        }
    }
}

struct AchievementCard: View {
    @EnvironmentObject var themeManager: ThemeManager
    let achievement: Achievement
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: achievement.icon)
                .font(.system(size: 40))
                .foregroundColor(achievement.isUnlocked ? ThemeManager.accentYellow : themeManager.textSecondary)
            
            Text(achievement.title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(themeManager.textPrimary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
            
            Text(achievement.description)
                .font(.system(size: 11))
                .foregroundColor(themeManager.textSecondary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            achievement.isUnlocked ?
            themeManager.cardColor :
            themeManager.cardColor.opacity(0.5)
        )
        .cornerRadius(16)
        .opacity(achievement.isUnlocked ? 1.0 : 0.6)
    }
}
