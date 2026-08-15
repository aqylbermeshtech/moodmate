//
//  InsightsView.swift
//  moodmate
//
//  Created by Nurtore on 26.07.2026.
//

import SwiftUI

struct InsightsView: View {
    @StateObject private var viewModel = InsightsViewModel()
    var onAddPostTap: (() -> Void)? = nil
    
    var body: some View {
        NavigationStack {
            ZStack {

                Color.theme.primaryBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    VStack(spacing: 12) {
                        headerBar
                        
                        DateFilterPicker(selectedFilter: $viewModel.selectedFilter)
                    }
                    .padding(.bottom, 10)
                    .background(Color.theme.primaryBackground)

                    ScrollView {
                        VStack(spacing: 24) {
                            switch viewModel.state {
                            case .loading:
                                AnalyticsSkeletonView()
                                    .padding(.top, 16)
                                
                            case .empty:
                                AnalyticsEmptyStateView {
                                    onAddPostTap?()
                                }
                                
                            case .error(let message):
                                AnalyticsErrorView(message: message) {
                                    Task { await viewModel.loadInitialData() }
                                }
                                
                            case .loaded(let dashboardData):

                                AnalyticsOverviewCards(data: dashboardData)
                                    .padding(.top, 12)

                                MoodDistributionChart(
                                    items: dashboardData.distribution,
                                    selectedSlice: $viewModel.selectedMoodSlice
                                )

                                WeeklyTrendChart(
                                    trendPoints: dashboardData.weeklyTrend,
                                    dateFilterSubtitle: viewModel.selectedFilter.subtitle
                                )

                                MoodCalendarView(
                                    currentMonth: viewModel.selectedCalendarMonth,
                                    entries: viewModel.calendarEntries,
                                    onNavigateMonth: { delta in
                                        viewModel.navigateCalendarMonth(by: delta)
                                    },
                                    onSelectDate: { date in
                                        viewModel.selectCalendarDate(date)
                                    }
                                )

                                StreaksSectionView(streaks: dashboardData.streaks)

                                PostingHabitsView(habits: dashboardData.postingHabits)

                                EngagementAnalyticsView(engagement: dashboardData.engagement)
                                
                                TopMoodsView(topMoods: dashboardData.topMoods)

                                PersonalInsightsView(insights: dashboardData.personalInsights)

                                AchievementsSectionView(achievements: dashboardData.achievements)

                                GoalsSectionView(
                                    goals: dashboardData.goals,
                                    onToggleGoal: { goal in
                                        viewModel.toggleGoal(goal)
                                    }
                                )
                            }
                        }
                        .padding(.bottom, 110)
                    }
                    .refreshable {
                        await viewModel.refresh()
                    }
                }
            }
            .task {
                if case .loading = viewModel.state {
                    await viewModel.loadInitialData()
                }
            }
            .sheet(isPresented: $viewModel.showCalendarDetailSheet) {
                if let record = viewModel.selectedCalendarRecord {
                    DayDetailSheet(record: record)
                }
            }
            .errorAlert($viewModel.errorMessage)
        }
    }
    
    // MARK: - Header Bar Component
    private var headerBar: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Insights")
                    .font(.title.weight(.medium))
                    .foregroundStyle(Color.theme.primaryText)
                
                Text(greetingMessage)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.theme.secondaryText)
            }
            
            Spacer()
            HStack(spacing: 6) {
                Text("🔥")
                    .font(.system(size: 16))
                
                Text("12 Days")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(.orange)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.theme.warning.opacity(0.12))
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(Color.theme.warning.opacity(0.3), lineWidth: 0.5)
            )
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }
    
    private var greetingMessage: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning, Nurtore"
        case 12..<17: return "Good afternoon, Nurtore"
        default: return "Good evening, Nurtore"
        }
    }
}

#Preview {
    InsightsView()
}
