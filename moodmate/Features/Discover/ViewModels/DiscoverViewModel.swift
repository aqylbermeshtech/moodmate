//
//  DiscoverViewModel.swift
//  moodmate
//
//  Created by Nurtore on 26.07.2026.
//

import SwiftUI
import Combine

@MainActor
final class DiscoverViewModel: ObservableObject {
    
    // MARK: - Published State

    @Published var discoverPosts: [DiscoverPost] = []
    @Published var trendingMoods: [TrendingMood] = []
    @Published var suggestedUsers: [SuggestedUser] = []
    @Published var trendingHashtags: [DiscoverHashtag] = []
    @Published var categories: [DiscoverCategory] = []
    
    @Published var selectedMood: TrendingMood? = nil
    @Published var selectedCategory: DiscoverCategory? = nil
    @Published var selectedHashtag: DiscoverHashtag? = nil
    
    @Published var searchText: String = ""
    @Published var searchResults: [SearchResult] = []
    @Published var recentSearches: [String] = []
    @Published var searchScope: SearchScope = .all
    @Published var isSearchActive: Bool = false
    
    @Published var isLoading: Bool = true
    @Published var isLoadingMore: Bool = false
    @Published var hasMorePages: Bool = true
    @Published var errorMessage: String? = nil
    
    // MARK: - Private
    
    private var currentPage = 0
    private var cancellables = Set<AnyCancellable>()
    private let recentSearchesKey = "moodmate_recent_searches"
    
    var hasActiveFilter: Bool {
        selectedMood != nil || selectedCategory != nil || selectedHashtag != nil
    }
    
    var activeFilterLabel: String {
        if let mood = selectedMood { return "\(mood.emoji) \(mood.name)" }
        if let category = selectedCategory { return category.name }
        if let hashtag = selectedHashtag { return "#\(hashtag.name)" }
        return ""
    }
    
    var filteredSearchResults: [SearchResult] {
        switch searchScope {
        case .all:
            return searchResults
        case .users:
            return searchResults.filter { $0.type == .user }
        case .posts:
            return searchResults.filter { $0.type == .post }
        case .moods:
            return searchResults.filter { $0.type == .mood }
        case .hashtags:
            return searchResults.filter { $0.type == .hashtag }
        }
    }
    
    // MARK: - Init
    
    private let discoverService: DiscoverServiceProtocol
    private let  profileService: ProfileServiceProtocol
    
    init(
        discoverService: DiscoverServiceProtocol = DiscoverService.shared,
        profileService: ProfileServiceProtocol = ProfileService.shared
    ) {
        self.discoverService = discoverService
        self.profileService = profileService
        loadRecentSearches()
        setupSearchDebounce()
        observeProfileUpdates()
    }
    
    private func observeProfileUpdates() {
        profileService.profileUpdatesPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] updatedProfile in
                guard let self = self else { return }

                if let index = self.suggestedUsers.firstIndex(where: { $0.id == updatedProfile.id }) {
                    self.suggestedUsers[index] = SuggestedUser(
                        id: updatedProfile.id,
                        displayName: updatedProfile.displayName,
                        username: updatedProfile.username,
                        avatarColorHex: updatedProfile.avatarColorHex,
                        avatarImageData: updatedProfile.avatarImageData,
                        bio: updatedProfile.bio,
                        moodEmoji: updatedProfile.currentMoodEmoji,
                        moodText: updatedProfile.currentMoodText,
                        moodColorHex: updatedProfile.currentMoodColorHex,
                        isFollowing: self.suggestedUsers[index].isFollowing
                    )
                }

