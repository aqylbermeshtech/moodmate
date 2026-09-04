//
//  DiscoverService.swift
//  moodmate
//
//  Created by Nurtore on 26.07.2026.
//

import Foundation

final class DiscoverService: DiscoverServiceProtocol {
    static let shared = DiscoverService()

    /// Fixed topic taxonomy — app-defined browse filters, not user content.
    private var categories: [DiscoverCategory] = []

    private let pageSize = 20
    private let maxHashtags = 20
    private let postRepository: PostRepositoryProtocol
    private let profileRepository: ProfileRepositoryProtocol
    private let followRepository: FollowRepositoryProtocol

    init(
        postRepository: PostRepositoryProtocol = PostRepository.shared,
        profileRepository: ProfileRepositoryProtocol = ProfileRepository.shared,
        followRepository: FollowRepositoryProtocol = FollowRepository.shared
    ) {
        self.postRepository = postRepository
        self.profileRepository = profileRepository
        self.followRepository = followRepository
        setupCategories()
    }

    /// Every known account except the viewer's own, ordered by name so the
    /// row stays stable between loads.
    private var suggestedUsers: [SuggestedUser] {
        let currentUserId = AppSessionManager.currentUserId()
        return profileRepository.allProfiles()
            .filter { $0.id != currentUserId }
            .sorted { $0.displayName.localizedCaseInsensitiveCompare($1.displayName) == .orderedAscending }
            .map { profile in
                SuggestedUser(
                    id: profile.id,
                    displayName: profile.displayName,
                    username: profile.username,
                    avatarColorHex: profile.avatarColorHex,
                    avatarImageData: profile.avatarImageData,
                    bio: profile.bio,
                    isFollowing: profile.isFollowing
                )
            }
    }

    /// The browse grid is a photo wall, so a word-only post has nothing to
    /// show there. Hashtag counts come off the same set, because tapping a tag
    /// filters this grid — a tag counted from posts the grid can't show would
    /// lead straight to an empty result.
    private var discoverablePosts: [PostModel] {
        postRepository.allPosts.filter { !$0.images.isEmpty }
    }

    /// Counted off the real post bodies, so a tag only trends if it's used.
    private var hashtags: [DiscoverHashtag] {
        var counts: [String: Int] = [:]
        var firstSpelling: [String: String] = [:]

        for post in discoverablePosts {
            let tags = Set(Self.hashtags(in: post.text ?? "") + Self.hashtags(in: post.quoteText ?? ""))
            for tag in tags {
                let key = tag.lowercased()
                counts[key, default: 0] += 1
                if firstSpelling[key] == nil { firstSpelling[key] = tag }
            }
        }

        return counts
            .sorted {
                $0.value == $1.value ? $0.key < $1.key : $0.value > $1.value
            }
            .prefix(maxHashtags)
            .map { key, count in
                DiscoverHashtag(id: "h_\(key)", name: firstSpelling[key] ?? key, postCount: count)
            }
    }

    private static func hashtags(in text: String) -> [String] {
        text.split(whereSeparator: { !$0.isLetter && !$0.isNumber && $0 != "#" && $0 != "_" })
            .filter { $0.hasPrefix("#") && $0.count > 1 }
            .map { String($0.dropFirst()) }
    }

    private var gridPosts: [DiscoverPost] {
        discoverablePosts.map(DiscoverPost.init)
    }

    /// Search reaches every post, photo or not: text you wrote should stay
    /// findable by that text even though it never appears in the grid.
    private var searchablePosts: [DiscoverPost] {
        postRepository.allPosts.map(DiscoverPost.init)
    }
    
    // MARK: - Public API
    
    func getSuggestedUsers() async -> [SuggestedUser] {
        try? await Task.sleep(nanoseconds: 400_000_000)
        return suggestedUsers
    }
    
    func getHashtags() async -> [DiscoverHashtag] {
        try? await Task.sleep(nanoseconds: 250_000_000)
        return hashtags
    }
    
    func getCategories() async -> [DiscoverCategory] {
        return categories
    }
    
