//
//  QuizSessionView.swift
//  MindSpark
//
//  Created on 2026-01-25.
//

import SwiftUI

struct QuizSessionView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appState: AppStateManager
    @EnvironmentObject var themeManager: ThemeManager
    let quiz: Quiz
    @ObservedObject var viewModel: QuizViewModel
    @State private var showingResults = false
    @State private var showExitAlert = false
    
    var currentQuestion: Question? {
        guard viewModel.currentQuestionIndex < quiz.questions.count else { return nil }
        return quiz.questions[viewModel.currentQuestionIndex]
    }
    
    var body: some View {
        ZStack {
            themeManager.backgroundColor.ignoresSafeArea()
            
            if !viewModel.quizCompleted {
                VStack(spacing: 0) {
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
                        
                        // Progress
                        Text("\(viewModel.currentQuestionIndex + 1)/\(quiz.questions.count)")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(themeManager.textPrimary)
                        
                        Spacer()
                        
                        // Timer (if applicable)
                        if quiz.timeLimit != nil {
                            HStack(spacing: 6) {
                                Image(systemName: "clock.fill")
                                    .font(.system(size: 14))
                                Text(timeString(from: viewModel.timeRemaining))
                                    .font(.system(size: 14, weight: .semibold))
                            }
                            .foregroundColor(viewModel.timeRemaining < 30 ? .red : themeManager.textPrimary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(themeManager.cardColor)
                            .cornerRadius(20)
                        }
                    }
                    .padding()
                    
                    // Progress Bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 4)
                            
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        colors: [ThemeManager.accentYellow, ThemeManager.accentBlue],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width * CGFloat(viewModel.currentQuestionIndex) / CGFloat(quiz.questions.count), height: 4)
                        }
                    }
                    .frame(height: 4)
                    .padding(.horizontal)
                    
                    // Question Content
                    if let question = currentQuestion {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 30) {
                                // Question Text
                                Text(question.text)
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(themeManager.textPrimary)
                                    .padding()
                                
                    // Answer Options
                        VStack(spacing: 15) {
                            ForEach(0..<question.options.count, id: \.self) { index in
                                AnswerOption(
                                    text: question.options[index],
                                    index: index,
                                    isSelected: viewModel.currentQuestionIndex < viewModel.selectedAnswers.count && viewModel.selectedAnswers[viewModel.currentQuestionIndex] == index,
                                    action: {
                                        viewModel.selectAnswer(index)
                                    }
                                )
                            }
                        }
                        .padding(.horizontal)
                            }
                            .padding(.top, 30)
                        }
                        
                        // Navigation Buttons
                        HStack(spacing: 15) {
                            if viewModel.currentQuestionIndex > 0 {
                                Button(action: {
                                    viewModel.previousQuestion()
                                }) {
                                    HStack {
                                        Image(systemName: "arrow.left")
                                        Text("Previous")
                                    }
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(themeManager.textPrimary)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(themeManager.cardColor)
                                    .cornerRadius(16)
                                }
                            }
                            
                            Button(action: {
                                if viewModel.currentQuestionIndex < quiz.questions.count - 1 {
                                    viewModel.nextQuestion()
                                } else {
                                    viewModel.nextQuestion() // This will complete the quiz
                                }
                            }) {
                                HStack {
                                    Text(viewModel.currentQuestionIndex < quiz.questions.count - 1 ? "Next" : "Finish")
                                    Image(systemName: viewModel.currentQuestionIndex < quiz.questions.count - 1 ? "arrow.right" : "checkmark")
                                }
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    (viewModel.currentQuestionIndex < viewModel.selectedAnswers.count && viewModel.selectedAnswers[viewModel.currentQuestionIndex] >= 0) ?
                                    ThemeManager.accentYellow : Color.gray.opacity(0.3)
                                )
                                .cornerRadius(16)
                            }
                            .disabled(viewModel.currentQuestionIndex >= viewModel.selectedAnswers.count || viewModel.selectedAnswers[viewModel.currentQuestionIndex] < 0)
                        }
                        .padding()
                    }
                }
            } else {
                QuizResultsView(
                    quiz: quiz,
                    score: viewModel.score,
                    totalQuestions: quiz.questions.count,
                    selectedAnswers: viewModel.selectedAnswers
                ) {
                    // Award points
                    let percentage = Double(viewModel.score) / Double(quiz.questions.count)
                    let points = Int(percentage * 100)
                    appState.addPoints(points)
                    
                    // Update statistics
                    appState.userProfile.statistics.updateQuizStats(
                        score: percentage * 100,
                        isPerfect: viewModel.score == quiz.questions.count
                    )
                    appState.saveProfile()
                    
                    viewModel.resetQuiz()
                    dismiss()
                }
            }
        }
        .onAppear {
            viewModel.startQuiz(quiz)
        }
        .alert("Exit Quiz?", isPresented: $showExitAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Exit", role: .destructive) {
                viewModel.resetQuiz()
                dismiss()
            }
        } message: {
            Text("Your progress will be lost.")
        }
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

