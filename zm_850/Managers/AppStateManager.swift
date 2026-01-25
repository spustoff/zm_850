//
//  AppStateManager.swift
//  MindSpark
//
//  Created on 2026-01-25.
//

import SwiftUI
import Combine

class AppStateManager: ObservableObject {
    @Published var hasCompletedOnboarding: Bool {
        didSet {
            UserDefaults.standard.set(hasCompletedOnboarding, forKey: "hasCompletedOnboarding")
        }
    }
    
    @Published var currentOnboardingStep: Int {
        didSet {
            UserDefaults.standard.set(currentOnboardingStep, forKey: "currentOnboardingStep")
        }
    }
    
    @Published var userProfile: UserProfile
    @Published var selectedTab: MainTab = .home
    
    init() {
        // Load onboarding state
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        self.currentOnboardingStep = UserDefaults.standard.integer(forKey: "currentOnboardingStep")
        
        // Load or create user profile
        if let profile = LocalStorageService.shared.loadUserProfile() {
            self.userProfile = profile
        } else {
            self.userProfile = UserProfile()
        }
        
        // Update streak on app launch
        updateDailyStreak()
    }
    
    func completeOnboarding() {
        hasCompletedOnboarding = true
        currentOnboardingStep = 0
        saveProfile()
    }
    
    func saveProfile() {
        userProfile.updatedAt = Date()
        LocalStorageService.shared.saveUserProfile(userProfile)
    }
    
    func updateDailyStreak() {
        userProfile.updateStreak()
        saveProfile()
    }
    
    func addPoints(_ points: Int) {
        userProfile.totalPoints += points
        saveProfile()
    }
    
    func resetApp() {
        // Reset user data
        LocalStorageService.shared.resetAllData()
        
        // Create new profile
        userProfile = UserProfile()
        
        // Reset onboarding
        hasCompletedOnboarding = false
        currentOnboardingStep = 0
        selectedTab = .home
    }
}

enum MainTab: String, CaseIterable {
    case home = "Home"
    case quizzes = "Quizzes"
    case puzzles = "Puzzles"
    case challenges = "Challenges"
    case profile = "Profile"
    
    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .quizzes: return "questionmark.circle.fill"
        case .puzzles: return "puzzlepiece.fill"
        case .challenges: return "trophy.fill"
        case .profile: return "person.fill"
        }
    }
}
