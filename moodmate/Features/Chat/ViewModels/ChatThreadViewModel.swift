//
//  ChatThreadViewModel.swift
//  moodmate
//

import Foundation
import Combine

@MainActor
final class ChatThreadViewModel: ObservableObject {

    @Published private(set) var participant: AppUser?
    @Published private(set) var messages: [ChatMessage] = []

    private let userId: String
    private let fetchChatParticipantUseCase: FetchChatParticipantUseCaseProtocol

    init(userId: String, fetchChatParticipantUseCase: FetchChatParticipantUseCaseProtocol = DIContainer.shared.fetchChatParticipantUseCase) {
        self.userId = userId
        self.fetchChatParticipantUseCase = fetchChatParticipantUseCase
        loadThread()
    }

    /// Resolves the participant only. `messages` stays empty until there is a
    /// real message store behind it.
    private func loadThread() {
        participant = fetchChatParticipantUseCase.execute(userId: userId)
    }
}
