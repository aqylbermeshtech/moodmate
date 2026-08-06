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
            VStack(alignment: .leading, spacing: 4) {
                Text("Mood Distribution")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.theme.primaryText)
                
                Text("Frequency of felt emotions over this period")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.theme.secondaryText)
            }
            
            ZStack {
                Chart(items) { item in
                    SectorMark(
                        angle: .value("Count", item.count),
                        innerRadius: .ratio(0.62),
                        angularInset: 2.0
                    )
                    .cornerRadius(6)
                    .foregroundStyle(Color.adaptiveMoodColor(hex: item.colorHex))
                    .opacity(selectedSlice == nil || selectedSlice?.id == item.id ? 1.0 : 0.4)
                }
                .frame(height: 220)
                
                VStack(spacing: 2) {
                    if let selected = selectedSlice {
                        Text(selected.moodEmoji)
                            .font(.system(size: 28))
                        Text("\(Int(selected.percentage))%")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.theme.primaryText)
                        Text(selected.moodName)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(Color.theme.secondaryText)
                    } else {
                        Text("\(items.map(\.count).reduce(0, +))")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.theme.primaryText)
                        Text("Total Logs")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(Color.theme.secondaryText)
                    }
                }
            }

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
                                .fill(Color.adaptiveMoodColor(hex: item.colorHex))
                                .frame(width: 10, height: 10)
                            
                            Text("\(item.moodEmoji) \(item.moodName)")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundStyle(Color.theme.primaryText)
                            
                            Spacer()
                            
                            Text("\(String(format: "%.0f", item.percentage))%")
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.theme.secondaryText)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(selectedSlice?.id == item.id ? Color.adaptiveMoodColor(hex: item.colorHex).opacity(0.2) : Color.theme.groupedBackground)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .stroke(selectedSlice?.id == item.id ? Color.adaptiveMoodColor(hex: item.colorHex).opacity(0.5) : Color.theme.border, lineWidth: 1)
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
                .fill(Color.theme.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Color.theme.border, lineWidth: 1)
                )
        }
        .shadow(color: Color.theme.shadow, radius: 10, x: 0, y: 5)
        .padding(.horizontal, 20)
    }
}
