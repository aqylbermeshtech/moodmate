//
//  CreatePostUseCases.swift
//  moodmate
//
//  Post composition use cases. UIImage ↔ base64 conversion stays in the
//  presentation layer; these speak only in domain types.
//

import Foundation

// MARK: - Create Post

nonisolated protocol CreatePostUseCaseProtocol {
    func execute(text: String, imageBase64Strings: [String], visibility: Visibility) async throws -> PostModel
}

nonisolated final class CreatePostUseCase: CreatePostUseCaseProtocol {
    private let postRepository: PostRepositoryProtocol
    private let currentUserProvider: CurrentUserProviderProtocol

    init(postRepository: PostRepositoryProtocol, currentUserProvider: CurrentUserProviderProtocol) {
        self.postRepository = postRepository
        self.currentUserProvider = currentUserProvider
    }

    func execute(text: String, imageBase64Strings: [String], visibility: Visibility) async throws -> PostModel {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let newPost = PostModel(
            id: "post_\(UUID().uuidString.prefix(8))",
            authorId: currentUserProvider.currentUserId,
            text: trimmed.isEmpty ? nil : text,
            images: imageBase64Strings,
            visibility: visibility,
            createdAt: Date(),
            likesCount: 0,
            commentsCount: 0,
            bookmarksCount: 0,
            isLiked: false,
            isBookmarked: false,
            gradientStartHex: "38B2AC",
            gradientEndHex: "805AD5"
        )
        return try await postRepository.createPost(newPost)
    }
}

// MARK: - Drafts

nonisolated protocol SavePostDraftUseCaseProtocol {
    func execute(_ draft: PostDraft)
}

nonisolated final class SavePostDraftUseCase: SavePostDraftUseCaseProtocol {
    private let draftStore: DraftStoreProtocol

    init(draftStore: DraftStoreProtocol) {
        self.draftStore = draftStore
    }

    func execute(_ draft: PostDraft) {
        draftStore.saveDraft(draft)
    }
}

nonisolated protocol LoadPostDraftUseCaseProtocol {
    func execute() -> PostDraft?
}

nonisolated final class LoadPostDraftUseCase: LoadPostDraftUseCaseProtocol {
    private let draftStore: DraftStoreProtocol

    init(draftStore: DraftStoreProtocol) {
        self.draftStore = draftStore
    }

    func execute() -> PostDraft? {
        draftStore.loadDraft()
    }
}

nonisolated protocol ClearPostDraftUseCaseProtocol {
    func execute()
}

nonisolated final class ClearPostDraftUseCase: ClearPostDraftUseCaseProtocol {
    private let draftStore: DraftStoreProtocol

    init(draftStore: DraftStoreProtocol) {
        self.draftStore = draftStore
    }

    func execute() {
        draftStore.clearDraft()
    }
}
