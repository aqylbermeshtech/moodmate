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
                // Background gradient matching Home & Discover
                Color.theme.backgroundGradient
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header Bar & Date Filter Picker
                    VStack(spacing: 12) {
                        headerBar
                        
                        DateFilterPicker(selectedFilter: $viewModel.selectedFilter)
                    }
                    .padding(.bottom, 10)
                    .background(.ultraThinMaterial)
                    
                    // Main Scrollable Content Area
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
                                // 1. Mood Overview Cards
                                AnalyticsOverviewCards(data: dashboardData)
                                    .padding(.top, 12)
                                
                                // 2. Mood Distribution Donut Chart
                                MoodDistributionChart(
                                    items: dashboardData.distribution,
                                    selectedSlice: $viewModel.selectedMoodSlice
                                )
                                
                                // 3. Weekly Mood Trend Chart
                                WeeklyTrendChart(
                                    trendPoints: dashboardData.weeklyTrend,
                                    dateFilterSubtitle: viewModel.selectedFilter.subtitle
                                )
                                
                                // 4. Monthly Mood Calendar
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
                                
                                // 5. Streaks Section
                                StreaksSectionView(streaks: dashboardData.streaks)
                                
                                // 6. Posting Habits Section
                                PostingHabitsView(habits: dashboardData.postingHabits)
                                
                                // 7. Engagement Section
                                EngagementAnalyticsView(engagement: dashboardData.engagement)
                                
                                // 8. Top Moods Ranking
                                TopMoodsView(topMoods: dashboardData.topMoods)
                                
                                // 9. Personal Insights
                                PersonalInsightsView(insights: dashboardData.personalInsights)
                                
                                // 10. Badges & Achievements
                                AchievementsSectionView(achievements: dashboardData.achievements)
                                
                                // 11. Goals Tracking
                                GoalsSectionView(
                                    goals: dashboardData.goals,
                                    onToggleGoal: { goal in
                                        viewModel.toggleGoal(goal)
                                    }
                                )
                            }
                        }
                        .padding(.bottom, 110) // Bottom tab bar spacing
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
        }
    }
    
    // MARK: - Header Bar Component
    private var headerBar: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Insights")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.teal, Color.purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                Text(greetingMessage)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.theme.secondaryText)
            }
            
            Spacer()
            
            // Streak Pill Badge
            HStack(spacing: 6) {
                Text("🔥")
                    .font(.system(size: 16))
                
                Text("12 Days")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(.orange)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.orange.opacity(0.12))
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(Color.orange.opacity(0.3), lineWidth: 1)
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
