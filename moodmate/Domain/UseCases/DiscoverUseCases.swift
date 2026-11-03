//
//  DiscoverUseCases.swift
//  moodmate
//
//  Discover/search use cases — thin boundaries over the discover service,
//  one per user-facing capability.
//

import Foundation

nonisolated protocol FetchSuggestedUsersUseCaseProtocol {
    func execute() async -> [SuggestedUser]
}

nonisolated final class FetchSuggestedUsersUseCase: FetchSuggestedUsersUseCaseProtocol {
    private let discoverService: DiscoverServiceProtocol

    init(discoverService: DiscoverServiceProtocol) {
        self.discoverService = discoverService
    }

    func execute() async -> [SuggestedUser] {
        await discoverService.getSuggestedUsers()
    }
}

nonisolated protocol FetchTrendingHashtagsUseCaseProtocol {
    func execute() async -> [DiscoverHashtag]
}

nonisolated final class FetchTrendingHashtagsUseCase: FetchTrendingHashtagsUseCaseProtocol {
    private let discoverService: DiscoverServiceProtocol

    init(discoverService: DiscoverServiceProtocol) {
        self.discoverService = discoverService
    }

    func execute() async -> [DiscoverHashtag] {
        await discoverService.getHashtags()
    }
}

nonisolated protocol FetchDiscoverCategoriesUseCaseProtocol {
    func execute() async -> [DiscoverCategory]
}

nonisolated final class FetchDiscoverCategoriesUseCase: FetchDiscoverCategoriesUseCaseProtocol {
    private let discoverService: DiscoverServiceProtocol

    init(discoverService: DiscoverServiceProtocol) {
        self.discoverService = discoverService
    }

    func execute() async -> [DiscoverCategory] {
        await discoverService.getCategories()
    }
}

nonisolated protocol FetchDiscoverPostsUseCaseProtocol {
    func execute(page: Int, category: DiscoverCategory?, hashtag: DiscoverHashtag?) async -> [DiscoverPost]
}

nonisolated final class FetchDiscoverPostsUseCase: FetchDiscoverPostsUseCaseProtocol {
    private let discoverService: DiscoverServiceProtocol

    init(discoverService: DiscoverServiceProtocol) {
        self.discoverService = discoverService
    }

    func execute(page: Int, category: DiscoverCategory?, hashtag: DiscoverHashtag?) async -> [DiscoverPost] {
        await discoverService.getDiscoverPosts(page: page, category: category, hashtag: hashtag)
    }
}

nonisolated protocol SearchDiscoverUseCaseProtocol {
    func execute(query: String) async -> [SearchResult]
}

nonisolated final class SearchDiscoverUseCase: SearchDiscoverUseCaseProtocol {
    private let discoverService: DiscoverServiceProtocol

    init(discoverService: DiscoverServiceProtocol) {
        self.discoverService = discoverService
    }

    func execute(query: String) async -> [SearchResult] {
        await discoverService.search(query: query)
    }
}
