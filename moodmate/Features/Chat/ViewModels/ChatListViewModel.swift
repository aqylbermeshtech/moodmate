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

    /// One row per account the user follows. Message history stays empty until
    /// there is a real message store behind it.
    private func loadConversations() {
        conversations = friendsRepository.loadFriends().map { friend in
            Conversation(
                id: friend.id,
                participant: friend,
                messages: [],
                unreadCount: 0
            )
        }
    }
}
