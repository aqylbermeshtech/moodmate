//
//  ChatUseCases.swift
//  moodmate
//
//  Chat use cases. Messaging itself is unimplemented (no message store
//  yet) — these cover the conversation list and thread participant.
//

import Foundation

// MARK: - Conversations

nonisolated protocol FetchConversationsUseCaseProtocol {
    func execute() -> [Conversation]
}

/// One conversation per account the user follows. Message history stays
/// empty until there is a real message store behind it.
nonisolated final class FetchConversationsUseCase: FetchConversationsUseCaseProtocol {
    private let friendsRepository: FriendsRepositoryProtocol

    init(friendsRepository: FriendsRepositoryProtocol) {
        self.friendsRepository = friendsRepository
    }

    func execute() -> [Conversation] {
        friendsRepository.loadFriends().map { friend in
            Conversation(
                id: friend.id,
                participant: friend,
                messages: [],
                unreadCount: 0
            )
        }
    }
}

// MARK: - Thread Participant

nonisolated protocol FetchChatParticipantUseCaseProtocol {
    func execute(userId: String) -> AppUser?
}

nonisolated final class FetchChatParticipantUseCase: FetchChatParticipantUseCaseProtocol {
    private let profileRepository: ProfileRepositoryProtocol

    init(profileRepository: ProfileRepositoryProtocol) {
        self.profileRepository = profileRepository
    }

    func execute(userId: String) -> AppUser? {
        guard let profile = profileRepository.getProfile(forId: userId) else { return nil }
        return AppUser(
            id: profile.id,
            name: profile.displayName,
            username: profile.username,
            avatarImageName: profile.avatarImageName,
            avatarImageData: profile.avatarImageData,
            avatarColorHex: profile.avatarColorHex
        )
    }
}
