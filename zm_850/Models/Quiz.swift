//
//  Quiz.swift
//  MindSpark
//
//  Created on 2026-01-25.
//

import Foundation

struct Quiz: Identifiable, Codable {
    let id: UUID
    var title: String
    var category: QuizCategory
    var difficulty: DifficultyLevel
    var questions: [Question]
    var timeLimit: TimeInterval?
    var createdAt: Date
    var updatedAt: Date
    
    init(id: UUID = UUID(), title: String, category: QuizCategory, difficulty: DifficultyLevel, questions: [Question], timeLimit: TimeInterval? = nil) {
        self.id = id
        self.title = title
        self.category = category
        self.difficulty = difficulty
        self.questions = questions
        self.timeLimit = timeLimit
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

struct Question: Identifiable, Codable {
    let id: UUID
    var text: String
    var options: [String]
    var correctAnswerIndex: Int
    var explanation: String?
    
    init(id: UUID = UUID(), text: String, options: [String], correctAnswerIndex: Int, explanation: String? = nil) {
        self.id = id
        self.text = text
        self.options = options
        self.correctAnswerIndex = correctAnswerIndex
        self.explanation = explanation
    }
}

enum QuizCategory: String, Codable, CaseIterable {
    case science = "Science"
    case history = "History"
    case geography = "Geography"
    case literature = "Literature"
    case mathematics = "Mathematics"
    case technology = "Technology"
    case arts = "Arts"
    case sports = "Sports"
    case general = "General Knowledge"
    
    var icon: String {
        switch self {
        case .science: return "atom"
        case .history: return "clock.arrow.circlepath"
        case .geography: return "globe.americas"
        case .literature: return "book.fill"
        case .mathematics: return "function"
        case .technology: return "cpu"
        case .arts: return "paintbrush.fill"
        case .sports: return "sportscourt.fill"
        case .general: return "lightbulb.fill"
        }
    }
}

enum DifficultyLevel: String, Codable, CaseIterable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    case expert = "Expert"
    
    var color: String {
        switch self {
        case .easy: return "green"
        case .medium: return "yellow"
        case .hard: return "orange"
        case .expert: return "red"
        }
    }
}
