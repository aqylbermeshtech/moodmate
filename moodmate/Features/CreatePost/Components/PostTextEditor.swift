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
    @FocusState private var isEditorFocused: Bool

    private let quickHashtags = ["#mindfulness", "#daily", "#gratitude", "#vibes"]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack(alignment: .topLeading) {
                TextEditor(text: $text)
                    .focused($isEditorFocused)
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(Color.theme.primaryText)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 120, maxHeight: 220)
                    .onChange(of: text) { _, newValue in
                        if newValue.count > maxLength {
                            text = String(newValue.prefix(maxLength))
                        }
                    }
                if text.isEmpty {
                    Text(placeholder)
                        .font(.system(size: 17, weight: .regular))
                        .foregroundStyle(Color.theme.tertiaryText)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 8)
                        .allowsHitTesting(false)
                }
            }
            HStack {
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
        maxLength: 500
    )
    .padding()
    .background(Color.theme.primaryBackground)
}
