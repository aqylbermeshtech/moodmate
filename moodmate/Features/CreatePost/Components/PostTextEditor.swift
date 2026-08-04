//
//  PostTextEditor.swift
//  moodmate
//
//  Created by Antigravity on 31.07.2026.
//

import SwiftUI

struct PostTextEditor: View {
    @Binding var text: String
    let placeholder: String
    let maxLength: Int
    var onEmojiSelected: (String) -> Void
    
    @FocusState private var isEditorFocused: Bool
    
    // Quick emoji bar options
    private let quickEmojis = ["✨", "🌱", "☕️", "🏃‍♂️", "🎧", "☀️", "🌙", "🌊", "🙏", "💖"]
    
    // Quick hashtag options
    private let quickHashtags = ["#mood", "#mindfulness", "#daily", "#gratitude", "#vibes"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack(alignment: .topLeading) {
                // Text editor
                TextEditor(text: $text)
                    .focused($isEditorFocused)
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(Color.theme.primaryText)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 120, maxHeight: 220)
                    // Truncate text if it exceeds the maximum allowed character limit
                    .onChange(of: text) { _, newValue in
                        if newValue.count > maxLength {
                            text = String(newValue.prefix(maxLength))
                        }
                    }
                
                // Placeholder overlay
                if text.isEmpty {
                    Text(placeholder)
                        .font(.system(size: 17, weight: .regular))
                        .foregroundStyle(Color.theme.tertiaryText)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 8)
                        .allowsHitTesting(false)
                }
            }
            
            // Bottom Bar inside editor (Character counter + Quick actions)
            HStack {
                // Quick hashtag chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(quickHashtags, id: \.self) { tag in
                            Button(action: {
                                appendTag(tag)
                            }) {
                                Text(tag)
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(Color.theme.accent)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.theme.accent.opacity(0.1))
                                    .clipShape(Capsule())
                            }
                            .buttonStyle(ScaleButtonStyle())
                        }
                    }
                }
                
                Spacer()
                
                CharacterCounter(currentLength: text.count, maxLength: maxLength)
            }
            
            Divider()
                .background(Color.theme.divider)
            
            // Quick Emoji Input Row
            HStack(spacing: 8) {
                Text("Quick add:")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.theme.secondaryText)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(quickEmojis, id: \.self) { emoji in
                            Button(action: {
                                onEmojiSelected(emoji)
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            }) {
                                Text(emoji)
                                    .font(.system(size: 20))
                                    .padding(4)
                            }
                            .buttonStyle(ScaleButtonStyle())
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.theme.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(isEditorFocused ? Color.theme.accent.opacity(0.6) : Color.theme.border, lineWidth: 1.5)
        )
        .shadow(color: Color.theme.shadow, radius: 8, x: 0, y: 3)
    }
    
    private func appendTag(_ tag: String) {
        if text.isEmpty {
            text = tag + " "
        } else if text.hasSuffix(" ") {
            text += tag + " "
        } else {
            text += " " + tag + " "
        }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
}

#Preview {
    PostTextEditor(
        text: .constant("Having a wonderfully peaceful morning!"),
        placeholder: "What's on your mind today?",
        maxLength: 500,
        onEmojiSelected: { _ in }
    )
    .padding()
    .background(Color.theme.primaryBackground)
}
