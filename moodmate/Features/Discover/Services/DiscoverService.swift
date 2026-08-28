//
//  DiscoverService.swift
//  moodmate
//
//  Created by Nurtore on 26.07.2026.
//

import Foundation

final class DiscoverService: DiscoverServiceProtocol {
    static let shared = DiscoverService()

    private var suggestedUsers: [SuggestedUser] = []
    private var hashtags: [DiscoverHashtag] = []
    private var categories: [DiscoverCategory] = []

    private let pageSize = 20
    private let postRepository: PostRepositoryProtocol
    private let profileRepository: ProfileRepositoryProtocol

    init(
        postRepository: PostRepositoryProtocol = PostRepository.shared,
        profileRepository: ProfileRepositoryProtocol = ProfileRepository.shared
    ) {
        self.postRepository = postRepository
        self.profileRepository = profileRepository
        setupMockData()
        publishSuggestedUserProfiles()
    }

    /// suggestedUsers is the one canonical roster for these 25 mock
    /// identities. Publishing them into ProfileRepository (if not already
    /// present) lets UserStore resolve display names for the generated
    /// Discover posts authored by them, without a second copy of the same
    /// roster living in PostRepository's seed data.
    private func publishSuggestedUserProfiles() {
        for user in suggestedUsers where profileRepository.getProfile(forId: user.id) == nil {
            profileRepository.setProfile(UserProfile(
                id: user.id,
                displayName: user.displayName,
                username: user.username,
                avatarColorHex: user.avatarColorHex,
                avatarImageData: user.avatarImageData,
                bio: user.bio
            ))
        }
    }

