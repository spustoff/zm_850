//
//  UserProfile.swift
//  MindSpark
//
//  Created on 2026-01-25.
//

import Foundation

struct UserProfile: Codable {
    var id: UUID
    var username: String
    var totalPoints: Int
    var streak: Int
    var longestStreak: Int
    var lastActiveDate: Date
    var preferences: UserPreferences
    var statistics: UserStatistics
    var achievements: [Achievement]
    var createdAt: Date
    var updatedAt: Date
    
    init(id: UUID = UUID(), username: String = "Player") {
        self.id = id
        self.username = username
        self.totalPoints = 0
        self.streak = 0
        self.longestStreak = 0
        self.lastActiveDate = Date()
        self.preferences = UserPreferences()
        self.statistics = UserStatistics()
        self.achievements = []
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    mutating func updateStreak() {
        let calendar = Calendar.current
        let lastDate = calendar.startOfDay(for: lastActiveDate)
        let today = calendar.startOfDay(for: Date())
        
        let daysDifference = calendar.dateComponents([.day], from: lastDate, to: today).day ?? 0
        
        if daysDifference == 1 {
            // Consecutive day
            streak += 1
            longestStreak = max(longestStreak, streak)
        } else if daysDifference > 1 {
            // Streak broken
            streak = 1
        }
        // If same day, don't change streak
        
        lastActiveDate = Date()
        updatedAt = Date()
    }
}

struct UserPreferences: Codable {
    var selectedCategories: [QuizCategory]
    var preferredDifficulty: DifficultyLevel
    var enableNotifications: Bool
    var soundEnabled: Bool
    var hapticEnabled: Bool
    
    init() {
        self.selectedCategories = QuizCategory.allCases
        self.preferredDifficulty = .medium
        self.enableNotifications = true
        self.soundEnabled = true
        self.hapticEnabled = true
    }
}

struct UserStatistics: Codable {
    var totalQuizzesCompleted: Int
    var totalPuzzlesSolved: Int
    var totalChallengesCompleted: Int
    var averageQuizScore: Double
    var totalTimeSpent: TimeInterval
    var perfectScores: Int
    
    init() {
        self.totalQuizzesCompleted = 0
        self.totalPuzzlesSolved = 0
        self.totalChallengesCompleted = 0
        self.averageQuizScore = 0.0
        self.totalTimeSpent = 0
        self.perfectScores = 0
    }
    
    mutating func updateQuizStats(score: Double, isPerfect: Bool) {
        let newTotal = totalQuizzesCompleted + 1
        averageQuizScore = (averageQuizScore * Double(totalQuizzesCompleted) + score) / Double(newTotal)
        totalQuizzesCompleted = newTotal
        if isPerfect {
            perfectScores += 1
        }
    }
}

struct Achievement: Identifiable, Codable {
    let id: UUID
    var title: String
    var description: String
    var icon: String
    var unlockedAt: Date?
    var isUnlocked: Bool
    
    init(id: UUID = UUID(), title: String, description: String, icon: String, isUnlocked: Bool = false) {
        self.id = id
        self.title = title
        self.description = description
        self.icon = icon
        self.isUnlocked = isUnlocked
        self.unlockedAt = isUnlocked ? Date() : nil
    }
}
