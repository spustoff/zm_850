//
//  PuzzleViewModel.swift
//  MindSpark
//
//  Created on 2026-01-25.
//

import Foundation
import Combine

class PuzzleViewModel: ObservableObject {
    @Published var availablePuzzles: [Puzzle] = []
    @Published var currentPuzzle: Puzzle?
    @Published var puzzleState: PuzzleState = .idle
    @Published var elapsedTime: TimeInterval = 0
    
    private var timer: Timer?
    private var startTime: Date?
    
    init() {
        loadPuzzles()
    }
    
    func loadPuzzles() {
        // Check for saved progress
        let savedPuzzles = LocalStorageService.shared.loadPuzzleProgress()
        
        if !savedPuzzles.isEmpty {
            availablePuzzles = savedPuzzles
        } else {
            availablePuzzles = generateSamplePuzzles()
            savePuzzles()
        }
    }
    
    func startPuzzle(_ puzzle: Puzzle) {
        currentPuzzle = puzzle
        puzzleState = .active
        startTime = Date()
        elapsedTime = 0
        startTimer()
    }
    
    func completePuzzle(success: Bool) {
        guard var puzzle = currentPuzzle else { return }
        
        stopTimer()
        
        if success {
            puzzle.isCompleted = true
            
            let finalTime = Date().timeIntervalSince(startTime ?? Date())
            if puzzle.bestTime == nil || finalTime < puzzle.bestTime! {
                puzzle.bestTime = finalTime
            }
            
            // Update in available puzzles
            if let index = availablePuzzles.firstIndex(where: { $0.id == puzzle.id }) {
                availablePuzzles[index] = puzzle
            }
            
            savePuzzles()
            puzzleState = .completed
        } else {
            puzzleState = .failed
        }
    }
    
    func resetPuzzle() {
        currentPuzzle = nil
        puzzleState = .idle
        elapsedTime = 0
        stopTimer()
    }
    
    private func savePuzzles() {
        LocalStorageService.shared.savePuzzleProgress(availablePuzzles)
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, let startTime = self.startTime else { return }
            self.elapsedTime = Date().timeIntervalSince(startTime)
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    // MARK: - Sample Puzzles Generation
    
    private func generateSamplePuzzles() -> [Puzzle] {
        var puzzles: [Puzzle] = []
        
        // Memory Game
        let memoryEmojis = ["🎮", "🎯", "🎨", "🎭", "🎪", "🎸"]
        var memoryCards: [MemoryCard] = []
        for emoji in memoryEmojis {
            memoryCards.append(MemoryCard(emoji: emoji))
            memoryCards.append(MemoryCard(emoji: emoji))
        }
        memoryCards.shuffle()
        
        puzzles.append(Puzzle(
            title: "Memory Match",
            type: .memory,
            difficulty: .easy,
            description: "Match all the pairs of cards",
            data: .memoryGame(cards: memoryCards),
            timeLimit: 120
        ))
        
        // Logic Grid
        let logicGrid: [[Int]] = [
            [1, 2, 3],
            [4, 5, 6],
            [7, 8, 0]
        ]
        
        puzzles.append(Puzzle(
            title: "Number Slide",
            type: .logic,
            difficulty: .medium,
            description: "Arrange numbers in order by sliding tiles",
            data: .logicGrid(grid: logicGrid),
            timeLimit: 180
        ))
        
        // Pattern Sequence
        puzzles.append(Puzzle(
            title: "Pattern Master",
            type: .pattern,
            difficulty: .medium,
            description: "Find the next number in the sequence: 2, 4, 8, 16, ?",
            data: .patternSequence(sequence: [2, 4, 8, 16], options: [24, 32, 20, 28]),
            timeLimit: 60
        ))
        
        // Word Scramble
        puzzles.append(Puzzle(
            title: "Word Unscrambler",
            type: .wordPuzzle,
            difficulty: .easy,
            description: "Unscramble the word",
            data: .wordScramble(
                word: "CHALLENGE",
                scrambled: "EGNELLAHC",
                hints: ["It means a difficult task", "9 letters", "Starts with C"]
            ),
            timeLimit: 90
        ))
        
        // Math Challenge
        puzzles.append(Puzzle(
            title: "Quick Math",
            type: .mathPuzzle,
            difficulty: .hard,
            description: "Solve: (15 × 4) + (36 ÷ 3) - 8",
            data: .mathChallenge(equation: "(15 × 4) + (36 ÷ 3) - 8", answer: 64),
            timeLimit: 45
        ))
        
        // More memory games with different difficulty
        let hardMemoryEmojis = ["🚀", "🛸", "🌟", "⭐", "💫", "✨", "🌙", "☀️"]
        var hardMemoryCards: [MemoryCard] = []
        for emoji in hardMemoryEmojis {
            hardMemoryCards.append(MemoryCard(emoji: emoji))
            hardMemoryCards.append(MemoryCard(emoji: emoji))
        }
        hardMemoryCards.shuffle()
        
        puzzles.append(Puzzle(
            title: "Cosmic Memory",
            type: .memory,
            difficulty: .hard,
            description: "Match all space-themed pairs",
            data: .memoryGame(cards: hardMemoryCards),
            timeLimit: 150
        ))
        
        return puzzles
    }
}

enum PuzzleState {
    case idle
    case active
    case completed
    case failed
}
