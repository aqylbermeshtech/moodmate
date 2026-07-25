//
//  WeeklyTrendChart.swift
//  moodmate
//
//  Created by Nurtore on 26.07.2026.
//

import SwiftUI
import Charts

struct WeeklyTrendChart: View {
    let trendPoints: [WeeklyTrendPoint]
    let dateFilterSubtitle: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            VStack(alignment: .leading, spacing: 4) {
                Text("Mood Score Trend")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                
                Text(dateFilterSubtitle)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)
            }
            
            // Chart Area
            Chart {
                ForEach(trendPoints) { point in
                    // Area Gradient Fill
                    AreaMark(
                        x: .value("Day", point.dayLabel),
                        y: .value("Score", point.averageScore)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.teal.opacity(0.4), Color.teal.opacity(0.02)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    
                    // Line Mark
                    LineMark(
                        x: .value("Day", point.dayLabel),
                        y: .value("Score", point.averageScore)
                    )
                    .interpolationMethod(.catmullRom)
                    .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.teal, Color.purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    
                    // Point Mark (Emoji Annotations)
                    PointMark(
                        x: .value("Day", point.dayLabel),
                        y: .value("Score", point.averageScore)
                    )
                    .foregroundStyle(Color(hex: point.colorHex))
                    .annotation(position: .top, spacing: 4) {
                        Text(point.primaryMoodEmoji)
                            .font(.system(size: 14))
                    }
                }
            }
            .chartYScale(domain: 1...6)
            .chartYAxis {
                AxisMarks(position: .leading, values: [1, 3, 5]) { value in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [4, 4]))
                        .foregroundStyle(Color.primary.opacity(0.12))
                    AxisValueLabel {
                        if let intVal = value.as(Int.self) {
                            Text(moodNameForScore(intVal))
                                .font(.system(size: 10, weight: .semibold, design: .rounded))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .chartXAxis {
                AxisMarks(values: .automatic) { value in
                    AxisGridLine().foregroundStyle(Color.clear)
                    AxisValueLabel {
                        if let day = value.as(String.self) {
                            Text(day)
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundStyle(.primary)
                        }
                    }
                }
            }
            .frame(height: 200)
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
    
    private func moodNameForScore(_ score: Int) -> String {
        switch score {
        case 1: return "Anxious"
        case 3: return "Tired"
        case 5: return "Happy"
        default: return ""
        }
    }
}
