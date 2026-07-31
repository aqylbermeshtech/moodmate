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
                    // Profile Circle with AvatarView
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
                        
                        AvatarView(
                            imageData: user.avatarImageData,
                            name: user.name,
                            colorHex: user.avatarColorHex,
                            size: 58,
                            showBorder: false,
                            moodEmoji: user.currentMoodEmoji
                        )
                    }
                }
                
                // User Name label
                Text(user.name)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.theme.primaryText.opacity(0.85))
                    .lineLimit(1)
                    .frame(maxWidth: 72)
            }
        }
        .buttonStyle(ScaleButtonStyle())
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
