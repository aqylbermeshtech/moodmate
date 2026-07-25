//
//  PostingHabitsView.swift
//  moodmate
//
//  Created by Nurtore on 26.07.2026.
//

import SwiftUI
import Charts

struct PostingHabitsView: View {
    let habits: PostingHabitsData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            VStack(alignment: .leading, spacing: 4) {
                Text("Posting Habits & Activity")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                
                Text("When and how often you share your mood")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)
            }
            
            // Metrics Row
            HStack(spacing: 12) {
                HabitMetricBadge(title: "Peak Day", value: habits.mostActiveDay, icon: "calendar.day.timeline.left")
                HabitMetricBadge(title: "Peak Time", value: habits.mostActiveHourLabel, icon: "clock.fill")
                HabitMetricBadge(title: "Weekly Avg", value: "\(String(format: "%.1f", habits.avgPostsPerWeek))", icon: "paperplane.fill")
            }
            
            // Sub-metrics
            HStack(spacing: 16) {
                Label("Longest break: \(habits.longestBreakDays) days", systemImage: "arrow.pause.circle.fill")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Label("Consistency: \(habits.postingConsistencyPercentage)%", systemImage: "checkmark.seal.fill")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(.teal)
            }
            
            // Hourly Bar Chart
            VStack(alignment: .leading, spacing: 8) {
                Text("Posts by Time of Day")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(.secondary)
                
                Chart(habits.hourlyBreakdown) { point in
                    BarMark(
                        x: .value("Time", point.hourLabel),
                        y: .value("Posts", point.postCount)
                    )
                    .cornerRadius(6)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.teal, Color.purple.opacity(0.8)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
                .frame(height: 140)
                .chartXAxis {
                    AxisMarks(values: .automatic) { value in
                        AxisValueLabel {
                            if let label = value.as(String.self) {
                                Text(label)
                                    .font(.system(size: 10, weight: .bold, design: .rounded))
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
        }
        .padding(18)
        .background {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [.white.opacity(0.4), .white.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        }
        .shadow(color: .black.opacity(0.04), radius: 10, x: 0, y: 5)
        .padding(.horizontal, 20)
    }
}

private struct HabitMetricBadge: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.teal)
            
            Text(value)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
                .minimumScaleFactor(0.8)
                .lineLimit(1)
            
            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.primary.opacity(0.03))
        }
    }
}
