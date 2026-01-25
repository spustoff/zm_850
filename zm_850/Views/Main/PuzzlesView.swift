//
//  PuzzlesView.swift
//  MindSpark
//
//  Created on 2026-01-25.
//

import SwiftUI

struct PuzzlesView: View {
    @EnvironmentObject var appState: AppStateManager
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var viewModel = PuzzleViewModel()
    @State private var selectedType: PuzzleType?
    @State private var selectedPuzzle: Puzzle?
    
    var filteredPuzzles: [Puzzle] {
        if let type = selectedType {
            return viewModel.availablePuzzles.filter { $0.type == type }
        }
        return viewModel.availablePuzzles
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Type Filter
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            FilterChip(
                                title: "All",
                                isSelected: selectedType == nil
                            ) {
                                selectedType = nil
                            }
                            
                            ForEach(PuzzleType.allCases, id: \.self) { type in
                                FilterChip(
                                    title: type.rawValue,
                                    icon: type.icon,
                                    isSelected: selectedType == type
                                ) {
                                    selectedType = type
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.top)
                    
                    // Puzzles List
                    LazyVStack(spacing: 15) {
                        ForEach(filteredPuzzles) { puzzle in
                            PuzzleCard(puzzle: puzzle)
                                .onTapGesture {
                                    selectedPuzzle = puzzle
                                }
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 30)
                }
            }
            .background(themeManager.backgroundColor.ignoresSafeArea())
            .navigationTitle("Puzzles")
            .navigationBarTitleDisplayMode(.large)
            .sheet(item: $selectedPuzzle) { puzzle in
                PuzzleDetailView(puzzle: puzzle, viewModel: viewModel)
            }
        }
    }
}

struct PuzzleCard: View {
    @EnvironmentObject var themeManager: ThemeManager
    let puzzle: Puzzle
    
    var body: some View {
        HStack(spacing: 15) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(ThemeManager.accentBlue.opacity(0.2))
                    .frame(width: 70, height: 70)
                
                Image(systemName: puzzle.type.icon)
                    .font(.system(size: 30))
                    .foregroundColor(ThemeManager.accentBlue)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(puzzle.title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(themeManager.textPrimary)
                
                Text(puzzle.description)
                    .font(.system(size: 14))
                    .foregroundColor(themeManager.textSecondary)
                    .lineLimit(2)
                
                HStack {
                    DifficultyBadge(difficulty: puzzle.difficulty)
                    
                    if puzzle.isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.system(size: 14))
                    }
                    
                    if let bestTime = puzzle.bestTime {
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                                .font(.system(size: 12))
                            Text(String(format: "%.1fs", bestTime))
                                .font(.system(size: 12))
                        }
                        .foregroundColor(themeManager.textSecondary)
                    }
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(themeManager.textSecondary)
        }
        .padding()
        .background(themeManager.cardColor)
        .cornerRadius(20)
    }
}

