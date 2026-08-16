//
//  ChatThreadViewModel.swift
//  moodmate
//

import Foundation
import Combine

@MainActor
final class ChatThreadViewModel: ObservableObject {

    @Published private(set) var participant: MoodUser?
    @Published private(set) var messages: [ChatMessage] = []

    private let userId: String
    private let profileRepository: ProfileRepositoryProtocol

    init(userId: String, profileRepository: ProfileRepositoryProtocol = ProfileRepository.shared) {
        self.userId = userId
        self.profileRepository = profileRepository
        loadThread()
    }

    private func loadThread() {
        guard let profile = profileRepository.getProfile(forId: userId) else { return }

        participant = MoodUser(
            id: profile.id,
            name: profile.displayName,
            username: profile.username,
            avatarImageData: profile.avatarImageData,
            avatarColorHex: profile.avatarColorHex,
            currentMoodEmoji: profile.currentMoodEmoji,
            currentMoodText: profile.currentMoodText,
            currentMoodColorHex: profile.currentMoodColorHex
        )
        messages = MockChatData.messages(for: profile.id)
    }
}