    /// All posts, projected fresh from the shared repository on every call
    /// so likes/bookmarks made in Feed or Profile are reflected here too.
    private var allPosts: [DiscoverPost] {
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

        var filtered = allPosts

        if let category {
            let keyword = category.name.lowercased()
            filtered = filtered.filter { $0.caption.lowercased().contains(keyword) || $0.quoteText.lowercased().contains(keyword) }
            if filtered.isEmpty {
                filtered = allPosts.shuffled().prefix(30).map { $0 }
            }
        }
        
        if let hashtag {
            let tag = hashtag.name.lowercased()
            filtered = filtered.filter { $0.caption.lowercased().contains(tag.replacingOccurrences(of: "#", with: "")) }
            if filtered.isEmpty {
                filtered = allPosts.shuffled().prefix(20).map { $0 }
            }
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

        for user in suggestedUsers where user.displayName.lowercased().contains(lowered) || user.username.lowercased().contains(lowered) {
            results.append(SearchResult(
                id: "sr_user_\(user.id)",
                type: .user,
                userId: user.id,
                userName: user.displayName,
                username: user.username,
                avatarColorHex: user.avatarColorHex,
                userBio: user.bio
            ))
        }

        for post in allPosts where post.quoteText.lowercased().contains(lowered) || post.caption.lowercased().contains(lowered) {
            results.append(SearchResult(
                id: "sr_post_\(post.id)",
                type: .post,
                postQuote: post.quoteText,
                postCaption: post.caption,
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
        if let index = suggestedUsers.firstIndex(where: { $0.id == userId }) {
            suggestedUsers[index].isFollowing.toggle()
        }
    }
    
    // MARK: - Mock Data Setup

    private func setupMockData() {
        setupCategories()
        setupHashtags()
        setupSuggestedUsers()
    }

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
    
    private func setupHashtags() {
        hashtags = [
            DiscoverHashtag(id: "h1",  name: "MorningWalk",       postCount: 3421),
            DiscoverHashtag(id: "h2",  name: "StudyDay",          postCount: 2187),
            DiscoverHashtag(id: "h3",  name: "WeekendMood",       postCount: 4532),
            DiscoverHashtag(id: "h4",  name: "MindfulMonday",     postCount: 1876),
            DiscoverHashtag(id: "h5",  name: "SelfCare",          postCount: 5621),
            DiscoverHashtag(id: "h6",  name: "Gratitude",         postCount: 3298),
            DiscoverHashtag(id: "h7",  name: "NatureVibes",       postCount: 2745),
            DiscoverHashtag(id: "h8",  name: "FitnessJourney",    postCount: 1932),
            DiscoverHashtag(id: "h9",  name: "CalmDown",          postCount: 1456),
            DiscoverHashtag(id: "h10", name: "GoodVibesOnly",     postCount: 6214),
            DiscoverHashtag(id: "h11", name: "MentalHealth",      postCount: 4127),
            DiscoverHashtag(id: "h12", name: "InnerPeace",        postCount: 2893),
            DiscoverHashtag(id: "h13", name: "DailyReflection",   postCount: 1654),
            DiscoverHashtag(id: "h14", name: "PositiveEnergy",    postCount: 3876),
            DiscoverHashtag(id: "h15", name: "JournalEntry",      postCount: 1243),
            DiscoverHashtag(id: "h16", name: "MoodTracker",       postCount: 987),
            DiscoverHashtag(id: "h17", name: "Meditation",        postCount: 2654),
            DiscoverHashtag(id: "h18", name: "BreathWork",        postCount: 1123),
            DiscoverHashtag(id: "h19", name: "SunsetChaser",      postCount: 3542),
            DiscoverHashtag(id: "h20", name: "MorningRoutine",    postCount: 2876)
        ]
    }
    
    private func setupSuggestedUsers() {
        suggestedUsers = [
            SuggestedUser(id: "su1",  displayName: "Luna Park",       username: "luna_glow",       avatarColorHex: "ED64A6", bio: "Night owl. Stargazer. Dream chaser.", isFollowing: false),
            SuggestedUser(id: "su2",  displayName: "River Stone",     username: "river_flows",     avatarColorHex: "38B2AC", bio: "Kayaker & nature lover. Flow state addict.", isFollowing: false),
            SuggestedUser(id: "su3",  displayName: "Maya Chen",       username: "maya_mindful",    avatarColorHex: "805AD5", bio: "Yoga instructor. Mindfulness advocate.", isFollowing: false),
            SuggestedUser(id: "su4",  displayName: "Kai Nakamura",    username: "kai_runs",        avatarColorHex: "FF6B6B", bio: "Marathon runner. Morning person.", isFollowing: false),
            SuggestedUser(id: "su5",  displayName: "Sage Williams",   username: "sage_reads",      avatarColorHex: "D69E2E", bio: "Bookworm. Tea enthusiast. Quiet observer.", isFollowing: false),
            SuggestedUser(id: "su6",  displayName: "Aurora James",    username: "aurora_art",      avatarColorHex: "F093FB", bio: "Watercolor artist. Color is my language.", isFollowing: false),
            SuggestedUser(id: "su7",  displayName: "Jasper Cole",     username: "jasper_hikes",    avatarColorHex: "12B886", bio: "Trail runner. Mountain photographer.", isFollowing: false),
            SuggestedUser(id: "su8",  displayName: "Nova Singh",      username: "nova_codes",      avatarColorHex: "4DABF7", bio: "Developer by day, stargazer by night.", isFollowing: false),
            SuggestedUser(id: "su9",  displayName: "Willow Reed",     username: "willow_writes",   avatarColorHex: "A0AEC0", bio: "Poet. Journal keeper. Sunset collector.", isFollowing: false),
            SuggestedUser(id: "su10", displayName: "Finn O'Brien",    username: "finn_surfs",      avatarColorHex: "00B5D8", bio: "Surfer. Ocean lover. Salt in my veins.", isFollowing: false),
            SuggestedUser(id: "su11", displayName: "Ivy Martinez",    username: "ivy_grows",       avatarColorHex: "48BB78", bio: "Plant mom. Garden enthusiast.", isFollowing: false),
            SuggestedUser(id: "su12", displayName: "Atlas Kim",       username: "atlas_travels",   avatarColorHex: "E53E3E", bio: "30 countries and counting. Wander often.", isFollowing: false),
            SuggestedUser(id: "su13", displayName: "Coral Davis",     username: "coral_sings",     avatarColorHex: "D53F8C", bio: "Singer-songwriter. Music heals.", isFollowing: false),
            SuggestedUser(id: "su14", displayName: "Zane Foster",     username: "zane_lifts",      avatarColorHex: "C05621", bio: "Personal trainer. Discipline is freedom.", isFollowing: false),
            SuggestedUser(id: "su15", displayName: "Pearl Wang",      username: "pearl_cooks",     avatarColorHex: "FAB005", bio: "Home chef. Comfort food creator.", isFollowing: false),
            SuggestedUser(id: "su16", displayName: "Rowan Blake",     username: "rowan_thinks",    avatarColorHex: "718096", bio: "Philosopher. Deep thinker. Quiet rebel.", isFollowing: false),
            SuggestedUser(id: "su17", displayName: "Sienna Lopez",    username: "sienna_dances",   avatarColorHex: "F6AD55", bio: "Dancer. Movement is medicine.", isFollowing: false),
            SuggestedUser(id: "su18", displayName: "Orion Patel",     username: "orion_games",     avatarColorHex: "9F7AEA", bio: "Game designer. Pixel dreamer.", isFollowing: false),
            SuggestedUser(id: "su19", displayName: "Hazel Brown",     username: "hazel_bakes",     avatarColorHex: "B7791F", bio: "Baker. Spreading sweetness daily.", isFollowing: false),
            SuggestedUser(id: "su20", displayName: "Reed Thompson",   username: "reed_meditates",  avatarColorHex: "319795", bio: "Meditation teacher. Stillness is power.", isFollowing: false),
            SuggestedUser(id: "su21", displayName: "Ember Fox",       username: "ember_captures",  avatarColorHex: "E53E3E", bio: "Street photographer. Urban stories.", isFollowing: false),
            SuggestedUser(id: "su22", displayName: "Sky Tanaka",      username: "sky_breathes",    avatarColorHex: "4299E1", bio: "Breathwork facilitator. Inhale courage.", isFollowing: false),
            SuggestedUser(id: "su23", displayName: "Clover Hayes",    username: "clover_journals", avatarColorHex: "48BB78", bio: "Bullet journal artist. Analog soul.", isFollowing: false),
            SuggestedUser(id: "su24", displayName: "Blaze Rivera",    username: "blaze_climbs",    avatarColorHex: "DD6B20", bio: "Rock climber. Fear is just a feeling.", isFollowing: false),
            SuggestedUser(id: "su25", displayName: "Iris Zhao",       username: "iris_paints",     avatarColorHex: "9B2C2C", bio: "Oil painter. Every canvas is a conversation.", isFollowing: false)
        ]
    }

}
