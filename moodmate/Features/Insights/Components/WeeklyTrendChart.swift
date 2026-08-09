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
            VStack(alignment: .leading, spacing: 4) {
                Text("Mood Score Trend")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.theme.primaryText)
                
                Text(dateFilterSubtitle)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.theme.secondaryText)
            }

            Chart {
                ForEach(trendPoints) { point in
                    AreaMark(
                        x: .value("Day", point.dayLabel),
                        y: .value("Score", point.averageScore)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(
                        Color.theme.accent.opacity(0.14)
                    )
                    LineMark(
                        x: .value("Day", point.dayLabel),
                        y: .value("Score", point.averageScore)
                    )
                    .interpolationMethod(.catmullRom)
                    .lineStyle(StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round))
                    .foregroundStyle(Color.theme.accent)

                    PointMark(
                        x: .value("Day", point.dayLabel),
                        y: .value("Score", point.averageScore)
                    )
                    .foregroundStyle(Color.adaptiveMoodColor(hex: point.colorHex))
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
                        .foregroundStyle(Color.theme.divider)
                    AxisValueLabel {
                        if let intVal = value.as(Int.self) {
                            Text(moodNameForScore(intVal))
                                .font(.system(size: 10, weight: .semibold, design: .rounded))
                                .foregroundStyle(Color.theme.secondaryText)
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
                                .foregroundStyle(Color.theme.primaryText)
                        }
                    }
                }
            }
            .frame(height: 200)
        }
        .padding(18)
        .background {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.theme.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Color.theme.border, lineWidth: 1)
                )
        }
        .shadow(color: Color.theme.shadow, radius: 10, x: 0, y: 5)
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
