//
//  MockChatData.swift
//  moodmate
//

import Foundation

/// Per-friend canned chat history, shared by ChatListViewModel and
/// ChatThreadViewModel so both show the same conversation for a friend id.
enum MockChatData {

    static func unreadCount(for friendId: String) -> Int {
        switch friendId {
        case "2": return 2
        case "4": return 1
        default: return 0
        }
    }

    static func messages(for friendId: String) -> [ChatMessage] {
        switch friendId {
        case "1":
            return [
                ChatMessage(id: UUID().uuidString, text: "Hey! How's your week going?", isFromCurrentUser: false, timeLabel: "Mon 9:14 AM"),
                ChatMessage(id: UUID().uuidString, text: "Pretty good, just posted about my morning", isFromCurrentUser: true, timeLabel: "Mon 9:20 AM"),
                ChatMessage(id: UUID().uuidString, text: "Nice, saw that one. Love it", isFromCurrentUser: false, timeLabel: "Mon 9:22 AM")
            ]
        case "2":
            return [
                ChatMessage(id: UUID().uuidString, text: "Saw your post about the calm walk, looked so peaceful", isFromCurrentUser: false, timeLabel: "Yesterday 6:40 PM"),
                ChatMessage(id: UUID().uuidString, text: "It really helped me reset before bed", isFromCurrentUser: true, timeLabel: "Yesterday 6:52 PM"),
                ChatMessage(id: UUID().uuidString, text: "We should go together sometime", isFromCurrentUser: false, timeLabel: "Yesterday 6:53 PM"),
                ChatMessage(id: UUID().uuidString, text: "Same time this weekend?", isFromCurrentUser: false, timeLabel: "Today 8:02 AM")
            ]
        case "3":
            return [
                ChatMessage(id: UUID().uuidString, text: "Standup notes are in the shared doc", isFromCurrentUser: false, timeLabel: "Fri 11:05 AM"),
                ChatMessage(id: UUID().uuidString, text: "Thanks, will check before the call", isFromCurrentUser: true, timeLabel: "Fri 11:10 AM")
            ]
        case "4":
            return [
                ChatMessage(id: UUID().uuidString, text: "Happy to hear you're doing better this week!", isFromCurrentUser: false, timeLabel: "Today 7:15 AM")
            ]
        default:
            return [
                ChatMessage(id: UUID().uuidString, text: "Hey, long time no chat!", isFromCurrentUser: false, timeLabel: "2 weeks ago"),
                ChatMessage(id: UUID().uuidString, text: "I know, let's catch up soon", isFromCurrentUser: true, timeLabel: "2 weeks ago")
            ]
        }
    }
}
