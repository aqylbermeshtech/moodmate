//
//  MessageBubble.swift
//  moodmate
//

import SwiftUI

struct MessageBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            if message.isFromCurrentUser { Spacer(minLength: 40) }

            VStack(alignment: message.isFromCurrentUser ? .trailing : .leading, spacing: 4) {
                Text(message.text)
                    .font(.system(size: 14))
                    .foregroundStyle(message.isFromCurrentUser ? .white : Color.theme.primaryText)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(message.isFromCurrentUser ? Color.theme.accent : Color.theme.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay {
                        if !message.isFromCurrentUser {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(Color.theme.border, lineWidth: 1)
                        }
                    }

                Text(message.timeLabel)
                    .font(.system(size: 10))
                    .foregroundStyle(Color.theme.tertiaryText)
            }

            if !message.isFromCurrentUser { Spacer(minLength: 40) }
        }
    }
}
