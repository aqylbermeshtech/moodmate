//
//  MockInsightsService.swift
//  moodmate
//
//  Created by Nurtore on 26.07.2026.
//

import Foundation

@MainActor
final class MockInsightsService: InsightsServiceProtocol {
 
    private let simulatedDelayNanoseconds: UInt64 = 400_000_000

    private var userGoals: [Goal] = [
        Goal(id: "goal-1", title: "Daily Check-in", targetDescription: "Post your mood every single day", currentValue: 12, targetValue: 30, unit: "days", iconName: "flame.fill", colorHex: "FF6B6B", isCompleted: false),
        Goal(id: "goal-2", title: "30-Day Streak", targetDescription: "Maintain an uninterrupted 30-day streak", currentValue: 12, targetValue: 30, unit: "days", iconName: "bolt.fill", colorHex: "FFD166", isCompleted: false),
        Goal(id: "goal-3", title: "Mood Explorer", targetDescription: "Log all 6 distinct mood spectrums", currentValue: 6, targetValue: 6, unit: "moods", iconName: "sparkles", colorHex: "4ECDC4", isCompleted: true),
        Goal(id: "goal-4", title: "Community Reach", targetDescription: "Reach 500 total profile followers", currentValue: 428, targetValue: 500, unit: "followers", iconName: "person.2.fill", colorHex: "1A535C", isCompleted: false),
        Goal(id: "goal-5", title: "Consistent Creator", targetDescription: "Publish 100 mood posts in MoodMate", currentValue: 84, targetValue: 100, unit: "posts", iconName: "square.and.pencil", colorHex: "A855F7", isCompleted: false)
    ]

    func fetchDashboardData(for filter: DateFilter) async throws -> InsightsDashboardData {
        try await Task.sleep(nanoseconds: simulatedDelayNanoseconds)
        
        let distribution = getDistribution(for: filter)
        let weeklyTrend = getWeeklyTrend(for: filter)
        let streaks = StreakData(
            currentStreakDays: 12,
            longestStreakDays: 28,
            bestMonthName: "July",
            consistencyScorePercentage: 94
        )
        
        let postingHabits = getPostingHabits(for: filter)
        let engagement = getEngagementData(for: filter)
        let topMoods = getTopMoods(for: filter)
        let personalInsights = getPersonalInsights(for: filter)
        let achievements = getAchievements()
        
        return InsightsDashboardData(
            filter: filter,
            currentMoodEmoji: "😌",
            currentMoodName: "Calm",
            currentMoodColorHex: "38B2AC",
            totalPostsCount: getFilteredPostsCount(for: filter),
            streaks: streaks,
            distribution: distribution,
            weeklyTrend: weeklyTrend,
            postingHabits: postingHabits,
            engagement: engagement,
            topMoods: topMoods,
            personalInsights: personalInsights,
            achievements: achievements,
            goals: userGoals
        )
    }
    
    func fetchCalendarEntries(for month: Date) async throws -> [String: MoodRecord] {
        try await Task.sleep(nanoseconds: simulatedDelayNanoseconds / 2)
        
        var records: [String: MoodRecord] = [:]
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        guard let range = calendar.range(of: .day, in: .month, for: month) else {
            return records
        }
        
        let components = calendar.dateComponents([.year, .month], from: month)
        let moods: [(emoji: String, name: String, score: Int, color: String)] = [
            ("😊", "Happy", 5, "FFB800"),
            ("😌", "Calm", 4, "38B2AC"),
            ("🤩", "Excited", 6, "FF5964"),
            ("😔", "Sad", 2, "4A90E2"),
            ("😴", "Tired", 3, "9B51E0"),
            ("😰", "Anxious", 1, "E28743")
        ]
        
        for day in range {
            var dayComp = components
            dayComp.day = day
            if let date = calendar.date(from: dayComp) {
                let mood = moods[(day * 3 + (dayComp.month ?? 1)) % moods.count]
                let dateString = formatter.string(from: date)
                
                records[dateString] = MoodRecord(
                    id: "rec-\(dateString)",
                    date: date,
                    moodEmoji: mood.emoji,
                    moodName: mood.name,
                    score: mood.score,
                    colorHex: mood.color,
                    note: "Reflecting on my feelings today during day \(day).",
                    postId: "post-\(dateString)"
                )
            }
        }
        
        return records
    }
    
