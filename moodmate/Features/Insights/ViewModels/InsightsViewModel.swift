//
//  InsightsViewModel.swift
//  moodmate
//
//  Created by Nurtore on 26.07.2026.
//

import SwiftUI
import Combine

enum InsightsState: Equatable {
    case loading
    case loaded(InsightsDashboardData)
    case empty
    case error(String)
}

@MainActor
final class InsightsViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var selectedFilter: DateFilter = .month {
        didSet {
            if oldValue != selectedFilter {
                Task {
                    await loadDashboardData()
                }
            }
        }
    }
    
    @Published var state: InsightsState = .loading
    @Published var selectedMoodSlice: MoodDistributionItem? = nil

    @Published var selectedCalendarMonth: Date = Date()
    @Published var calendarEntries: [String: MoodRecord] = [:]
    @Published var selectedCalendarRecord: MoodRecord? = nil
    @Published var showCalendarDetailSheet: Bool = false
    
    @Published var isRefreshing: Bool = false
    
    // MARK: - Dependencies
    private let service: InsightsServiceProtocol
    
    init(service: InsightsServiceProtocol? = nil) {
        self.service = service ?? MockInsightsService()
    }
    
    // MARK: - Actions
    
    func loadInitialData() async {
        await loadDashboardData()
        await loadCalendarData()
    }
    
    func refresh() async {
        isRefreshing = true
        await loadDashboardData()
        await loadCalendarData()
        isRefreshing = false
    }
    
    func loadDashboardData() async {
        if case .loaded = state {
        } else {
            state = .loading
        }
        
        do {
            let data = try await service.fetchDashboardData(for: selectedFilter)
            if data.totalPostsCount == 0 && data.distribution.isEmpty {
                state = .empty
            } else {
                withAnimation(.easeInOut(duration: 0.35)) {
                    state = .loaded(data)
                }
            }
        } catch {
            state = .error(error.localizedDescription)
        }
    }
    
    func loadCalendarData() async {
        do {
            let entries = try await service.fetchCalendarEntries(for: selectedCalendarMonth)
            withAnimation(.easeInOut(duration: 0.25)) {
                self.calendarEntries = entries
            }
        } catch {
            print("Failed to fetch calendar entries: \(error)")
        }
    }
    
    func navigateCalendarMonth(by delta: Int) {
        let calendar = Calendar.current
        if let newMonth = calendar.date(byAdding: .month, value: delta, to: selectedCalendarMonth) {
            selectedCalendarMonth = newMonth
            Task {
                await loadCalendarData()
            }
        }
    }
    
    func selectCalendarDate(_ date: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let key = formatter.string(from: date)
        
        if let record = calendarEntries[key] {
            selectedCalendarRecord = record
            showCalendarDetailSheet = true
        } else {
            selectedCalendarRecord = MoodRecord(
                id: "empty-\(key)",
                date: date,
                moodEmoji: "✨",
                moodName: "No Log",
                score: 3,
                colorHex: "CBD5E0",
                note: "No mood post recorded on this day. Tap below to log your feelings!",
                postId: nil
            )
            showCalendarDetailSheet = true
        }
    }
    
    func toggleGoal(_ goal: Goal) {
        Task {
            do {
                let updatedGoal = try await service.toggleGoalCompletion(goalId: goal.id)
                if case let .loaded(currentData) = state {
                    var updatedGoals = currentData.goals
                    if let idx = updatedGoals.firstIndex(where: { $0.id == updatedGoal.id }) {
                        updatedGoals[idx] = updatedGoal
                        let newData = InsightsDashboardData(
                            filter: currentData.filter,
                            currentMoodEmoji: currentData.currentMoodEmoji,
                            currentMoodName: currentData.currentMoodName,
                            currentMoodColorHex: currentData.currentMoodColorHex,
                            totalPostsCount: currentData.totalPostsCount,
                            streaks: currentData.streaks,
                            distribution: currentData.distribution,
                            weeklyTrend: currentData.weeklyTrend,
                            postingHabits: currentData.postingHabits,
                            engagement: currentData.engagement,
                            topMoods: currentData.topMoods,
                            personalInsights: currentData.personalInsights,
                            achievements: currentData.achievements,
                            goals: updatedGoals
                        )
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                            state = .loaded(newData)
                        }
                    }
                }
            } catch {
                print("Failed to toggle goal: \(error)")
            }
        }
    }
}
