//
//  FriendAvatar.swift
//  moodmate
//
//  Created by Nurtore on 22.07.2026.
//

import SwiftUI

struct FriendAvatar: View {
    let user: MoodUser
    var onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                ZStack(alignment: .bottomTrailing) {
                    // Profile Circle
                    ZStack {
                        // Outer ring gradient representing mood vitality
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color(hex: user.currentMoodColorHex ?? "38B2AC"),
                                        Color(hex: user.avatarColorHex)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2.5
                            )
                            .frame(width: 68, height: 68)
                        
                        // Inner initials circle
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color(hex: user.avatarColorHex).opacity(0.85), Color(hex: user.avatarColorHex)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            
                            Text(getInitials(user.name))
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                        }
                        .frame(width: 58, height: 58)
                    }
                    
                    // Mood Emoji Badge overlay
                    if let emoji = user.currentMoodEmoji {
                        ZStack {
                            Circle()
                                .fill(Color(.systemBackground))
                                .frame(width: 24, height: 24)
                                .shadow(color: .black.opacity(0.12), radius: 3, x: 0, y: 1.5)
                            
                            Text(emoji)
                                .font(.system(size: 14))
                        }
                        .transition(.scale)
                    }
                }
                
                // User Name label
                Text(user.name)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(.primary.opacity(0.8))
                    .lineLimit(1)
                    .frame(maxWidth: 72)
            }
        }
        .buttonStyle(ScaleButtonStyle())
    }
    
    private func getInitials(_ name: String) -> String {
        let parts = name.split(separator: " ")
        if parts.count >= 2, let first = parts[0].first, let second = parts[1].first {
            return "\(first)\(second)".uppercased()
        } else if let first = name.first {
            return String(first).uppercased()
        }
        return "?"
    }
}

#Preview {
    HStack(spacing: 16) {
        FriendAvatar(user: MoodUser(
            id: "1", name: "Alex", username: "alex", avatarImageName: nil,
            avatarColorHex: "FF6B6B", currentMoodEmoji: "😊", currentMoodText: "Happy", currentMoodColorHex: "38B2AC"
        ), onTap: {})
        
        FriendAvatar(user: MoodUser(
            id: "2", name: "Emma", username: "emma", avatarImageName: nil,
            avatarColorHex: "4DABF7", currentMoodEmoji: "😌", currentMoodText: "Calm", currentMoodColorHex: "4A5568"
        ), onTap: {})
    }
    .padding()
    .background(Color.teal.opacity(0.1))
}
