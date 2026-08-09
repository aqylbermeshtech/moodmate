//
//  MoodPickerCard.swift
//  moodmate
//
//  Created by Antigravity on 31.07.2026.
//

import SwiftUI

struct MoodPickerCard: View {
    let selectedMoodEmoji: String?
    let selectedMoodText: String?
    let selectedMoodColorHex: String?
    var onTap: () -> Void
    
    private var activeColor: Color {
        if let colorHex = selectedMoodColorHex {
            return Color.adaptiveMoodColor(hex: colorHex)
        }
        return Color.theme.accent
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(activeColor.opacity(0.14))
                        .frame(width: 52, height: 52)
                    
                    Text(selectedMoodEmoji ?? "➕")
                        .font(.system(size: 26))
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(selectedMoodEmoji != nil ? "Mood Selected" : "How are you feeling?")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(activeColor)
                        .textCase(.uppercase)
                    
                    if let emoji = selectedMoodEmoji, let text = selectedMoodText {
                        Text("\(emoji) Feeling \(text)")
                            .font(.body.weight(.medium))
                            .foregroundStyle(Color.theme.primaryText)
                    } else {
                        Text("Tap to select your mood")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(Color.theme.secondaryText)
                    }
                }
                
                Spacer()
                
                HStack(spacing: 6) {
                    Text(selectedMoodEmoji != nil ? "Change" : "Choose")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(activeColor)
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(activeColor)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(activeColor.opacity(0.12))
                .clipShape(Capsule())
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                    .fill(Color.theme.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                    .stroke(
                        selectedMoodEmoji != nil ? activeColor.opacity(0.6) : Color.theme.border,
                        lineWidth: 0.5
                    )
            )
            .shadow(color: Color.theme.shadow, radius: AppShadow.radius, y: AppShadow.y)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

#Preview {
    VStack(spacing: 16) {
        MoodPickerCard(
            selectedMoodEmoji: "😊",
            selectedMoodText: "Happy",
            selectedMoodColorHex: "38B2AC",
            onTap: {}
        )
        MoodPickerCard(
            selectedMoodEmoji: nil,
            selectedMoodText: nil,
            selectedMoodColorHex: nil,
            onTap: {}
        )
    }
    .padding()
    .background(Color.theme.primaryBackground)
}
