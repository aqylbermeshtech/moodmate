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
            VStack(spacing: 6) {
                AvatarView(
                    imageData: user.avatarImageData,
                    name: user.name,
                    colorHex: user.avatarColorHex,
                    size: 48,
                    showBorder: false,
                    moodEmoji: user.currentMoodEmoji
                )

                Text(user.name)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundStyle(Color.theme.secondaryText)
                    .lineLimit(1)
                    .frame(maxWidth: 56)
            }
        }
        .buttonStyle(XPressableStyle(pressedScale: 0.95))
    }

}

#Preview {
    HStack(spacing: 16) {
        FriendAvatar(user: MoodUser(
            id: "1", name: "Pepper", username: "pepperoni", avatarImageName: nil,
            avatarColorHex: "FF6B6B", currentMoodEmoji: "😊", currentMoodText: "Happy", currentMoodColorHex: "38B2AC"
        ), onTap: {})

        FriendAvatar(user: MoodUser(
            id: "2", name: "Michele", username: "mj", avatarImageName: nil,
            avatarColorHex: "4DABF7", currentMoodEmoji: "😌", currentMoodText: "Calm", currentMoodColorHex: "4A5568"
        ), onTap: {})
    }
    .padding()
    .background(Color.theme.primaryBackground)
}
