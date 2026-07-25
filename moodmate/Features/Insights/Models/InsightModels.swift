//
//  InsightModels.swift
//  moodmate
//
//  Created by Nurtore on 26.07.2026.
//

import SwiftUI

// MARK: - Date Filter Period
enum DateFilter: String, CaseIterable, Identifiable, Codable {
    case today = "Today"
    case week = "Week"
    case month = "Month"
    case threeMonths = "3 Months"
    case year = "Year"
    case allTime = "All Time"
    
    var id: String { rawValue }
    
    var displayName: String { rawValue }
    
    var subtitle: String {
        switch self {
        case .today: return "Today's summary"
        case .week: return "Past 7 days"
        case .month: return "Past 30 days"
        case .threeMonths: return "Past 90 days"
        case .year: return "Past 365 days"
        case .allTime: return "Lifetime statistics"
        }
    }
}

// MARK: - Mood Record Model
struct MoodRecord: Identifiable, Codable, Equatable {
    let id: String
    let date: Date
    let moodEmoji: String
    let moodName: String
    let score: Int // 1 (lowest) to 6 (highest)
    let colorHex: String
    let note: String?
    let postId: String?
}

// MARK: - Mood Distribution Item (Donut Chart)
struct MoodDistributionItem: Identifiable, Codable, Equatable {
    let id: String
    let moodEmoji: String
    let moodName: String
    let count: Int
    let percentage: Double // 0.0 to 100.0
    let colorHex: String
}

// MARK: - Weekly Trend Point (Line Chart)
struct WeeklyTrendPoint: Identifiable, Codable, Equatable {
    let id: String
    let dayLabel: String // e.g. "Mon", "Tue"
    let date: Date
    let averageScore: Double // 1.0 to 6.0
    let primaryMoodEmoji: String
    let colorHex: String
}

// MARK: - Streaks Metrics Data
struct StreakData: Codable, Equatable {
    let currentStreakDays: Int
    let longestStreakDays: Int
    let bestMonthName: String
    let consistencyScorePercentage: Int // 0-100%
}

// MARK: - Posting Habits Data
struct PostingHabitsHourlyPoint: Identifiable, Codable, Equatable {
    let id: String
    let hourLabel: String // e.g. "9 AM"
    let hourOfDay: Int // 0-23
    let postCount: Int
}

struct PostingHabitsData: Codable, Equatable {
    let mostActiveDay: String // e.g. "Sunday"
    let mostActiveHourLabel: String // e.g. "8:00 PM"
    let avgPostsPerWeek: Double
    let postingConsistencyPercentage: Int
    let longestBreakDays: Int
    let hourlyBreakdown: [PostingHabitsHourlyPoint]
}

// MARK: - Engagement Data
struct EngagementFollowerPoint: Identifiable, Codable, Equatable {
    let id: String
    let label: String
    let count: Int
}

struct EngagementWeeklyPoint: Identifiable, Codable, Equatable {
    let id: String
    let dayLabel: String
    let likesCount: Int
    let commentsCount: Int
}

struct EngagementPostSnapshot: Identifiable, Codable, Equatable {
    let id: String
    let quoteText: String
    let moodEmoji: String
    let moodColorHex: String
    let likesCount: Int
    let commentsCount: Int
    let timeAgo: String
}

struct EngagementData: Codable, Equatable {
    let avgLikesPerPost: Double
    let avgCommentsPerPost: Double
    let totalLikesReceived: Int
    let totalCommentsReceived: Int
    let followersCount: Int
    let mostLikedPost: EngagementPostSnapshot?
    let mostCommentedPost: EngagementPostSnapshot?
    let followerGrowth: [EngagementFollowerPoint]
    let weeklyEngagement: [EngagementWeeklyPoint]
}

// MARK: - Top Mood Item (Ranked List)
struct TopMoodItem: Identifiable, Codable, Equatable {
    let id: String
    let rank: Int
    let moodEmoji: String
    let moodName: String
    let percentage: Double
    let postCount: Int
    let colorHex: String
}

// MARK: - Personal Insight (AI Friendly Card)
enum InsightCategory: String, Codable {
    case positive
    case pattern
    case achievement
    case suggestion
}

struct PersonalInsight: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let message: String
    let iconName: String
    let category: InsightCategory
    let accentColorHex: String
}

// MARK: - Achievement Model
struct InsightAchievement: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let description: String
    let iconEmoji: String
    let progress: Int
    let totalTarget: Int
    let isUnlocked: Bool
    let unlockedDateLabel: String?
    let badgeColorHex: String
    
    var percentage: Double {
        guard totalTarget > 0 else { return 0 }
        return min(1.0, Double(progress) / Double(totalTarget))
    }
}

// MARK: - Goal Model
struct Goal: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let targetDescription: String
    var currentValue: Int
    let targetValue: Int
    let unit: String
    let iconName: String
    let colorHex: String
    var isCompleted: Bool
    
    var progressFraction: Double {
        guard targetValue > 0 else { return 0 }
        return min(1.0, Double(currentValue) / Double(targetValue))
    }
}

// MARK: - Complete Insights Dashboard Data Container
struct InsightsDashboardData: Codable, Equatable {
    let filter: DateFilter
    let currentMoodEmoji: String
    let currentMoodName: String
    let currentMoodColorHex: String
    let totalPostsCount: Int
    let streaks: StreakData
    let distribution: [MoodDistributionItem]
    let weeklyTrend: [WeeklyTrendPoint]
    let postingHabits: PostingHabitsData
    let engagement: EngagementData
    let topMoods: [TopMoodItem]
    let personalInsights: [PersonalInsight]
    let achievements: [InsightAchievement]
    let goals: [Goal]
}