struct AnswerOption: View {
    @EnvironmentObject var themeManager: ThemeManager
    let text: String
    let index: Int
    let isSelected: Bool
    let action: () -> Void
    
    let letters = ["A", "B", "C", "D"]
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                Text(letters[index])
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(isSelected ? .black : .white)
                    .frame(width: 40, height: 40)
                    .background(isSelected ? ThemeManager.accentYellow : themeManager.cardColor)
                    .cornerRadius(20)
                
                Text(text)
                    .font(.system(size: 16))
                    .foregroundColor(themeManager.textPrimary)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(ThemeManager.accentYellow)
                }
            }
            .padding()
            .background(
                Group {
                    if isSelected {
                        themeManager.cardColor.overlay(ThemeManager.accentYellow.opacity(0.1))
                    } else {
                        themeManager.cardColor
                    }
                }
            )
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? ThemeManager.accentYellow : Color.clear, lineWidth: 2)
            )
        }
    }
}

struct QuizResultsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    let quiz: Quiz
    let score: Int
    let totalQuestions: Int
    let selectedAnswers: [Int]
    let onDismiss: () -> Void
    
    var scorePercentage: Double {
        Double(score) / Double(totalQuestions) * 100
    }
    
    var performanceMessage: String {
        if scorePercentage == 100 {
            return "Perfect! 🎉"
        } else if scorePercentage >= 80 {
            return "Excellent! ⭐"
        } else if scorePercentage >= 60 {
            return "Good Job! 👍"
        } else if scorePercentage >= 40 {
            return "Keep Practicing! 📚"
        } else {
            return "Try Again! 💪"
        }
    }
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Score Circle
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 20)
                    .frame(width: 200, height: 200)
                
                Circle()
                    .trim(from: 0, to: scorePercentage / 100)
                    .stroke(
                        LinearGradient(
                            colors: [ThemeManager.accentYellow, ThemeManager.accentBlue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 20, lineCap: .round)
                    )
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(-90))
                
                VStack(spacing: 8) {
                    Text("\(Int(scorePercentage))%")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(themeManager.textPrimary)
                    
                    Text("\(score)/\(totalQuestions)")
                        .font(.system(size: 18))
                        .foregroundColor(themeManager.textSecondary)
                }
            }
            
            Text(performanceMessage)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(themeManager.textPrimary)
            
            // Stats
            HStack(spacing: 30) {
                VStack(spacing: 8) {
                    Text("\(score)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.green)
                    Text("Correct")
                        .font(.system(size: 14))
                        .foregroundColor(themeManager.textSecondary)
                }
                
                VStack(spacing: 8) {
                    Text("\(totalQuestions - score)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.red)
                    Text("Incorrect")
                        .font(.system(size: 14))
                        .foregroundColor(themeManager.textSecondary)
                }
                
                VStack(spacing: 8) {
                    Text("+\(Int(scorePercentage))")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(ThemeManager.accentYellow)
                    Text("Points")
                        .font(.system(size: 14))
                        .foregroundColor(themeManager.textSecondary)
                }
            }
            .padding()
            .background(themeManager.cardColor)
            .cornerRadius(20)
            
            Spacer()
            
            Button(action: onDismiss) {
                Text("Continue")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(ThemeManager.accentYellow)
                    .cornerRadius(16)
            }
            .padding(.horizontal)
            .padding(.bottom, 40)
        }
        .padding()
    }
}
