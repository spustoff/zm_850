//
//  ChallengeViewModel.swift
//  MindSpark
//
//  Created on 2026-01-25.
//

import Foundation
import Combine

class ChallengeViewModel: ObservableObject {
    @Published var dailyChallenges: [DailyChallenge] = []
    @Published var communityChallenges: [CommunityChallenge] = []
    
    init() {
        loadChallenges()
    }
    
    func loadChallenges() {
        // Check if we need to generate new daily challenges
        let savedChallenges = LocalStorageService.shared.loadDailyChallenges()
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Filter challenges for today
        let todaysChallenges = savedChallenges.filter { challenge in
            calendar.isDate(challenge.date, inSameDayAs: today)
        }
        
        if todaysChallenges.isEmpty {
            // Generate new daily challenges
            dailyChallenges = generateDailyChallenges()
            saveChallenges()
        } else {
            dailyChallenges = todaysChallenges
        }
        
        // Load community challenges
        loadCommunityChallenges()
    }
    
    func updateChallengeProgress(_ challengeId: UUID, progress: Int) {
        if let index = dailyChallenges.firstIndex(where: { $0.id == challengeId }) {
            dailyChallenges[index].currentProgress += progress
            
            if dailyChallenges[index].currentProgress >= dailyChallenges[index].targetValue {
                dailyChallenges[index].isCompleted = true
            }
            
            saveChallenges()
        }
    }
    
    func completeChallenge(_ challengeId: UUID) -> ChallengeReward? {
        if let index = dailyChallenges.firstIndex(where: { $0.id == challengeId }) {
            if !dailyChallenges[index].isCompleted {
                dailyChallenges[index].isCompleted = true
                saveChallenges()
                return dailyChallenges[index].reward
            }
        }
        return nil
    }
    
    private func saveChallenges() {
        LocalStorageService.shared.saveDailyChallenges(dailyChallenges)
    }
    
    private func loadCommunityChallenges() {
        // Generate sample community challenges
        communityChallenges = [
            CommunityChallenge(
                id: UUID(),
                title: "Weekend Warrior",
                description: "Complete 10 quizzes this weekend",
                participants: 1247,
                timeRemaining: 172800, // 48 hours
                reward: ChallengeReward(points: 500, badge: "🏆", title: "Weekend Champion")
            ),
            CommunityChallenge(
                id: UUID(),
                title: "Perfect Streak",
                description: "Get 5 perfect scores in a row",
                participants: 892,
                timeRemaining: 259200, // 72 hours
                reward: ChallengeReward(points: 750, badge: "⭐", title: "Perfectionist")
            ),
            CommunityChallenge(
                id: UUID(),
                title: "Speed Demon",
                description: "Complete any quiz in under 2 minutes",
                participants: 2156,
                timeRemaining: 86400, // 24 hours
                reward: ChallengeReward(points: 300, badge: "⚡", title: "Speed Master")
            )
        ]
    }
    
    private func generateDailyChallenges() -> [DailyChallenge] {
        let challenges = [
            DailyChallenge(
                date: Date(),
                title: "Quiz Master",
                description: "Complete 3 quizzes today",
                type: .completeQuizzes,
                targetValue: 3,
                reward: ChallengeReward(points: 100, badge: "📚")
            ),
            DailyChallenge(
                date: Date(),
                title: "Puzzle Solver",
                description: "Solve 2 puzzles today",
                type: .solvePuzzles,
                targetValue: 2,
                reward: ChallengeReward(points: 150, badge: "🧩")
            ),
            DailyChallenge(
                date: Date(),
                title: "Perfect Score",
                description: "Get a perfect score on any quiz",
                type: .perfectScore,
                targetValue: 1,
                reward: ChallengeReward(points: 200, badge: "⭐")
            ),
            DailyChallenge(
                date: Date(),
                title: "Variety Seeker",
                description: "Complete quizzes from 3 different categories",
                type: .variety,
                targetValue: 3,
                reward: ChallengeReward(points: 120, badge: "🌈")
            )
        ]
        
        return challenges
    }
}

struct CommunityChallenge: Identifiable {
    let id: UUID
    var title: String
    var description: String
    var participants: Int
    var timeRemaining: TimeInterval
    var reward: ChallengeReward
    var isJoined: Bool = false
    var progress: Double = 0.0
    
    var timeRemainingFormatted: String {
        let hours = Int(timeRemaining) / 3600
        let minutes = (Int(timeRemaining) % 3600) / 60
        
        if hours > 24 {
            let days = hours / 24
            return "\(days)d remaining"
        } else if hours > 0 {
            return "\(hours)h \(minutes)m remaining"
        } else {
            return "\(minutes)m remaining"
        }
    }
}
