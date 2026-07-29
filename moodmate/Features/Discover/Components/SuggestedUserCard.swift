//
//  SuggestedUserCard.swift
//  moodmate
//
//  Created by Nurtore on 26.07.2026.
//

import SwiftUI

struct SuggestedUserCard: View {
    let user: SuggestedUser
    var onFollow: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack(alignment: .bottomTrailing) {
                ZStack {
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color(hex: user.moodColorHex ?? "38B2AC"),
                                    Color(hex: user.avatarColorHex)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2.5
                        )
                        .frame(width: 62, height: 62)
                    
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: user.avatarColorHex).opacity(0.85), Color(hex: user.avatarColorHex)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        Text(getInitials(user.displayName))
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                    }
                    .frame(width: 52, height: 52)
                }
                
                if let emoji = user.moodEmoji {
                    ZStack {
                        Circle()
                            .fill(Color.theme.surface)
                            .frame(width: 22, height: 22)
                            .shadow(color: Color.theme.shadow, radius: 3, x: 0, y: 1.5)
                        
                        Text(emoji)
                            .font(.system(size: 12))
                    }
                }
            }
            
            // User info
            VStack(spacing: 2) {
                Text(user.displayName)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.theme.primaryText)
                    .lineLimit(1)
                
                Text("@\(user.username)")
                    .font(.system(size: 11))
                    .foregroundStyle(Color.theme.secondaryText)
                    .lineLimit(1)
                
                if let moodText = user.moodText, let emoji = user.moodEmoji {
                    HStack(spacing: 3) {
                        Text(emoji)
                            .font(.system(size: 9))
                        Text(moodText)
                            .font(.system(size: 9, weight: .bold))
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.adaptiveMoodColor(hex: user.moodColorHex ?? "38B2AC").opacity(0.15))
                    .foregroundStyle(Color.adaptiveMoodColor(hex: user.moodColorHex ?? "38B2AC"))
                    .clipShape(Capsule())
                    .padding(.top, 2)
                }
            }
            
            // Follow button
            Button(action: onFollow) {
                Text(user.isFollowing ? "Following" : "Follow")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(user.isFollowing ? Color.theme.secondaryText : Color.white)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 7)
                    .background {
                        if user.isFollowing {
                            Capsule()
                                .fill(Color.theme.groupedBackground)
                        } else {
                            Capsule()
                                .fill(Color.teal)
                        }
                    }
            }
            .buttonStyle(ScaleButtonStyle())
        }
        .frame(width: 130)
        .padding(.vertical, 16)
        .padding(.horizontal, 8)
        .background(Color.theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.theme.border, lineWidth: 1)
        )
        .shadow(color: Color.theme.shadow, radius: 8, x: 0, y: 4)
    }
    
}

#Preview {
    HStack(spacing: 12) {
        SuggestedUserCard(
            user: SuggestedUser(
                id: "1", displayName: "Luna Park", username: "luna_glow",
                avatarColorHex: "ED64A6", bio: "Night owl.", moodEmoji: "🌙",
                moodText: "Dreamy", moodColorHex: "805AD5", isFollowing: false
            ),
            onFollow: {}
        )
        SuggestedUserCard(
            user: SuggestedUser(
                id: "2", displayName: "River Stone", username: "river_flows",
                avatarColorHex: "38B2AC", bio: "Kayaker.", moodEmoji: "🌊",
                moodText: "Flowing", moodColorHex: "4DABF7", isFollowing: true
            ),
            onFollow: {}
        )
    }
    .padding()
    .background(Color.teal.opacity(0.1))
}
