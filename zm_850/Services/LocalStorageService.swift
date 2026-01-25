//
//  LocalStorageService.swift
//  MindSpark
//
//  Created on 2026-01-25.
//

import Foundation

class LocalStorageService {
    static let shared = LocalStorageService()
    
    private let userProfileKey = "userProfile"
    private let quizResultsKey = "quizResults"
    private let puzzleProgressKey = "puzzleProgress"
    private let dailyChallengesKey = "dailyChallenges"
    
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    private init() {
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
    }
    
    // MARK: - User Profile
    
    func saveUserProfile(_ profile: UserProfile) {
        if let encoded = try? encoder.encode(profile) {
            UserDefaults.standard.set(encoded, forKey: userProfileKey)
        }
    }
    
    func loadUserProfile() -> UserProfile? {
        guard let data = UserDefaults.standard.data(forKey: userProfileKey),
              let profile = try? decoder.decode(UserProfile.self, from: data) else {
            return nil
        }
        return profile
    }
    
    func deleteUserProfile() {
        UserDefaults.standard.removeObject(forKey: userProfileKey)
    }
    
    // MARK: - Quiz Results
    
    func saveQuizResult(_ result: QuizResult) {
        var results = loadQuizResults()
        results.append(result)
        
        // Keep only last 100 results
        if results.count > 100 {
            results = Array(results.suffix(100))
        }
        
        if let encoded = try? encoder.encode(results) {
            UserDefaults.standard.set(encoded, forKey: quizResultsKey)
        }
    }
    
    func loadQuizResults() -> [QuizResult] {
        guard let data = UserDefaults.standard.data(forKey: quizResultsKey),
              let results = try? decoder.decode([QuizResult].self, from: data) else {
            return []
        }
        return results
    }
    
    // MARK: - Puzzle Progress
    
    func savePuzzleProgress(_ puzzles: [Puzzle]) {
        if let encoded = try? encoder.encode(puzzles) {
            UserDefaults.standard.set(encoded, forKey: puzzleProgressKey)
        }
    }
    
    func loadPuzzleProgress() -> [Puzzle] {
        guard let data = UserDefaults.standard.data(forKey: puzzleProgressKey),
              let puzzles = try? decoder.decode([Puzzle].self, from: data) else {
            return []
        }
        return puzzles
    }
    
    // MARK: - Daily Challenges
    
    func saveDailyChallenges(_ challenges: [DailyChallenge]) {
        if let encoded = try? encoder.encode(challenges) {
            UserDefaults.standard.set(encoded, forKey: dailyChallengesKey)
        }
    }
    
    func loadDailyChallenges() -> [DailyChallenge] {
        guard let data = UserDefaults.standard.data(forKey: dailyChallengesKey),
              let challenges = try? decoder.decode([DailyChallenge].self, from: data) else {
            return []
        }
        return challenges
    }
    
    // MARK: - Reset
    
    func resetAllData() {
        UserDefaults.standard.removeObject(forKey: userProfileKey)
        UserDefaults.standard.removeObject(forKey: quizResultsKey)
        UserDefaults.standard.removeObject(forKey: puzzleProgressKey)
        UserDefaults.standard.removeObject(forKey: dailyChallengesKey)
    }
}

struct QuizResult: Identifiable, Codable {
    let id: UUID
    var quizId: UUID
    var quizTitle: String
    var score: Double
    var correctAnswers: Int
    var totalQuestions: Int
    var timeTaken: TimeInterval
    var completedAt: Date
    
    init(id: UUID = UUID(), quizId: UUID, quizTitle: String, score: Double, correctAnswers: Int, totalQuestions: Int, timeTaken: TimeInterval) {
        self.id = id
        self.quizId = quizId
        self.quizTitle = quizTitle
        self.score = score
        self.correctAnswers = correctAnswers
        self.totalQuestions = totalQuestions
        self.timeTaken = timeTaken
        self.completedAt = Date()
    }
}
