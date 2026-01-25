//
//  DailyChallenge.swift
//  MindSpark
//
//  Created on 2026-01-25.
//

import Foundation

struct DailyChallenge: Identifiable, Codable {
    let id: UUID
    var date: Date
    var title: String
    var description: String
    var type: ChallengeType
    var targetValue: Int
    var currentProgress: Int
    var isCompleted: Bool
    var reward: ChallengeReward
    
    init(id: UUID = UUID(), date: Date = Date(), title: String, description: String, type: ChallengeType, targetValue: Int, reward: ChallengeReward) {
        self.id = id
        self.date = date
        self.title = title
        self.description = description
        self.type = type
        self.targetValue = targetValue
        self.currentProgress = 0
        self.isCompleted = false
        self.reward = reward
    }
    
    var progressPercentage: Double {
        guard targetValue > 0 else { return 0 }
        return min(Double(currentProgress) / Double(targetValue), 1.0)
    }
}

enum ChallengeType: String, Codable {
    case completeQuizzes = "Complete Quizzes"
    case solvePuzzles = "Solve Puzzles"
    case perfectScore = "Perfect Score"
    case timeChallenge = "Time Challenge"
    case streak = "Streak"
    case variety = "Variety"
    
    var icon: String {
        switch self {
        case .completeQuizzes: return "checkmark.circle.fill"
        case .solvePuzzles: return "puzzlepiece.fill"
        case .perfectScore: return "star.fill"
        case .timeChallenge: return "timer"
        case .streak: return "flame.fill"
        case .variety: return "sparkles"
        }
    }
}

struct ChallengeReward: Codable {
    var points: Int
    var badge: String?
    var title: String?
    
    init(points: Int, badge: String? = nil, title: String? = nil) {
        self.points = points
        self.badge = badge
        self.title = title
    }
}