    func getDiscoverPosts(page: Int, category: DiscoverCategory? = nil, hashtag: DiscoverHashtag? = nil) async -> [DiscoverPost] {
        try? await Task.sleep(nanoseconds: UInt64.random(in: 600_000_000...1_000_000_000))

        var filtered = gridPosts

        // A filter that matches nothing returns nothing — the caller shows an
        // empty state rather than unrelated posts standing in for a match.
        if let category {
            let keyword = category.name.lowercased()
            filtered = filtered.filter { $0.caption.lowercased().contains(keyword) || $0.quoteText.lowercased().contains(keyword) }
        }

        if let hashtag {
            let tag = hashtag.name.lowercased().replacingOccurrences(of: "#", with: "")
            filtered = filtered.filter { $0.caption.lowercased().contains(tag) || $0.quoteText.lowercased().contains(tag) }
        }

        
        let start = page * pageSize
        guard start < filtered.count else { return [] }
        let end = min(start + pageSize, filtered.count)
        return Array(filtered[start..<end])
    }
    
    func search(query: String) async -> [SearchResult] {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else { return [] }
        try? await Task.sleep(nanoseconds: 300_000_000)
        
        let lowered = query.lowercased()
        var results: [SearchResult] = []

        // Search all known accounts (not just the suggestion roster), minus self.
        let currentUserId = AppSessionManager.currentUserId()
        let matchedUsers = profileRepository.allProfiles()
            .filter { $0.id != currentUserId }
            .filter {
                $0.displayName.lowercased().contains(lowered)
                    || $0.username.lowercased().contains(lowered)
                    || $0.bio.lowercased().contains(lowered)
            }
            .sorted { $0.displayName.localizedCaseInsensitiveCompare($1.displayName) == .orderedAscending }

        for profile in matchedUsers {
            results.append(SearchResult(
                id: "sr_user_\(profile.id)",
                type: .user,
                userId: profile.id,
                userName: profile.displayName,
                username: profile.username,
                avatarColorHex: profile.avatarColorHex,
                avatarImageData: profile.avatarImageData,
                userBio: profile.bio
            ))
        }

        for post in searchablePosts where post.quoteText.lowercased().contains(lowered) || post.caption.lowercased().contains(lowered) {
            results.append(SearchResult(
                id: "sr_post_\(post.id)",
                type: .post,
                postQuote: post.quoteText,
                postCaption: post.caption,
                postImage: post.images.first,
                postGradientStartHex: post.gradientStartHex,
                postGradientEndHex: post.gradientEndHex,
                postLikesCount: post.likesCount,
                postUserId: post.userId
            ))
        }

        for tag in hashtags where tag.name.lowercased().contains(lowered) {
            results.append(SearchResult(
                id: "sr_tag_\(tag.id)",
                type: .hashtag,
                hashtagName: tag.name,
                hashtagPostCount: tag.postCount
            ))
        }
        
        return results
    }
    
    func toggleFollow(userId: String) {
        _ = followRepository.toggleFollow(targetId: userId)
    }

    // MARK: - Topic Setup

    private func setupCategories() {
        categories = [
            DiscoverCategory(id: "c1",  name: "Photography", iconName: "camera.fill",           gradientStartHex: "667EEA", gradientEndHex: "764BA2"),
            DiscoverCategory(id: "c2",  name: "Travel",      iconName: "airplane",               gradientStartHex: "F093FB", gradientEndHex: "F5576C"),
            DiscoverCategory(id: "c3",  name: "Nature",      iconName: "leaf.fill",              gradientStartHex: "4FACFE", gradientEndHex: "00F2FE"),
            DiscoverCategory(id: "c4",  name: "Food",        iconName: "fork.knife",             gradientStartHex: "FA709A", gradientEndHex: "FEE140"),
            DiscoverCategory(id: "c5",  name: "Fitness",     iconName: "figure.run",             gradientStartHex: "A18CD1", gradientEndHex: "FBC2EB"),
            DiscoverCategory(id: "c6",  name: "Art",         iconName: "paintpalette.fill",      gradientStartHex: "FF9A9E", gradientEndHex: "FECFEF"),
            DiscoverCategory(id: "c7",  name: "Music",       iconName: "music.note",             gradientStartHex: "A1C4FD", gradientEndHex: "C2E9FB"),
            DiscoverCategory(id: "c8",  name: "Study",       iconName: "book.fill",              gradientStartHex: "D4FC79", gradientEndHex: "96E6A1"),
            DiscoverCategory(id: "c9",  name: "Gaming",      iconName: "gamecontroller.fill",    gradientStartHex: "84FAB0", gradientEndHex: "8FD3F4"),
            DiscoverCategory(id: "c10", name: "Lifestyle",   iconName: "sparkles",               gradientStartHex: "FFECD2", gradientEndHex: "FCB69F")
        ]
    }
}
