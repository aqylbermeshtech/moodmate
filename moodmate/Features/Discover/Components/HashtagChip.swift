//
//  HashtagChip.swift
//  moodmate
//
//  Created by Nurtore on 26.07.2026.
//

import SwiftUI

struct HashtagChip: View {
    let hashtag: DiscoverHashtag
    let isSelected: Bool
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 4) {
                Text("#\(hashtag.name)")
                    .font(.xTrendingTopic)

                Text(formattedCount(hashtag.postCount))
                    .font(.xTrendingMeta)
                    .foregroundStyle(isSelected ? .white.opacity(0.8) : Color.theme.secondaryText)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background {
                if isSelected {
                    Capsule().fill(Color.theme.accent)
                } else {
                    Capsule().fill(Color.theme.secondaryBackground)
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
            return String(format: "%.1fk", Double(count) / 1000.0)
        }
        return "\(count)"
    }
}

#Preview {
    HStack(spacing: 8) {
        HashtagChip(
            hashtag: DiscoverHashtag(id: "1", name: "MorningWalk", postCount: 3421),
            isSelected: false,
            onTap: {}
        )
        HashtagChip(
            hashtag: DiscoverHashtag(id: "2", name: "SelfCare", postCount: 5621),
            isSelected: true,
            onTap: {}
        )
    }
    .padding()
    .background(Color.theme.primaryBackground)
}
