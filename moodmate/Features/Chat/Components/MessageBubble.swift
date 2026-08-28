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
                    .font(.xDMBody)
                    .foregroundStyle(message.isFromCurrentUser ? .white : Color.theme.primaryText)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        message.isFromCurrentUser
                            ? Color.theme.accent
                            : Color.theme.secondaryBackground
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .overlay {
                        if !message.isFromCurrentUser {
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(Color.theme.divider, lineWidth: 1)
                        }
                    }

                Text(message.timeLabel)
                    .font(.xDMTimestamp)
                    .foregroundStyle(Color.theme.secondaryText)
            }

            if !message.isFromCurrentUser { Spacer(minLength: 40) }
        }
    }
}