                for i in 0..<self.discoverPosts.count {
                    if self.discoverPosts[i].userId == updatedProfile.id {
                        let oldPost = self.discoverPosts[i]
                        self.discoverPosts[i] = DiscoverPost(
                            id: oldPost.id,
                            userId: oldPost.userId,
                            userName: updatedProfile.displayName,
                            username: updatedProfile.username,
                            avatarColorHex: updatedProfile.avatarColorHex,
                            moodEmoji: oldPost.moodEmoji,
                            moodText: oldPost.moodText,
                            moodColorHex: oldPost.moodColorHex,
                            quoteText: oldPost.quoteText,
                            caption: oldPost.caption,
                            gradientStartHex: oldPost.gradientStartHex,
                            gradientEndHex: oldPost.gradientEndHex,
                            likesCount: oldPost.likesCount,
                            commentsCount: oldPost.commentsCount,
                            isLiked: oldPost.isLiked,
                            heightClass: oldPost.heightClass,
                            createdAt: oldPost.createdAt
                        )
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Data Loading
    
    func loadInitialData() async {
        isLoading = true
        errorMessage = nil
        currentPage = 0
        
        async let moods = discoverService.getTrendingMoods()
        async let users = discoverService.getSuggestedUsers()
        async let tags = discoverService.getHashtags()
        async let cats = discoverService.getCategories()
        async let posts = discoverService.getDiscoverPosts(page: 0)
        
        self.trendingMoods = await moods
        self.suggestedUsers = await users
        self.trendingHashtags = await tags
        self.categories = await cats
        self.discoverPosts = await posts
        self.hasMorePages = self.discoverPosts.count >= 20
        
        withAnimation(.easeOut(duration: 0.3)) {
            self.isLoading = false
        }
    }
    
    func loadMorePosts() async {
        guard !isLoadingMore && hasMorePages else { return }
        
        isLoadingMore = true
        currentPage += 1
        
        let newPosts = await discoverService.getDiscoverPosts(
            page: currentPage,
            mood: selectedMood,
            category: selectedCategory,
            hashtag: selectedHashtag
        )
        
        if newPosts.isEmpty {
            hasMorePages = false
        } else {
            discoverPosts.append(contentsOf: newPosts)
        }
        
        isLoadingMore = false
    }
    
    func refresh() async {
        currentPage = 0
        hasMorePages = true
        errorMessage = nil
        
        let posts = await discoverService.getDiscoverPosts(
            page: 0,
            mood: selectedMood,
            category: selectedCategory,
            hashtag: selectedHashtag
        )
        
        withAnimation(.easeOut(duration: 0.3)) {
            self.discoverPosts = posts
            self.hasMorePages = posts.count >= 20
        }
    }
    
    // MARK: - Filters
    
    func selectMood(_ mood: TrendingMood) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            if selectedMood == mood {
                selectedMood = nil
            } else {
                selectedMood = mood
                selectedCategory = nil
                selectedHashtag = nil
            }
        }
        
        Task { await reloadFilteredPosts() }
    }
    
    func selectCategory(_ category: DiscoverCategory) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            if selectedCategory == category {
                selectedCategory = nil
            } else {
                selectedCategory = category
                selectedMood = nil
                selectedHashtag = nil
            }
        }
        
        Task { await reloadFilteredPosts() }
    }
    
    func selectHashtag(_ hashtag: DiscoverHashtag) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            if selectedHashtag == hashtag {
                selectedHashtag = nil
            } else {
                selectedHashtag = hashtag
                selectedMood = nil
                selectedCategory = nil
            }
        }
        
        Task { await reloadFilteredPosts() }
    }
    
    func clearFilters() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            selectedMood = nil
            selectedCategory = nil
            selectedHashtag = nil
        }
        
        Task { await reloadFilteredPosts() }
    }
    
    private func reloadFilteredPosts() async {
        currentPage = 0
        hasMorePages = true
        
        let posts = await discoverService.getDiscoverPosts(
            page: 0,
            mood: selectedMood,
            category: selectedCategory,
            hashtag: selectedHashtag
        )
        
        withAnimation(.easeOut(duration: 0.3)) {
            self.discoverPosts = posts
            self.hasMorePages = posts.count >= 20
        }
    }
    
    // MARK: - Search
    
    private func setupSearchDebounce() {
        $searchText
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] query in
                guard let self else { return }
                Task {
                    await self.performSearch(query: query)
                }
            }
            .store(in: &cancellables)
    }
    
    private func performSearch(query: String) async {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            withAnimation(.easeOut(duration: 0.2)) {
                self.searchResults = []
            }
            return
        }
        
        let results = await discoverService.search(query: query)
        
        withAnimation(.easeOut(duration: 0.2)) {
            self.searchResults = results
        }
    }
    
    func addRecentSearch(_ query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        
        recentSearches.removeAll { $0.lowercased() == trimmed.lowercased() }
        recentSearches.insert(trimmed, at: 0)
        
        if recentSearches.count > 10 {
            recentSearches = Array(recentSearches.prefix(10))
        }
        
        saveRecentSearches()
    }
    
    func clearRecentSearches() {
        recentSearches = []
        saveRecentSearches()
    }
    
    private func loadRecentSearches() {
        recentSearches = UserDefaults.standard.stringArray(forKey: recentSearchesKey) ?? []
    }
    
    private func saveRecentSearches() {
        UserDefaults.standard.set(recentSearches, forKey: recentSearchesKey)
    }
    
    // MARK: - Actions
    
    func toggleFollow(user: SuggestedUser) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            discoverService.toggleFollow(userId: user.id)
            if let index = suggestedUsers.firstIndex(where: { $0.id == user.id }) {
                suggestedUsers[index].isFollowing.toggle()
            }
        }
    }
    
    func toggleLike(post: DiscoverPost) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            discoverService.toggleLike(postId: post.id)
            if let index = discoverPosts.firstIndex(where: { $0.id == post.id }) {
                discoverPosts[index].isLiked.toggle()
                discoverPosts[index].likesCount += discoverPosts[index].isLiked ? 1 : -1
            }
        }
    }
}
