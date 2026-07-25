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
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                
                Text(formattedCount(hashtag.postCount))
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(isSelected ? .white.opacity(0.7) : .secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background {
                if isSelected {
                    Capsule().fill(Color.teal)
                } else {
                    Capsule().fill(Color(.systemBackground).opacity(0.78))
                }
            }
            .foregroundStyle(isSelected ? .white : .teal)
            .overlay(
                Capsule()
                    .stroke(
                        isSelected ? Color.clear : Color.teal.opacity(0.2),
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(ScaleButtonStyle())
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
}
