//
//  QuizzesView.swift
//  MindSpark
//
//  Created on 2026-01-25.
//

import SwiftUI

struct QuizzesView: View {
    @EnvironmentObject var appState: AppStateManager
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var viewModel = QuizViewModel()
    @State private var selectedCategory: QuizCategory?
    @State private var selectedDifficulty: DifficultyLevel?
    @State private var showingQuizDetail: Quiz?
    
    var filteredQuizzes: [Quiz] {
        viewModel.availableQuizzes.filter { quiz in
            (selectedCategory == nil || quiz.category == selectedCategory) &&
            (selectedDifficulty == nil || quiz.difficulty == selectedDifficulty)
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Filters
                    VStack(spacing: 15) {
                        // Category Filter
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                FilterChip(
                                    title: "All",
                                    isSelected: selectedCategory == nil
                                ) {
                                    selectedCategory = nil
                                }
                                
                                ForEach(QuizCategory.allCases, id: \.self) { category in
                                    FilterChip(
                                        title: category.rawValue,
                                        icon: category.icon,
                                        isSelected: selectedCategory == category
                                    ) {
                                        selectedCategory = category
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        // Difficulty Filter
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                FilterChip(
                                    title: "All Levels",
                                    isSelected: selectedDifficulty == nil
                                ) {
                                    selectedDifficulty = nil
                                }
                                
                                ForEach(DifficultyLevel.allCases, id: \.self) { difficulty in
                                    FilterChip(
                                        title: difficulty.rawValue,
                                        isSelected: selectedDifficulty == difficulty
                                    ) {
                                        selectedDifficulty = difficulty
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.top)
                    
                    // Quiz Grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                        ForEach(filteredQuizzes) { quiz in
                            QuizCard(quiz: quiz)
                                .onTapGesture {
                                    showingQuizDetail = quiz
                                }
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 30)
                }
            }
            .background(themeManager.backgroundColor.ignoresSafeArea())
            .navigationTitle("Quizzes")
            .navigationBarTitleDisplayMode(.large)
            .sheet(item: $showingQuizDetail) { quiz in
                QuizDetailView(quiz: quiz, viewModel: viewModel)
            }
        }
    }
}

struct QuizCard: View {
    @EnvironmentObject var themeManager: ThemeManager
    let quiz: Quiz
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Category Icon
            ZStack {
                Circle()
                    .fill(ThemeManager.accentYellow.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: quiz.category.icon)
                    .font(.system(size: 24))
                    .foregroundColor(ThemeManager.accentYellow)
            }
            
            Text(quiz.title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(themeManager.textPrimary)
                .lineLimit(2)
            
            HStack {
                DifficultyBadge(difficulty: quiz.difficulty)
                
                Spacer()
                
                Text("\(quiz.questions.count) Q")
                    .font(.system(size: 12))
                    .foregroundColor(themeManager.textSecondary)
            }
        }
        .padding()
        .frame(height: 160)
        .background(themeManager.cardColor)
        .cornerRadius(20)
    }
}

struct DifficultyBadge: View {
    let difficulty: DifficultyLevel
    
    var badgeColor: Color {
        switch difficulty {
        case .easy: return .green
        case .medium: return .orange
        case .hard: return .red
        case .expert: return .purple
        }
    }
    
    var body: some View {
        Text(difficulty.rawValue)
            .font(.system(size: 10, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(badgeColor)
            .cornerRadius(6)
    }
}

struct FilterChip: View {
    @EnvironmentObject var themeManager: ThemeManager
    let title: String
    var icon: String?
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 14))
                }
                
                Text(title)
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundColor(isSelected ? .black : themeManager.textPrimary)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isSelected ? ThemeManager.accentYellow : themeManager.cardColor)
            .cornerRadius(20)
        }
    }
}

struct QuizDetailView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    let quiz: Quiz
    @ObservedObject var viewModel: QuizViewModel
    @State private var showingQuizSession = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 25) {
                    // Header
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            Image(systemName: quiz.category.icon)
                                .font(.system(size: 40))
                                .foregroundColor(ThemeManager.accentYellow)
                            
                            Spacer()
                            
                            DifficultyBadge(difficulty: quiz.difficulty)
                        }
                        
                        Text(quiz.title)
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(themeManager.textPrimary)
                        
                        HStack(spacing: 20) {
                            InfoItem(icon: "questionmark.circle", text: "\(quiz.questions.count) Questions")
                            
                            if let timeLimit = quiz.timeLimit {
                                InfoItem(icon: "clock", text: "\(Int(timeLimit/60)) min")
                            }
                            
                            InfoItem(icon: "folder", text: quiz.category.rawValue)
                        }
                    }
                    .padding()
                    .background(themeManager.cardColor)
                    .cornerRadius(20)
                    
                    // Questions Preview
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Questions")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(themeManager.textPrimary)
                        
                        ForEach(Array(quiz.questions.prefix(3).enumerated()), id: \.element.id) { index, question in
                            HStack(alignment: .top, spacing: 12) {
                                Text("\(index + 1)")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(ThemeManager.accentYellow)
                                    .frame(width: 24, height: 24)
                                    .background(ThemeManager.accentYellow.opacity(0.2))
                                    .cornerRadius(12)
                                
                                Text(question.text)
                                    .font(.system(size: 14))
                                    .foregroundColor(themeManager.textPrimary)
                            }
                            .padding()
                            .background(themeManager.cardColor)
                            .cornerRadius(12)
                        }
                        
                        if quiz.questions.count > 3 {
                            Text("+ \(quiz.questions.count - 3) more questions")
                                .font(.system(size: 14))
                                .foregroundColor(themeManager.textSecondary)
                                .padding(.leading)
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
                        showingQuizSession = true
                    }) {
                        HStack {
                            Image(systemName: "play.fill")
                            Text("Start Quiz")
                                .font(.system(size: 18, weight: .semibold))
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(ThemeManager.accentYellow)
                        .cornerRadius(16)
                    }
                    .padding()
                }
            )
            .fullScreenCover(isPresented: $showingQuizSession) {
                QuizSessionView(quiz: quiz, viewModel: viewModel)
            }
        }
    }
}

struct InfoItem: View {
    @EnvironmentObject var themeManager: ThemeManager
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(themeManager.textSecondary)
            
            Text(text)
                .font(.system(size: 12))
                .foregroundColor(themeManager.textSecondary)
        }
    }
}
