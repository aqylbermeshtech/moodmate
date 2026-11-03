//
//  ChatListViewModel.swift
//  moodmate
//

import Foundation
import Combine

@MainActor
final class ChatListViewModel: ObservableObject {

    @Published private(set) var conversations: [Conversation] = []

    private let fetchConversationsUseCase: FetchConversationsUseCaseProtocol

    init(fetchConversationsUseCase: FetchConversationsUseCaseProtocol = DIContainer.shared.fetchConversationsUseCase) {
        self.fetchConversationsUseCase = fetchConversationsUseCase
        loadConversations()
    }

    /// One row per account the user follows. Message history stays empty until
    /// there is a real message store behind it.
    private func loadConversations() {
        conversations = fetchConversationsUseCase.execute()
    }
}
