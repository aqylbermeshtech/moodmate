//
//  TrendingMoodChip.swift
//  moodmate
//
//  Created by Nurtore on 26.07.2026.
//

import SwiftUI

struct TrendingMoodChip: View {
    let mood: TrendingMood
    let isSelected: Bool
    var onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                Text(mood.emoji)
                    .font(.system(size: 18))
                
                VStack(alignment: .leading, spacing: 1) {
                    Text(mood.name)
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                    
                    Text(formattedCount(mood.postCount))
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(isSelected ? .white.opacity(0.85) : Color.theme.secondaryText)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background {
                if isSelected {
                    Capsule()
                        .fill(Color.adaptiveMoodColor(hex: mood.colorHex))
                } else {
                    Capsule()
                        .fill(Color.adaptiveMoodColor(hex: mood.colorHex).opacity(0.18))
                }
            }
            .foregroundStyle(isSelected ? .white : Color.adaptiveMoodColor(hex: mood.colorHex))
            .overlay(
                Capsule()
                    .stroke(
                        isSelected ? Color.clear : Color.adaptiveMoodColor(hex: mood.colorHex).opacity(0.3),
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
    
    private func formattedCount(_ count: Int) -> String {
        if count >= 1000 {
            return String(format: "%.1fk posts", Double(count) / 1000.0)
        }
        return "\(count) posts"
    }
}

#Preview {
    HStack(spacing: 10) {
        TrendingMoodChip(
            mood: TrendingMood(id: "1", emoji: "😊", name: "Happy", postCount: 1247, colorHex: "38B2AC"),
            isSelected: false,
            onTap: {}
        )
        TrendingMoodChip(
            mood: TrendingMood(id: "2", emoji: "😴", name: "Tired", postCount: 892, colorHex: "667EEA"),
            isSelected: true,
            onTap: {}
        )
    }
    .padding()
}
