//
//  ChatModels.swift
//  moodmate
//

import Foundation

nonisolated struct ChatMessage: Identifiable, Equatable {
    let id: String
    let text: String
    let isFromCurrentUser: Bool
    let timeLabel: String
}

nonisolated struct Conversation: Identifiable, Equatable {
    let id: String
    let participant: AppUser
    let messages: [ChatMessage]
    let unreadCount: Int

    var lastMessage: ChatMessage? { messages.last }
}
