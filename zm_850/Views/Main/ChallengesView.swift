//
//  ChallengesView.swift
//  MindSpark
//
//  Created on 2026-01-25.
//

import SwiftUI

struct ChallengesView: View {
    @EnvironmentObject var appState: AppStateManager
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var viewModel = ChallengeViewModel()
    @State private var selectedSegment = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Segment Control
                Picker("Challenge Type", selection: $selectedSegment) {
                    Text("Daily").tag(0)
                    Text("Community").tag(1)
                }
                .pickerStyle(.segmented)
                .padding()
                .background(themeManager.backgroundColor)
                
                // Content
                if selectedSegment == 0 {
                    DailyChallengesListView(viewModel: viewModel)
                } else {
                    CommunityChallengesListView(viewModel: viewModel)
                }
            }
            .background(themeManager.backgroundColor.ignoresSafeArea())
            .navigationTitle("Challenges")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct DailyChallengesListView: View {
    @EnvironmentObject var appState: AppStateManager
    @EnvironmentObject var themeManager: ThemeManager
    @ObservedObject var viewModel: ChallengeViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: "calendar")
                            .font(.system(size: 24))
                            .foregroundColor(ThemeManager.accentYellow)
                        
                        Text(Date().formatted(date: .long, time: .omitted))
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(themeManager.textPrimary)
                    }
                    
                    Text("Complete challenges to earn points and badges!")
                        .font(.system(size: 14))
                        .foregroundColor(themeManager.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(themeManager.cardColor)
                .cornerRadius(16)
                .padding(.horizontal)
                .padding(.top)
                
                // Challenges
                if viewModel.dailyChallenges.isEmpty {
                    EmptyStateView(
                        icon: "trophy.fill",
                        message: "No challenges available",
                        color: ThemeManager.accentYellow
                    )
                    .padding()
                } else {
                    LazyVStack(spacing: 15) {
                        ForEach(viewModel.dailyChallenges) { challenge in
                            DailyChallengeDetailCard(
                                challenge: challenge,
                                onClaim: {
                                    if let reward = viewModel.completeChallenge(challenge.id) {
                                        appState.addPoints(reward.points)
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                
                Spacer(minLength: 30)
            }
        }
    }
}

struct DailyChallengeDetailCard: View {
    @EnvironmentObject var themeManager: ThemeManager
    let challenge: DailyChallenge
    let onClaim: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack(alignment: .top) {
                Image(systemName: challenge.type.icon)
                    .font(.system(size: 30))
                    .foregroundColor(ThemeManager.accentYellow)
                    .frame(width: 50, height: 50)
                    .background(ThemeManager.accentYellow.opacity(0.2))
                    .cornerRadius(25)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(challenge.title)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(themeManager.textPrimary)
                    
                    Text(challenge.description)
                        .font(.system(size: 14))
                        .foregroundColor(themeManager.textSecondary)
                }
                
                Spacer()
                
                if challenge.isCompleted {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.green)
                }
            }
            
            // Progress
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Progress")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(themeManager.textSecondary)
                    
                    Spacer()
                    
                    Text("\(challenge.currentProgress)/\(challenge.targetValue)")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(themeManager.textPrimary)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 12)
                        
                        RoundedRectangle(cornerRadius: 6)
                            .fill(
                                LinearGradient(
                                    colors: [ThemeManager.accentYellow, ThemeManager.accentBlue],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * challenge.progressPercentage, height: 12)
                    }
                }
                .frame(height: 12)
            }
            
            // Reward
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "star.fill")
                        .foregroundColor(ThemeManager.accentYellow)
                    
                    Text("+\(challenge.reward.points) points")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(themeManager.textPrimary)
                    
                    if let badge = challenge.reward.badge {
                        Text(badge)
                            .font(.system(size: 20))
                    }
                }
                
                Spacer()
                
                if challenge.isCompleted {
                    Button(action: onClaim) {
                        Text("Claim")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.black)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(ThemeManager.accentYellow)
                            .cornerRadius(20)
                    }
                }
            }
        }
        .padding()
        .background(themeManager.cardColor)
        .cornerRadius(20)
    }
}

struct CommunityChallengesListView: View {
    @EnvironmentObject var appState: AppStateManager
    @EnvironmentObject var themeManager: ThemeManager
    @ObservedObject var viewModel: ChallengeViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: "globe")
                            .font(.system(size: 24))
                            .foregroundColor(ThemeManager.accentBlue)
                        
                        Text("Global Challenges")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(themeManager.textPrimary)
                    }
                    
                    Text("Compete with players worldwide!")
                        .font(.system(size: 14))
                        .foregroundColor(themeManager.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(themeManager.cardColor)
                .cornerRadius(16)
                .padding(.horizontal)
                .padding(.top)
                
                // Challenges
                LazyVStack(spacing: 15) {
                    ForEach(viewModel.communityChallenges) { challenge in
                        CommunityChallengeCard(challenge: challenge)
                    }
                }
                .padding(.horizontal)
                
                Spacer(minLength: 30)
            }
        }
    }
}

struct CommunityChallengeCard: View {
    @EnvironmentObject var themeManager: ThemeManager
    @State var challenge: CommunityChallenge
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(challenge.title)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(themeManager.textPrimary)
                    
                    Text(challenge.description)
                        .font(.system(size: 14))
                        .foregroundColor(themeManager.textSecondary)
                }
                
                Spacer()
            }
            
            // Participants & Time
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "person.2.fill")
                        .font(.system(size: 12))
                    Text("\(challenge.participants)")
                        .font(.system(size: 12, weight: .semibold))
                }
                .foregroundColor(themeManager.textSecondary)
                
                Spacer()
                
                HStack(spacing: 6) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 12))
                    Text(challenge.timeRemainingFormatted)
                        .font(.system(size: 12, weight: .semibold))
                }
                .foregroundColor(.orange)
            }
            
            // Progress (if joined)
            if challenge.isJoined {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Your Progress")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(themeManager.textSecondary)
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 8)
                            
                            RoundedRectangle(cornerRadius: 6)
                                .fill(ThemeManager.accentBlue)
                                .frame(width: geometry.size.width * challenge.progress, height: 8)
                        }
                    }
                    .frame(height: 8)
                }
            }
            
            // Reward & Action
            HStack {
                HStack(spacing: 8) {
                    if let badge = challenge.reward.badge {
                        Text(badge)
                            .font(.system(size: 20))
                    }
                    
                    Text("+\(challenge.reward.points) pts")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(ThemeManager.accentYellow)
                }
                
                Spacer()
                
                Button(action: {
                    challenge.isJoined.toggle()
                }) {
                    Text(challenge.isJoined ? "Joined" : "Join")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(challenge.isJoined ? themeManager.textPrimary : .black)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(challenge.isJoined ? themeManager.cardColor.opacity(0.5) : ThemeManager.accentBlue)
                        .cornerRadius(20)
                }
            }
        }
        .padding()
        .background(themeManager.cardColor)
        .cornerRadius(20)
    }
}
