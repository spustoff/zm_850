//
//  Puzzle.swift
//  MindSpark
//
//  Created on 2026-01-25.
//

import Foundation

struct Puzzle: Identifiable, Codable {
    let id: UUID
    var title: String
    var type: PuzzleType
    var difficulty: DifficultyLevel
    var description: String
    var data: PuzzleData
    var timeLimit: TimeInterval?
    var bestTime: TimeInterval?
    var isCompleted: Bool
    var createdAt: Date
    
    init(id: UUID = UUID(), title: String, type: PuzzleType, difficulty: DifficultyLevel, description: String, data: PuzzleData, timeLimit: TimeInterval? = nil) {
        self.id = id
        self.title = title
        self.type = type
        self.difficulty = difficulty
        self.description = description
        self.data = data
        self.timeLimit = timeLimit
        self.bestTime = nil
        self.isCompleted = false
        self.createdAt = Date()
    }
}

enum PuzzleType: String, Codable, CaseIterable {
    case logic = "Logic"
    case memory = "Memory"
    case pattern = "Pattern"
    case wordPuzzle = "Word Puzzle"
    case mathPuzzle = "Math Puzzle"
    case spatial = "Spatial"
    
    var icon: String {
        switch self {
        case .logic: return "brain.head.profile"
        case .memory: return "memorychip"
        case .pattern: return "square.grid.3x3.fill"
        case .wordPuzzle: return "textformat"
        case .mathPuzzle: return "number.square.fill"
        case .spatial: return "cube.fill"
        }
    }
}

enum PuzzleData: Codable {
    case memoryGame(cards: [MemoryCard])
    case logicGrid(grid: [[Int]])
    case patternSequence(sequence: [Int], options: [Int])
    case wordScramble(word: String, scrambled: String, hints: [String])
    case mathChallenge(equation: String, answer: Double)
    
    enum CodingKeys: String, CodingKey {
        case type
        case cards
        case grid
        case sequence
        case options
        case word
        case scrambled
        case hints
        case equation
        case answer
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        
        switch type {
        case "memoryGame":
            let cards = try container.decode([MemoryCard].self, forKey: .cards)
            self = .memoryGame(cards: cards)
        case "logicGrid":
            let grid = try container.decode([[Int]].self, forKey: .grid)
            self = .logicGrid(grid: grid)
        case "patternSequence":
            let sequence = try container.decode([Int].self, forKey: .sequence)
            let options = try container.decode([Int].self, forKey: .options)
            self = .patternSequence(sequence: sequence, options: options)
        case "wordScramble":
            let word = try container.decode(String.self, forKey: .word)
            let scrambled = try container.decode(String.self, forKey: .scrambled)
            let hints = try container.decode([String].self, forKey: .hints)
            self = .wordScramble(word: word, scrambled: scrambled, hints: hints)
        case "mathChallenge":
            let equation = try container.decode(String.self, forKey: .equation)
            let answer = try container.decode(Double.self, forKey: .answer)
            self = .mathChallenge(equation: equation, answer: answer)
        default:
            throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Unknown puzzle type")
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .memoryGame(let cards):
            try container.encode("memoryGame", forKey: .type)
            try container.encode(cards, forKey: .cards)
        case .logicGrid(let grid):
            try container.encode("logicGrid", forKey: .type)
            try container.encode(grid, forKey: .grid)
        case .patternSequence(let sequence, let options):
            try container.encode("patternSequence", forKey: .type)
            try container.encode(sequence, forKey: .sequence)
            try container.encode(options, forKey: .options)
        case .wordScramble(let word, let scrambled, let hints):
            try container.encode("wordScramble", forKey: .type)
            try container.encode(word, forKey: .word)
            try container.encode(scrambled, forKey: .scrambled)
            try container.encode(hints, forKey: .hints)
        case .mathChallenge(let equation, let answer):
            try container.encode("mathChallenge", forKey: .type)
            try container.encode(equation, forKey: .equation)
            try container.encode(answer, forKey: .answer)
        }
    }
}

struct MemoryCard: Identifiable, Codable {
    let id: UUID
    var emoji: String
    var isMatched: Bool
    var isFaceUp: Bool
    
    init(id: UUID = UUID(), emoji: String) {
        self.id = id
        self.emoji = emoji
        self.isMatched = false
        self.isFaceUp = false
    }
}
