//
//  ChatListViewModel.swift
//  moodmate
//

import Foundation
import Combine

@MainActor
final class ChatListViewModel: ObservableObject {

    @Published private(set) var conversations: [Conversation] = []

    private let friendsRepository: FriendsRepositoryProtocol

    init(friendsRepository: FriendsRepositoryProtocol = FriendsRepository()) {
        self.friendsRepository = friendsRepository
        loadConversations()
    }

    private func loadConversations() {
        conversations = friendsRepository.loadFriends().map { friend in
            Conversation(
                id: friend.id,
                participant: friend,
                messages: MockChatData.messages(for: friend.id),
                unreadCount: MockChatData.unreadCount(for: friend.id)
            )
        }
    }
}
