//
//  QuizViewModel.swift
//  MindSpark
//
//  Created on 2026-01-25.
//

import Foundation
import Combine

class QuizViewModel: ObservableObject {
    @Published var availableQuizzes: [Quiz] = []
    @Published var currentQuiz: Quiz?
    @Published var currentQuestionIndex = 0
    @Published var selectedAnswers: [Int] = []
    @Published var score = 0
    @Published var isQuizActive = false
    @Published var quizCompleted = false
    @Published var timeRemaining: TimeInterval = 0
    
    private var timer: Timer?
    private var startTime: Date?
    
    init() {
        loadQuizzes()
    }
    
    func loadQuizzes() {
        // Generate sample quizzes
        availableQuizzes = generateSampleQuizzes()
    }
    
    func startQuiz(_ quiz: Quiz) {
        currentQuiz = quiz
        currentQuestionIndex = 0
        selectedAnswers = Array(repeating: -1, count: quiz.questions.count)
        score = 0
        isQuizActive = true
        quizCompleted = false
        startTime = Date()
        
        if let timeLimit = quiz.timeLimit {
            timeRemaining = timeLimit
            startTimer()
        }
    }
    
    func selectAnswer(_ answerIndex: Int) {
        guard let quiz = currentQuiz, currentQuestionIndex < quiz.questions.count else { return }
        selectedAnswers[currentQuestionIndex] = answerIndex
    }
    
    func nextQuestion() {
        guard let quiz = currentQuiz else { return }
        
        if currentQuestionIndex < quiz.questions.count - 1 {
            currentQuestionIndex += 1
        } else {
            completeQuiz()
        }
    }
    
    func previousQuestion() {
        if currentQuestionIndex > 0 {
            currentQuestionIndex -= 1
        }
    }
    
    private func completeQuiz() {
        guard let quiz = currentQuiz else { return }
        
        stopTimer()
        
        // Calculate score
        var correctCount = 0
        for (index, question) in quiz.questions.enumerated() {
            if selectedAnswers[index] == question.correctAnswerIndex {
                correctCount += 1
            }
        }
        
        score = correctCount
        quizCompleted = true
        isQuizActive = false
        
        // Calculate final score percentage
        let scorePercentage = Double(correctCount) / Double(quiz.questions.count) * 100
        let timeTaken = Date().timeIntervalSince(startTime ?? Date())
        
        // Save result
        let result = QuizResult(
            quizId: quiz.id,
            quizTitle: quiz.title,
            score: scorePercentage,
            correctAnswers: correctCount,
            totalQuestions: quiz.questions.count,
            timeTaken: timeTaken
        )
        LocalStorageService.shared.saveQuizResult(result)
    }
    
