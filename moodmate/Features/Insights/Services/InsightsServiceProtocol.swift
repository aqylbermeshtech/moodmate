//
//  InsightsServiceProtocol.swift
//  moodmate
//
//  Created by Nurtore on 26.07.2026.
//

import Foundation

@MainActor
protocol InsightsServiceProtocol {
    func fetchDashboardData(for filter: DateFilter) async throws -> InsightsDashboardData
    func fetchCalendarEntries(for month: Date) async throws -> [String: MoodRecord]
    func toggleGoalCompletion(goalId: String) async throws -> Goal
}