struct PuzzleDetailView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appState: AppStateManager
    @EnvironmentObject var themeManager: ThemeManager
    let puzzle: Puzzle
    @ObservedObject var viewModel: PuzzleViewModel
    @State private var showingPuzzleSession = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 25) {
                    // Header
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            Image(systemName: puzzle.type.icon)
                                .font(.system(size: 40))
                                .foregroundColor(ThemeManager.accentBlue)
                            
                            Spacer()
                            
                            DifficultyBadge(difficulty: puzzle.difficulty)
                        }
                        
                        Text(puzzle.title)
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(themeManager.textPrimary)
                        
                        Text(puzzle.description)
                            .font(.system(size: 16))
                            .foregroundColor(themeManager.textSecondary)
                        
                        HStack(spacing: 20) {
                            InfoItem(icon: "brain.head.profile", text: puzzle.type.rawValue)
                            
                            if let timeLimit = puzzle.timeLimit {
                                InfoItem(icon: "clock", text: "\(Int(timeLimit)) sec")
                            }
                            
                            if puzzle.isCompleted {
                                InfoItem(icon: "checkmark.circle.fill", text: "Completed")
                            }
                        }
                    }
                    .padding()
                    .background(themeManager.cardColor)
                    .cornerRadius(20)
                    
                    // Best Score
                    if let bestTime = puzzle.bestTime {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Your Best Time")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(themeManager.textPrimary)
                            
                            HStack {
                                Image(systemName: "trophy.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(ThemeManager.accentYellow)
                                
                                Text(String(format: "%.2f seconds", bestTime))
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(themeManager.textPrimary)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(themeManager.cardColor)
                            .cornerRadius(12)
                        }
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding()
            }
            .background(themeManager.backgroundColor.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(themeManager.textPrimary)
                }
            }
            .overlay(
                VStack {
                    Spacer()
                    
                    Button(action: {
                        showingPuzzleSession = true
                    }) {
                        HStack {
                            Image(systemName: "play.fill")
                            Text(puzzle.isCompleted ? "Play Again" : "Start Puzzle")
                                .font(.system(size: 18, weight: .semibold))
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(ThemeManager.accentBlue)
                        .cornerRadius(16)
                    }
                    .padding()
                }
            )
            .fullScreenCover(isPresented: $showingPuzzleSession) {
                PuzzleSessionView(puzzle: puzzle, viewModel: viewModel, appState: appState)
            }
        }
    }
}

struct PuzzleSessionView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    let puzzle: Puzzle
    @ObservedObject var viewModel: PuzzleViewModel
    @ObservedObject var appState: AppStateManager
    @State private var showExitAlert = false
    
    var body: some View {
        ZStack {
            themeManager.backgroundColor.ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header
                HStack {
                    Button(action: {
                        showExitAlert = true
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(themeManager.textPrimary)
                            .frame(width: 40, height: 40)
                            .background(themeManager.cardColor)
                            .cornerRadius(20)
                    }
                    
                    Spacer()
                    
                    // Timer
                    HStack(spacing: 6) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 14))
                        Text(String(format: "%.1f", viewModel.elapsedTime))
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(themeManager.textPrimary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(themeManager.cardColor)
                    .cornerRadius(20)
                }
                .padding()
                
                // Puzzle Content based on type
                switch puzzle.data {
                case .memoryGame(let cards):
                    MemoryGameView(cards: cards, onComplete: {
                        handlePuzzleCompletion(success: true)
                    })
                    
                case .wordScramble(let word, let scrambled, let hints):
                    WordScrambleView(
                        word: word,
                        scrambled: scrambled,
                        hints: hints,
                        onComplete: {
                            handlePuzzleCompletion(success: true)
                        }
                    )
                    
                default:
                    Text("Puzzle type not yet implemented")
                        .foregroundColor(themeManager.textSecondary)
                }
                
                Spacer()
            }
        }
        .onAppear {
            viewModel.startPuzzle(puzzle)
        }
        .alert("Exit Puzzle?", isPresented: $showExitAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Exit", role: .destructive) {
                viewModel.resetPuzzle()
                dismiss()
            }
        } message: {
            Text("Your progress will be lost.")
        }
    }
    
    private func handlePuzzleCompletion(success: Bool) {
        viewModel.completePuzzle(success: success)
        
        if success {
            // Award points
            let basePoints = 50
            let difficultyMultiplier: Int
            switch puzzle.difficulty {
            case .easy: difficultyMultiplier = 1
            case .medium: difficultyMultiplier = 2
            case .hard: difficultyMultiplier = 3
            case .expert: difficultyMultiplier = 4
            }
            
            appState.addPoints(basePoints * difficultyMultiplier)
            appState.userProfile.statistics.totalPuzzlesSolved += 1
            appState.saveProfile()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            dismiss()
        }
    }
}

