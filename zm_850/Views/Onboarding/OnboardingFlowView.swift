//
//  OnboardingFlowView.swift
//  MindSpark
//
//  Created on 2026-01-25.
//

import SwiftUI

struct OnboardingFlowView: View {
    @EnvironmentObject var appState: AppStateManager
    @EnvironmentObject var themeManager: ThemeManager
    @State private var currentStep = 0
    
    var body: some View {
        ZStack {
            themeManager.backgroundColor
                .ignoresSafeArea()
            
            TabView(selection: $currentStep) {
                WelcomeStepView(currentStep: $currentStep)
                    .tag(0)
                
                TutorialStepView(currentStep: $currentStep)
                    .tag(1)
                
                PreferencesStepView(currentStep: $currentStep)
                    .tag(2)
                
                FinalStepView()
                    .tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea()
            
            // Custom Page Indicator
            VStack {
                Spacer()
                
                HStack(spacing: 12) {
                    ForEach(0..<4) { index in
                        Circle()
                            .fill(currentStep == index ? ThemeManager.accentYellow : Color.white.opacity(0.3))
                            .frame(width: currentStep == index ? 12 : 8, height: currentStep == index ? 12 : 8)
                            .animation(.spring(), value: currentStep)
                    }
                }
                .padding(.bottom, 50)
            }
        }
    }
}

// MARK: - Step 1: Welcome

struct WelcomeStepView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Binding var currentStep: Int
    @State private var animateGradient = false
    @State private var animateLogo = false
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Animated Logo
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [ThemeManager.accentYellow, ThemeManager.accentBlue],
                            startPoint: animateGradient ? .topLeading : .bottomTrailing,
                            endPoint: animateGradient ? .bottomTrailing : .topLeading
                        )
                    )
                    .frame(width: 150, height: 150)
                    .scaleEffect(animateLogo ? 1.0 : 0.8)
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: animateLogo)
                
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 70))
                    .foregroundColor(.white)
            }
            .onAppear {
                animateGradient = true
                animateLogo = true
            }
            
            Text("MindSpark")
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Text("Ignite Your Cognitive Potential")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(themeManager.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
            
            // Continue Button
            Button(action: {
                withAnimation(.spring()) {
                    currentStep = 1
                }
            }) {
                HStack {
                    Text("Get Started")
                        .font(.system(size: 18, weight: .semibold))
                    Image(systemName: "arrow.right")
                }
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding()
                .background(ThemeManager.accentYellow)
                .cornerRadius(16)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 80)
        }
    }
}

// MARK: - Step 2: Tutorial

struct TutorialStepView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Binding var currentStep: Int
    @State private var currentFeature = 0
    
    let features = [
        Feature(icon: "questionmark.circle.fill", color: ThemeManager.accentYellow, title: "Dynamic Quizzes", description: "Test your knowledge across multiple topics with adaptive difficulty"),
        Feature(icon: "puzzlepiece.fill", color: ThemeManager.accentBlue, title: "Mind Puzzles", description: "Challenge yourself with logic, memory, and pattern recognition games"),
        Feature(icon: "trophy.fill", color: ThemeManager.accentYellow, title: "Daily Challenges", description: "Complete daily tasks and compete with the global community")
    ]
    
    var body: some View {
        VStack(spacing: 40) {
            // Skip Button
            HStack {
                Spacer()
                Button("Skip") {
                    withAnimation(.spring()) {
                        currentStep = 3
                    }
                }
                .foregroundColor(themeManager.textSecondary)
                .padding()
            }
            
            Spacer()
            
            TabView(selection: $currentFeature) {
                ForEach(0..<features.count, id: \.self) { index in
                    FeatureCard(feature: features[index])
                        .tag(index)
                }
            }
            .tabViewStyle(.page)
            .frame(height: 400)
            
            Spacer()
            
            // Navigation Buttons
            HStack(spacing: 20) {
                if currentFeature > 0 {
                    Button(action: {
                        withAnimation {
                            currentFeature -= 1
                        }
                    }) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 50, height: 50)
                            .background(ThemeManager.cardBackground)
                            .cornerRadius(25)
                    }
                }
                
                Spacer()
                
                Button(action: {
                    withAnimation(.spring()) {
                        if currentFeature < features.count - 1 {
                            currentFeature += 1
                        } else {
                            currentStep = 2
                        }
                    }
                }) {
                    HStack {
                        Text(currentFeature < features.count - 1 ? "Next" : "Continue")
                            .font(.system(size: 18, weight: .semibold))
                        Image(systemName: "arrow.right")
                    }
                    .foregroundColor(.black)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 15)
                    .background(ThemeManager.accentYellow)
                    .cornerRadius(25)
                }
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 80)
        }
    }
}

