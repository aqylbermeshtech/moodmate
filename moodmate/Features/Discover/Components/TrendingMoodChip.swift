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
                        .font(.xTrendingTopic)

                    Text(formattedCount(mood.postCount))
                        .font(.xTrendingMeta)
                        .foregroundStyle(isSelected ? .white.opacity(0.85) : Color.theme.secondaryText)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background {
                if isSelected {
                    Capsule()
                        .fill(Color.theme.accent)
                } else {
                    Capsule()
                        .fill(Color.theme.secondaryBackground)
                }
            }
            .foregroundStyle(isSelected ? .white : Color.theme.primaryText)
            .overlay(
                Capsule()
                    .stroke(
                        isSelected ? Color.clear : Color.theme.divider,
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(XPressableStyle())
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
    .background(Color.theme.primaryBackground)
}