// Simple implementations of puzzle game views
struct MemoryGameView: View {
    @State private var cards: [MemoryCard]
    @State private var flippedIndices: Set<Int> = []
    @State private var matchedPairs: Set<String> = []
    let onComplete: () -> Void
    
    init(cards: [MemoryCard], onComplete: @escaping () -> Void) {
        _cards = State(initialValue: cards)
        self.onComplete = onComplete
    }
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 15) {
            ForEach(Array(cards.enumerated()), id: \.element.id) { index, card in
                MemoryCardView(
                    card: card,
                    isFlipped: flippedIndices.contains(index) || matchedPairs.contains(card.emoji)
                )
                .onTapGesture {
                    handleCardTap(at: index)
                }
            }
        }
        .padding()
    }
    
    private func handleCardTap(at index: Int) {
        guard flippedIndices.count < 2,
              !flippedIndices.contains(index),
              !matchedPairs.contains(cards[index].emoji) else { return }
        
        flippedIndices.insert(index)
        
        if flippedIndices.count == 2 {
            let indices = Array(flippedIndices)
            if cards[indices[0]].emoji == cards[indices[1]].emoji {
                matchedPairs.insert(cards[indices[0]].emoji)
                flippedIndices.removeAll()
                
                if matchedPairs.count == cards.count / 2 {
                    onComplete()
                }
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    flippedIndices.removeAll()
                }
            }
        }
    }
}

struct MemoryCardView: View {
    @EnvironmentObject var themeManager: ThemeManager
    let card: MemoryCard
    let isFlipped: Bool
    
    var body: some View {
        ZStack {
            if isFlipped {
                RoundedRectangle(cornerRadius: 12)
                    .fill(ThemeManager.accentBlue)
                
                Text(card.emoji)
                    .font(.system(size: 40))
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(themeManager.cardColor)
                
                Image(systemName: "questionmark")
                    .font(.system(size: 30))
                    .foregroundColor(themeManager.textSecondary)
            }
        }
        .frame(width: 80, height: 80)
        .rotation3DEffect(
            .degrees(isFlipped ? 0 : 180),
            axis: (x: 0, y: 1, z: 0)
        )
        .animation(.spring(), value: isFlipped)
    }
}

struct WordScrambleView: View {
    @EnvironmentObject var themeManager: ThemeManager
    let word: String
    let scrambled: String
    let hints: [String]
    let onComplete: () -> Void
    
    @State private var userAnswer = ""
    @State private var showHint = false
    @State private var currentHintIndex = 0
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Unscramble the word")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(themeManager.textPrimary)
            
            Text(scrambled)
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(ThemeManager.accentYellow)
                .tracking(8)
            
            TextField("Your answer", text: $userAnswer)
                .font(.system(size: 24))
                .foregroundColor(themeManager.textPrimary)
                .multilineTextAlignment(.center)
                .padding()
                .background(themeManager.cardColor)
                .cornerRadius(12)
                .textInputAutocapitalization(.characters)
                .onChange(of: userAnswer) { newValue in
                    if newValue.uppercased() == word.uppercased() {
                        onComplete()
                    }
                }
            
            if showHint && currentHintIndex < hints.count {
                Text("💡 \(hints[currentHintIndex])")
                    .font(.system(size: 16))
                    .foregroundColor(ThemeManager.accentBlue)
                    .padding()
                    .background(themeManager.cardColor)
                    .cornerRadius(12)
            }
            
            Button(action: {
                if !showHint {
                    showHint = true
                } else if currentHintIndex < hints.count - 1 {
                    currentHintIndex += 1
                }
            }) {
                Text(showHint ? "Next Hint" : "Show Hint")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(themeManager.textPrimary)
                    .padding()
                    .background(themeManager.cardColor)
                    .cornerRadius(12)
            }
            .disabled(showHint && currentHintIndex >= hints.count - 1)
        }
        .padding()
    }
}