struct Feature {
    let icon: String
    let color: Color
    let title: String
    let description: String
}

struct FeatureCard: View {
    let feature: Feature
    
    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: feature.icon)
                .font(.system(size: 80))
                .foregroundColor(feature.color)
            
            Text(feature.title)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
            
            Text(feature.description)
                .font(.system(size: 18))
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
}

// MARK: - Step 3: Preferences

struct PreferencesStepView: View {
    @EnvironmentObject var appState: AppStateManager
    @EnvironmentObject var themeManager: ThemeManager
    @Binding var currentStep: Int
    @State private var selectedCategories: Set<QuizCategory> = Set(QuizCategory.allCases)
    @State private var selectedDifficulty: DifficultyLevel = .medium
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 30) {
                Text("Personalize Your Experience")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal)
                    .padding(.top, 60)
                
                // Category Selection
                VStack(alignment: .leading, spacing: 15) {
                    Text("Favorite Topics")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                        ForEach(QuizCategory.allCases, id: \.self) { category in
                            CategoryButton(
                                category: category,
                                isSelected: selectedCategories.contains(category)
                            ) {
                                if selectedCategories.contains(category) {
                                    selectedCategories.remove(category)
                                } else {
                                    selectedCategories.insert(category)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Difficulty Selection
                VStack(alignment: .leading, spacing: 15) {
                    Text("Preferred Difficulty")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal)
                    
                    VStack(spacing: 12) {
                        ForEach(DifficultyLevel.allCases, id: \.self) { difficulty in
                            DifficultyButton(
                                difficulty: difficulty,
                                isSelected: selectedDifficulty == difficulty
                            ) {
                                selectedDifficulty = difficulty
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                Spacer(minLength: 100)
            }
        }
        .overlay(
            VStack {
                Spacer()
                Button(action: {
                    // Save preferences
                    appState.userProfile.preferences.selectedCategories = Array(selectedCategories)
                    appState.userProfile.preferences.preferredDifficulty = selectedDifficulty
                    appState.saveProfile()
                    
                    withAnimation(.spring()) {
                        currentStep = 3
                    }
                }) {
                    HStack {
                        Text("Continue")
                            .font(.system(size: 18, weight: .semibold))
                        Image(systemName: "arrow.right")
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(ThemeManager.accentYellow)
                    .cornerRadius(16)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 80)
            }
        )
    }
}

struct CategoryButton: View {
    let category: QuizCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: category.icon)
                    .font(.system(size: 30))
                    .foregroundColor(isSelected ? .black : .white)
                
                Text(category.rawValue)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isSelected ? .black : .white)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(isSelected ? ThemeManager.accentYellow : ThemeManager.cardBackground)
            .cornerRadius(16)
        }
    }
}

struct DifficultyButton: View {
    let difficulty: DifficultyLevel
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(difficulty.rawValue)
                    .font(.system(size: 16, weight: .semibold))
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(ThemeManager.accentBlue)
                }
            }
            .foregroundColor(isSelected ? .black : .white)
            .padding()
            .background(isSelected ? ThemeManager.accentYellow : ThemeManager.cardBackground)
            .cornerRadius(12)
        }
    }
}

// MARK: - Step 4: Final

struct FinalStepView: View {
    @EnvironmentObject var appState: AppStateManager
    @State private var username = ""
    @State private var showAlert = false
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 100))
                .foregroundColor(ThemeManager.accentYellow)
            
            Text("You're All Set!")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.white)
            
            Text("Enter a username to track your progress")
                .font(.system(size: 18))
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            // Username Input
            TextField("Username", text: $username)
                .font(.system(size: 18))
                .foregroundColor(.white)
                .padding()
                .background(ThemeManager.cardBackground)
                .cornerRadius(12)
                .padding(.horizontal, 40)
            
            Spacer()
            
            VStack(spacing: 15) {
                Button(action: {
                    if username.isEmpty {
                        appState.userProfile.username = "Player"
                    } else {
                        appState.userProfile.username = username
                    }
                    appState.completeOnboarding()
                }) {
                    Text("Start Learning")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(ThemeManager.accentYellow)
                        .cornerRadius(16)
                }
                
                Button(action: {
                    appState.userProfile.username = "Player"
                    appState.completeOnboarding()
                }) {
                    Text("Skip for Now")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 80)
        }
    }
}
