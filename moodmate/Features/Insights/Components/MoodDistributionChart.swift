//
//  MoodDistributionChart.swift
//  moodmate
//
//  Created by Nurtore on 26.07.2026.
//

import SwiftUI
import Charts

struct MoodDistributionChart: View {
    let items: [MoodDistributionItem]
    @Binding var selectedSlice: MoodDistributionItem?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section Header
            VStack(alignment: .leading, spacing: 4) {
                Text("Mood Distribution")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                
                Text("Frequency of felt emotions over this period")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)
            }
            
            ZStack {
                // Apple Charts SectorMark Donut Chart
                Chart(items) { item in
                    SectorMark(
                        angle: .value("Count", item.count),
                        innerRadius: .ratio(0.62),
                        angularInset: 2.0
                    )
                    .cornerRadius(6)
                    .foregroundStyle(Color(hex: item.colorHex))
                    .opacity(selectedSlice == nil || selectedSlice?.id == item.id ? 1.0 : 0.4)
                }
                .frame(height: 220)
                
                // Donut Center Text Summary
                VStack(spacing: 2) {
                    if let selected = selectedSlice {
                        Text(selected.moodEmoji)
                            .font(.system(size: 28))
                        Text("\(Int(selected.percentage))%")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)
                        Text(selected.moodName)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(.secondary)
                    } else {
                        Text("\(items.map(\.count).reduce(0, +))")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)
                        Text("Total Logs")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            // Legend Grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(items) { item in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                            if selectedSlice?.id == item.id {
                                selectedSlice = nil
                            } else {
                                selectedSlice = item
                            }
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Circle()
                                .fill(Color(hex: item.colorHex))
                                .frame(width: 10, height: 10)
                            
                            Text("\(item.moodEmoji) \(item.moodName)")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundStyle(.primary)
                            
                            Spacer()
                            
                            Text("\(String(format: "%.0f", item.percentage))%")
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(selectedSlice?.id == item.id ? Color(hex: item.colorHex).opacity(0.18) : Color.primary.opacity(0.04))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .stroke(selectedSlice?.id == item.id ? Color(hex: item.colorHex).opacity(0.5) : Color.clear, lineWidth: 1)
                                )
                        }
                    }
                    .buttonStyle(.plain)
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