    func resetQuiz() {
        currentQuiz = nil
        currentQuestionIndex = 0
        selectedAnswers = []
        score = 0
        isQuizActive = false
        quizCompleted = false
        stopTimer()
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.completeQuiz()
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    // MARK: - Sample Data Generation
    
    private func generateSampleQuizzes() -> [Quiz] {
        var quizzes: [Quiz] = []
        
        // Science Quiz
        let scienceQuestions = [
            Question(text: "What is the chemical symbol for gold?", options: ["Au", "Ag", "Fe", "Cu"], correctAnswerIndex: 0, explanation: "Au comes from the Latin word 'aurum' meaning gold."),
            Question(text: "What planet is known as the Red Planet?", options: ["Venus", "Mars", "Jupiter", "Saturn"], correctAnswerIndex: 1, explanation: "Mars appears red due to iron oxide on its surface."),
            Question(text: "What is the speed of light?", options: ["299,792 km/s", "150,000 km/s", "400,000 km/s", "250,000 km/s"], correctAnswerIndex: 0, explanation: "Light travels at approximately 299,792 kilometers per second in a vacuum."),
            Question(text: "How many bones are in the adult human body?", options: ["196", "206", "216", "186"], correctAnswerIndex: 1, explanation: "An adult human has 206 bones."),
            Question(text: "What is the most abundant gas in Earth's atmosphere?", options: ["Oxygen", "Carbon Dioxide", "Nitrogen", "Hydrogen"], correctAnswerIndex: 2, explanation: "Nitrogen makes up about 78% of Earth's atmosphere.")
        ]
        
        quizzes.append(Quiz(title: "Science Fundamentals", category: .science, difficulty: .easy, questions: scienceQuestions))
        
        // History Quiz
        let historyQuestions = [
            Question(text: "In which year did World War II end?", options: ["1943", "1944", "1945", "1946"], correctAnswerIndex: 2, explanation: "World War II ended in 1945."),
            Question(text: "Who was the first President of the United States?", options: ["Thomas Jefferson", "George Washington", "John Adams", "Benjamin Franklin"], correctAnswerIndex: 1, explanation: "George Washington served as the first U.S. President from 1789 to 1797."),
            Question(text: "What year did the Titanic sink?", options: ["1910", "1911", "1912", "1913"], correctAnswerIndex: 2, explanation: "The Titanic sank on April 15, 1912."),
            Question(text: "Who painted the Mona Lisa?", options: ["Michelangelo", "Leonardo da Vinci", "Raphael", "Donatello"], correctAnswerIndex: 1, explanation: "Leonardo da Vinci painted the Mona Lisa in the early 16th century.")
        ]
        
        quizzes.append(Quiz(title: "History 101", category: .history, difficulty: .medium, questions: historyQuestions))
        
        // Technology Quiz
        let techQuestions = [
            Question(text: "What does CPU stand for?", options: ["Central Processing Unit", "Computer Personal Unit", "Central Program Utility", "Computer Processing Utility"], correctAnswerIndex: 0),
            Question(text: "Who is the founder of Apple Inc.?", options: ["Bill Gates", "Steve Jobs", "Mark Zuckerberg", "Elon Musk"], correctAnswerIndex: 1),
            Question(text: "What year was the first iPhone released?", options: ["2005", "2006", "2007", "2008"], correctAnswerIndex: 2),
            Question(text: "What does HTML stand for?", options: ["Hyper Text Markup Language", "High Tech Modern Language", "Home Tool Markup Language", "Hyperlinks and Text Markup Language"], correctAnswerIndex: 0),
            Question(text: "Which company developed the Android operating system?", options: ["Apple", "Microsoft", "Google", "Samsung"], correctAnswerIndex: 2)
        ]
        
        quizzes.append(Quiz(title: "Tech Trivia", category: .technology, difficulty: .medium, questions: techQuestions))
        
        // Mathematics Quiz
        let mathQuestions = [
            Question(text: "What is the square root of 144?", options: ["10", "11", "12", "13"], correctAnswerIndex: 2),
            Question(text: "What is 15% of 200?", options: ["25", "30", "35", "40"], correctAnswerIndex: 1),
            Question(text: "If x + 5 = 12, what is x?", options: ["5", "6", "7", "8"], correctAnswerIndex: 2),
            Question(text: "What is the value of π (pi) to two decimal places?", options: ["3.12", "3.14", "3.16", "3.18"], correctAnswerIndex: 1)
        ]
        
        quizzes.append(Quiz(title: "Math Basics", category: .mathematics, difficulty: .easy, questions: mathQuestions))
        
        // Geography Quiz
        let geoQuestions = [
            Question(text: "What is the capital of France?", options: ["London", "Berlin", "Paris", "Madrid"], correctAnswerIndex: 2),
            Question(text: "Which is the largest ocean?", options: ["Atlantic", "Indian", "Arctic", "Pacific"], correctAnswerIndex: 3),
            Question(text: "How many continents are there?", options: ["5", "6", "7", "8"], correctAnswerIndex: 2),
            Question(text: "What is the tallest mountain in the world?", options: ["K2", "Mount Everest", "Kilimanjaro", "Denali"], correctAnswerIndex: 1),
            Question(text: "Which country has the largest population?", options: ["India", "United States", "China", "Indonesia"], correctAnswerIndex: 2)
        ]
        
        quizzes.append(Quiz(title: "World Geography", category: .geography, difficulty: .easy, questions: geoQuestions))
        
        return quizzes
    }
}