    func toggleGoalCompletion(goalId: String) async throws -> Goal {
        try await Task.sleep(nanoseconds: 150_000_000)
        guard let index = userGoals.firstIndex(where: { $0.id == goalId }) else {
            throw NSError(domain: "MockInsightsService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Goal not found"])
        }
        
        userGoals[index].isCompleted.toggle()
        if userGoals[index].isCompleted {
            userGoals[index].currentValue = userGoals[index].targetValue
        } else {
            userGoals[index].currentValue = max(0, userGoals[index].targetValue - 5)
        }
        return userGoals[index]
    }
    
    // MARK: - Private Mock Generators
    
    private func getFilteredPostsCount(for filter: DateFilter) -> Int {
        switch filter {
        case .today: return 3
        case .week: return 18
        case .month: return 48
        case .threeMonths: return 112
        case .year: return 365
        case .allTime: return 428
        }
    }
    
    private func getDistribution(for filter: DateFilter) -> [MoodDistributionItem] {
        switch filter {
        case .today:
            return [
                MoodDistributionItem(id: "1", moodEmoji: "😌", moodName: "Calm", count: 2, percentage: 66.7, colorHex: "38B2AC"),
                MoodDistributionItem(id: "2", moodEmoji: "😊", moodName: "Happy", count: 1, percentage: 33.3, colorHex: "FFB800")
            ]
        case .week:
            return [
                MoodDistributionItem(id: "1", moodEmoji: "😊", moodName: "Happy", count: 7, percentage: 38.9, colorHex: "FFB800"),
                MoodDistributionItem(id: "2", moodEmoji: "😌", moodName: "Calm", count: 5, percentage: 27.8, colorHex: "38B2AC"),
                MoodDistributionItem(id: "3", moodEmoji: "🤩", moodName: "Excited", count: 3, percentage: 16.7, colorHex: "FF5964"),
                MoodDistributionItem(id: "4", moodEmoji: "😴", moodName: "Tired", count: 2, percentage: 11.1, colorHex: "9B51E0"),
                MoodDistributionItem(id: "5", moodEmoji: "😔", moodName: "Sad", count: 1, percentage: 5.5, colorHex: "4A90E2")
            ]
        case .month, .threeMonths, .year, .allTime:
            return [
                MoodDistributionItem(id: "1", moodEmoji: "😊", moodName: "Happy", count: 128, percentage: 35.0, colorHex: "FFB800"),
                MoodDistributionItem(id: "2", moodEmoji: "😌", moodName: "Calm", count: 80, percentage: 22.0, colorHex: "38B2AC"),
                MoodDistributionItem(id: "3", moodEmoji: "🤩", moodName: "Excited", count: 51, percentage: 14.0, colorHex: "FF5964"),
                MoodDistributionItem(id: "4", moodEmoji: "😰", moodName: "Anxious", count: 37, percentage: 10.0, colorHex: "E28743"),
                MoodDistributionItem(id: "5", moodEmoji: "😔", moodName: "Sad", count: 36, percentage: 10.0, colorHex: "4A90E2"),
                MoodDistributionItem(id: "6", moodEmoji: "😴", moodName: "Tired", count: 33, percentage: 9.0, colorHex: "9B51E0")
            ]
        }
    }
    
    private func getWeeklyTrend(for filter: DateFilter) -> [WeeklyTrendPoint] {
        let calendar = Calendar.current
        let today = Date()
        let days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        let scores = [4.2, 3.8, 4.5, 4.0, 5.2, 5.6, 5.1]
        let emojis = ["😌", "😴", "😌", "😊", "🤩", "😊", "😌"]
        let colors = ["38B2AC", "9B51E0", "38B2AC", "FFB800", "FF5964", "FFB800", "38B2AC"]
        
        return (0..<7).map { idx in
            let date = calendar.date(byAdding: .day, value: -(6 - idx), to: today) ?? today
            return WeeklyTrendPoint(
                id: "wt-\(idx)",
                dayLabel: days[idx],
                date: date,
                averageScore: scores[idx],
                primaryMoodEmoji: emojis[idx],
                colorHex: colors[idx]
            )
        }
    }
    
    private func getPostingHabits(for filter: DateFilter) -> PostingHabitsData {
        let hourly = [
            PostingHabitsHourlyPoint(id: "h6", hourLabel: "6 AM", hourOfDay: 6, postCount: 2),
            PostingHabitsHourlyPoint(id: "h9", hourLabel: "9 AM", hourOfDay: 9, postCount: 14),
            PostingHabitsHourlyPoint(id: "h12", hourLabel: "12 PM", hourOfDay: 12, postCount: 22),
            PostingHabitsHourlyPoint(id: "h15", hourLabel: "3 PM", hourOfDay: 15, postCount: 18),
            PostingHabitsHourlyPoint(id: "h18", hourLabel: "6 PM", hourOfDay: 18, postCount: 29),
            PostingHabitsHourlyPoint(id: "h20", hourLabel: "8 PM", hourOfDay: 20, postCount: 42),
            PostingHabitsHourlyPoint(id: "h22", hourLabel: "10 PM", hourOfDay: 22, postCount: 11)
        ]
        
        return PostingHabitsData(
            mostActiveDay: "Sunday",
            mostActiveHourLabel: "8:00 PM",
            avgPostsPerWeek: 4.8,
            postingConsistencyPercentage: 88,
            longestBreakDays: 2,
            hourlyBreakdown: hourly
        )
    }
    
    private func getEngagementData(for filter: DateFilter) -> EngagementData {
        let followerPoints = [
            EngagementFollowerPoint(id: "f1", label: "May", count: 280),
            EngagementFollowerPoint(id: "f2", label: "Jun", count: 340),
            EngagementFollowerPoint(id: "f3", label: "Jul", count: 428)
        ]
        
        let weeklyEng = [
            EngagementWeeklyPoint(id: "e1", dayLabel: "Mon", likesCount: 42, commentsCount: 9),
            EngagementWeeklyPoint(id: "e2", dayLabel: "Tue", likesCount: 38, commentsCount: 7),
            EngagementWeeklyPoint(id: "e3", dayLabel: "Wed", likesCount: 55, commentsCount: 14),
            EngagementWeeklyPoint(id: "e4", dayLabel: "Thu", likesCount: 48, commentsCount: 11),
            EngagementWeeklyPoint(id: "e5", dayLabel: "Fri", likesCount: 78, commentsCount: 19),
            EngagementWeeklyPoint(id: "e6", dayLabel: "Sat", likesCount: 95, commentsCount: 24),
            EngagementWeeklyPoint(id: "e7", dayLabel: "Sun", likesCount: 110, commentsCount: 31)
        ]
        
        let topLiked = EngagementPostSnapshot(
            id: "post-top-liked",
            quoteText: "Sunset reflections: Finding tranquility amidst the quiet evening noise.",
            moodEmoji: "😌",
            moodColorHex: "38B2AC",
            likesCount: 148,
            commentsCount: 26,
            timeAgo: "3 days ago"
        )
        
        let topCommented = EngagementPostSnapshot(
            id: "post-top-comm",
            quoteText: "Starting a new mindfulness journey today! What keeps you grounded?",
            moodEmoji: "🤩",
            moodColorHex: "FF5964",
            likesCount: 112,
            commentsCount: 44,
            timeAgo: "1 week ago"
        )
        
        return EngagementData(
            avgLikesPerPost: 14.6,
            avgCommentsPerPost: 3.8,
            totalLikesReceived: 512,
            totalCommentsReceived: 124,
            followersCount: 428,
            mostLikedPost: topLiked,
            mostCommentedPost: topCommented,
            followerGrowth: followerPoints,
            weeklyEngagement: weeklyEng
        )
    }
    
    private func getTopMoods(for filter: DateFilter) -> [TopMoodItem] {
        return [
            TopMoodItem(id: "tm1", rank: 1, moodEmoji: "😊", moodName: "Happy", percentage: 35.0, postCount: 128, colorHex: "FFB800"),
            TopMoodItem(id: "tm2", rank: 2, moodEmoji: "😌", moodName: "Calm", percentage: 22.0, postCount: 80, colorHex: "38B2AC"),
            TopMoodItem(id: "tm3", rank: 3, moodEmoji: "🤩", moodName: "Excited", percentage: 14.0, postCount: 51, colorHex: "FF5964"),
            TopMoodItem(id: "tm4", rank: 4, moodEmoji: "😰", moodName: "Anxious", percentage: 10.0, postCount: 37, colorHex: "E28743"),
            TopMoodItem(id: "tm5", rank: 5, moodEmoji: "😔", moodName: "Sad", percentage: 10.0, postCount: 36, colorHex: "4A90E2")
        ]
    }
    
    private func getPersonalInsights(for filter: DateFilter) -> [PersonalInsight] {
        return [
            PersonalInsight(
                id: "pi1",
                title: "Weekend Bliss",
                message: "You feel happiest on weekends. Your average mood score leaps from 4.1 to 5.4 on Saturday and Sunday!",
                iconName: "sun.max.fill",
                category: .positive,
                accentColorHex: "FFB800"
            ),
            PersonalInsight(
                id: "pi2",
                title: "Evening Reflection Routine",
                message: "You post most often in the evening around 8:00 PM. Taking time to unwind daily builds inner clarity.",
                iconName: "moon.stars.fill",
                category: .pattern,
                accentColorHex: "A855F7"
            ),
            PersonalInsight(
                id: "pi3",
                title: "12-Day Streak Milestone",
                message: "You've maintained a 12-day posting streak! Only 18 more days to reach your 30-day Streak Goal.",
                iconName: "flame.fill",
                category: .achievement,
                accentColorHex: "FF6B6B"
            ),
            PersonalInsight(
                id: "pi4",
                title: "Calm Horizon",
                message: "Your most common mood this month is Calm (22% of all entries). Your emotional balance is thriving.",
                iconName: "leaf.fill",
                category: .positive,
                accentColorHex: "38B2AC"
            ),
            PersonalInsight(
                id: "pi5",
                title: "Stronger Consistency",
                message: "You've been 18% more consistent than last month. Keep building your daily mindfulness practice!",
                iconName: "chart.line.uptrend.xyaxis",
                category: .suggestion,
                accentColorHex: "4ECDC4"
            )
        ]
    }
    
    private func getAchievements() -> [InsightAchievement] {
        return [
            InsightAchievement(id: "ach-1", title: "7-Day Streak", description: "Log your mood for 7 consecutive days", iconEmoji: "🔥", progress: 7, totalTarget: 7, isUnlocked: true, unlockedDateLabel: "Jul 14", badgeColorHex: "FF6B6B"),
            InsightAchievement(id: "ach-2", title: "100 Posts", description: "Share 100 mood posts with MoodMate", iconEmoji: "📸", progress: 84, totalTarget: 100, isUnlocked: false, unlockedDateLabel: nil, badgeColorHex: "A855F7"),
            InsightAchievement(id: "ach-3", title: "Mood Explorer", description: "Experience all 6 mood spectrums", iconEmoji: "🌈", progress: 6, totalTarget: 6, isUnlocked: true, unlockedDateLabel: "Jun 20", badgeColorHex: "38B2AC"),
            InsightAchievement(id: "ach-4", title: "Early Bird", description: "Post a morning mood before 8:00 AM", iconEmoji: "⭐", progress: 1, totalTarget: 1, isUnlocked: true, unlockedDateLabel: "Jul 02", badgeColorHex: "FFB800"),
            InsightAchievement(id: "ach-5", title: "Consistent Poster", description: "Post at least 5 days a week for a month", iconEmoji: "🎯", progress: 24, totalTarget: 30, isUnlocked: false, unlockedDateLabel: nil, badgeColorHex: "FF5964"),
            InsightAchievement(id: "ach-6", title: "Social Butterfly", description: "Receive 500 total post likes", iconEmoji: "❤️", progress: 512, totalTarget: 500, isUnlocked: true, unlockedDateLabel: "Jul 22", badgeColorHex: "FF5964"),
            InsightAchievement(id: "ach-7", title: "Night Owl", description: "Log a night reflection after 11:00 PM", iconEmoji: "🌙", progress: 5, totalTarget: 5, isUnlocked: true, unlockedDateLabel: "May 18", badgeColorHex: "6C5CE7")
        ]
    }
}
