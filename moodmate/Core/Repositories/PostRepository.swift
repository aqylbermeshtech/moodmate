//
//  PostRepository.swift
//  moodmate
//
//  Single source of truth for all posts across Home, Profile, Discover, and
//  CreatePost. Every feature reads its display projection from here and
//  routes every like/bookmark/create/delete mutation back through here, so a
//  change made in one feature is visible in the others.
//
//  Posts persist to a JSON file in the app's documents directory — the same
//  local-store pattern ProfileRepository uses for profiles. Seed content is
//  only (re)generated when the file is missing or the seed version bumps;
//  user-created posts are kept across launches.
//

import Foundation
import Combine
import OSLog

final class PostRepository: PostRepositoryProtocol {
    static let shared = PostRepository()

    @Published private var posts: [PostModel] = [] {
        didSet {
            logger.debug("posts changed: \(self.posts.map(\.id).joined(separator: ","), privacy: .public)")
        }
    }

    var allPosts: [PostModel] { posts }

    var postsPublisher: AnyPublisher<[PostModel], Never> {
        $posts.eraseToAnyPublisher()
    }

    private let postUpdateSubject = PassthroughSubject<PostModel, Never>()
    var postUpdatePublisher: AnyPublisher<PostModel, Never> {
        postUpdateSubject.eraseToAnyPublisher()
    }

    private var cancellables = Set<AnyCancellable>()
    private let logger = Logger(subsystem: "com.moodmate", category: "PostRepository")
    private let profileRepository: ProfileRepositoryProtocol

    // MARK: - Local store

    private let fileManager = FileManager.default
    private let storageKey = "moodmate_posts_v1.json"

    /// Bump when the seed content itself changes and needs to replace the
    /// copy already written to disk. Mirrors ProfileRepository.mockDataVersion.
    private static let seedVersion = 1
    private static let seedVersionKey = "moodmate_post_seed_version"

    private var storageFileURL: URL {
        let paths = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent(storageKey)
    }

    init(profileRepository: ProfileRepositoryProtocol = ProfileRepository.shared) {
        self.profileRepository = profileRepository
        loadPersistedPosts()
        invalidateStaleSeedPostsIfNeeded()
        seedMissingPosts()
        persistPosts()
        observeProfileUpdates()
    }

    private func observeProfileUpdates() {
        profileRepository.profileUpdatesPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] updatedProfile in
                guard let self else { return }

                // The first time a real Firebase user profile comes through,
                // re-author whatever mock-seeded posts still belong to the
                // pre-auth placeholder id — mirrors ProfileRepository's own
                // mock-profile-to-authenticated-user migration. Posts carry
                // only authorId now, so there's nothing else to patch here —
                // display fields are resolved live from UserStore.
                if updatedProfile.id != AppSessionManager.mockUserId,
                   !self.posts(forAuthor: AppSessionManager.mockUserId).isEmpty {
                    self.migrateAuthor(from: AppSessionManager.mockUserId, to: updatedProfile.id)
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - Reads

    func fetchPosts() async throws -> [PostModel] {
        try await Task.sleep(nanoseconds: 150_000_000)
        return posts
    }

    func posts(forAuthor authorId: String) -> [PostModel] {
        posts.filter { $0.authorId == authorId }
    }

    func post(id: String) -> PostModel? {
        posts.first { $0.id == id }
    }

    // MARK: - Mutations

    func createPost(_ post: PostModel) async throws -> PostModel {
        try await Task.sleep(nanoseconds: 400_000_000)
        posts.insert(post, at: 0)
        persistPosts()
        postUpdateSubject.send(post)
        return post
    }

    func deletePost(id: String) async throws {
        try await Task.sleep(nanoseconds: 100_000_000)
        posts.removeAll { $0.id == id }
        persistPosts()
    }

    func setLike(postId: String, isLiked: Bool) async throws {
        guard let index = posts.firstIndex(where: { $0.id == postId }) else { return }
        guard posts[index].isLiked != isLiked else { return }

        var updated = posts[index]
        updated.isLiked = isLiked
        updated.likesCount += isLiked ? 1 : -1
        posts[index] = updated
        persistPosts()

        logger.debug("like committed for \(postId, privacy: .public): isLiked=\(isLiked, privacy: .public) count=\(updated.likesCount, privacy: .public)")
        postUpdateSubject.send(updated)
    }

    func toggleBookmark(postId: String) async throws {
        guard let index = posts.firstIndex(where: { $0.id == postId }) else { return }
        posts[index].isBookmarked.toggle()
        persistPosts()
        postUpdateSubject.send(posts[index])
    }

    func migrateAuthor(from oldAuthorId: String, to newAuthorId: String) {
        var changed = false
        for i in 0..<posts.count where posts[i].authorId == oldAuthorId {
            posts[i].authorId = newAuthorId
            changed = true
        }
        if changed { persistPosts() }
    }


    // MARK: - Persistence

    private func persistPosts() {
        do {
            let data = try JSONEncoder().encode(posts)
            try data.write(to: storageFileURL, options: .atomic)
        } catch {
            logger.error("Failed to persist posts: \(error, privacy: .public)")
        }
    }

    private func loadPersistedPosts() {
        guard fileManager.fileExists(atPath: storageFileURL.path) else { return }
        do {
            let data = try Data(contentsOf: storageFileURL)
            posts = try JSONDecoder().decode([PostModel].self, from: data)
        } catch {
            logger.error("Failed to load persisted posts: \(error, privacy: .public)")
        }
    }

    // MARK: - Mock Data Seeding

    /// The full seed set — 5 hand-authored + 3 current-user + 100 generated.
    private func seedPosts() -> [PostModel] {
        handAuthoredPosts + currentUserSeedPosts + generatedDiscoverPosts
    }

    /// On a seed-version bump, drop the seed-authored copies already on disk
    /// so `seedMissingPosts()` re-adds the current content. User-created
    /// posts (`post_*`) are untouched.
    private func invalidateStaleSeedPostsIfNeeded() {
        let storedVersion = UserDefaults.standard.integer(forKey: Self.seedVersionKey)
        guard storedVersion < Self.seedVersion else { return }
        let seedIds = Set(seedPosts().map(\.id))
        posts.removeAll { seedIds.contains($0.id) || $0.id.hasPrefix("lazy_") }
        UserDefaults.standard.set(Self.seedVersion, forKey: Self.seedVersionKey)
    }

    /// Adds any seed post whose id isn't already present (first launch, or
    /// after an invalidation). Existing posts — user or seed — keep their
    /// persisted state (likes, bookmarks, order).
    private func seedMissingPosts() {
        let existingIds = Set(posts.map(\.id))
        let missing = seedPosts().filter { !existingIds.contains($0.id) }
        guard !missing.isEmpty else { return }
        posts.append(contentsOf: missing)
    }

    /// The original 5 hand-authored feed posts.
    private var handAuthoredPosts: [PostModel] {
        [
            PostModel(
                id: "p1",
                authorId: "2",
                text: "Taking a conscious pause today. A reminder that it is okay to just be, rather than always do.",
                images: [],
                visibility: .publicVisibility,
                createdAt: Date().addingTimeInterval(-7200),
                likesCount: 24,
                commentsCount: 3,
                bookmarksCount: 5,
                isLiked: false,
                isBookmarked: false,
                quoteText: "Breathe in experience, breathe out poetry.",
                gradientStartHex: "38B2AC",
                gradientEndHex: "805AD5"
            ),
            PostModel(
                id: "p2",
                authorId: "3",
                text: "Listening to my body and getting to sleep early tonight. Recharge session starts now.",
                images: [],
                visibility: .publicVisibility,
                createdAt: Date().addingTimeInterval(-10800),
                likesCount: 15,
                commentsCount: 1,
                bookmarksCount: 2,
                isLiked: true,
                isBookmarked: false,
                quoteText: "Rest is a fine medicine.",
                gradientStartHex: "1A365D",
                gradientEndHex: "667EEA"
            ),
            PostModel(
                id: "p3",
                authorId: "1",
                text: "Morning run cleared my head. Highly recommend starting your day active.",
                images: [],
                visibility: .publicVisibility,
                createdAt: Date().addingTimeInterval(-18000),
                likesCount: 42,
                commentsCount: 8,
                bookmarksCount: 12,
                isLiked: false,
                isBookmarked: true,
                quoteText: "Motion creates emotion.",
                gradientStartHex: "ED64A6",
                gradientEndHex: "ECC94B"
            ),
            PostModel(
                id: "p4",
                authorId: "4",
                text: "We launched our beta today. Incredibly grateful for the team's effort.",
                images: [],
                visibility: .publicVisibility,
                createdAt: Date().addingTimeInterval(-21600),
                likesCount: 56,
                commentsCount: 12,
                bookmarksCount: 4,
                isLiked: false,
                isBookmarked: false,
                quoteText: "Celebrate the tiny wins.",
                gradientStartHex: "ED64A6",
                gradientEndHex: "FEFCBF"
            ),
            PostModel(
                id: "p5",
                authorId: "5",
                text: "Enjoyed a quiet matcha latte. Focusing on the warmth, the taste, and the silence.",
                images: [],
                visibility: .publicVisibility,
                createdAt: Date().addingTimeInterval(-28800),
                likesCount: 31,
                commentsCount: 4,
                bookmarksCount: 3,
                isLiked: false,
                isBookmarked: false,
                quoteText: "Be here now.",
                gradientStartHex: "12B886",
                gradientEndHex: "38B2AC"
            )
        ]
    }

    /// The signed-in (or pre-auth mock) viewer's own 3 seed posts. Authored
    /// against `AppSessionManager.mockUserId`; `migrateAuthor` re-points
    /// them at the real Firebase uid the first time
    /// `ProfileRepository.syncWithFirebaseUser` runs, mirroring how
    /// ProfileRepository migrates the mock profile itself.
    private var currentUserSeedPosts: [PostModel] {
        return [
            PostModel(
                id: "up1",
                authorId: AppSessionManager.mockUserId,
                text: "Enjoyed a peaceful coffee walk this morning. Grateful for the fresh air.",
                images: [],
                visibility: .publicVisibility,
                createdAt: Date().addingTimeInterval(-7200),
                likesCount: 14,
                commentsCount: 2,
                bookmarksCount: 0,
                isLiked: false,
                isBookmarked: false,
                quoteText: "The present moment is filled with joy and happiness.",
                gradientStartHex: "38B2AC",
                gradientEndHex: "805AD5"
            ),
            PostModel(
                id: "up2",
                authorId: AppSessionManager.mockUserId,
                text: "Spent 10 minutes writing down my worries. Writing them helps me let them go.",
                images: [],
                visibility: .publicVisibility,
                createdAt: Date().addingTimeInterval(-86400 * 2),
                likesCount: 9,
                commentsCount: 0,
                bookmarksCount: 0,
                isLiked: false,
                isBookmarked: false,
                quoteText: "Quiet mind, peaceful heart.",
                gradientStartHex: "4DABF7",
                gradientEndHex: "BE4BDF"
            ),
            PostModel(
                id: "up3",
                authorId: AppSessionManager.mockUserId,
                text: "Revisited my goals today. Taking it day by day. Every small step counts.",
                images: [],
                visibility: .publicVisibility,
                createdAt: Date().addingTimeInterval(-86400 * 4),
                likesCount: 28,
                commentsCount: 5,
                bookmarksCount: 0,
                isLiked: true,
                isBookmarked: true,
                quoteText: "Grateful for small things, big things, and everything in between.",
                gradientStartHex: "ED64A6",
                gradientEndHex: "FEFCBF"
            )
        ]
    }

    /// Just the ids for cycling through authors below — the actual display
    /// identities (name/username/avatar) for su1–su25 live in
    /// ProfileRepository, published once by DiscoverService from its
    /// suggestedUsers roster (the one canonical copy of who these 25
    /// people are), and resolved by UserStore at render time.
    private var discoverAuthorIds: [String] {
        (1...25).map { "su\($0)" }
    }

    /// The 100 generated Discover-feed posts, ported from what used to be
    /// DiscoverService.setupDiscoverPosts() — same generator, same content
    /// pools, now producing canonical PostModel instead of a Discover-only
    /// DiscoverPost that no other feature could see.
    private var generatedDiscoverPosts: [PostModel] {
        let gradientPairs: [(start: String, end: String)] = [
            ("38B2AC", "805AD5"), ("ED64A6", "ECC94B"), ("1A365D", "667EEA"),
            ("F56565", "ED64A6"), ("12B886", "38B2AC"), ("4A5568", "718096"),
            ("805AD5", "B7791F"), ("000000", "2D3748"), ("F6AD55", "D69E2E"),
            ("667EEA", "764BA2"), ("4DABF7", "BE4BDF"), ("FF6B6B", "FAB005"),
            ("D53F8C", "FF6B6B"), ("319795", "4DABF7"), ("E53E3E", "DD6B20"),
            ("48BB78", "38B2AC"), ("9F7AEA", "ED64A6"), ("4299E1", "667EEA"),
            ("B7791F", "F6AD55"), ("718096", "A0AEC0")
        ]

        let quotes = [
            "Breathe in experience, breathe out poetry.", "Motion creates emotion.", "Rest is a fine medicine.",
            "Celebrate the tiny wins.", "Be here now.", "Peace is a daily practice.",
            "Joy is what happens when we allow ourselves to recognize how good things are.", "Sleep is the best meditation.",
            "Energy is contagious.", "Quiet the mind and the soul will speak.",
            "The present moment is filled with joy and happiness.", "Grateful hearts see good things.",
            "Calm is a super power.", "Keep moving, keep growing.", "Stars can't shine without darkness.",
            "Inhale courage, exhale fear.", "Every day is a fresh start.", "Let your light shine.",
            "Small steps lead to big changes.", "Stillness speaks louder than noise.",
            "Your vibe attracts your tribe.", "Embrace the journey.", "Find beauty in the ordinary.",
            "Growth happens outside comfort zones.", "Water your own garden.", "Trust the timing of your life.",
            "Let go of what you can't control.", "Kindness is always in season.", "Dream without fear.",
            "Love without limits.", "Today is a gift.", "Create the life you imagine.",
            "Believe in your inner strength.", "Silence is golden.", "Rise above the storm.",
            "Bloom where you are planted.", "Happiness is homemade.", "Adventures await the brave.",
            "Be the energy you want to attract.", "Simplicity is the ultimate sophistication.",
            "Your only limit is your mind.", "Make peace with the mirror.", "Stay wild.",
            "Let nature be your teacher.", "The best view comes after the hardest climb.",
            "Collect moments, not things.", "Paint your own reality.", "Dance in the rain.",
            "Write your own story.", "Stars are just the beginning."
        ]

        let captions = [
            "Taking a conscious pause today. A reminder that it is okay to just be.",
            "Morning run cleared my head. Endorphins are flowing.",
            "Listening to my body and getting to sleep early tonight.",
            "We launched our project today. Feeling incredibly grateful.",
            "Enjoyed a quiet matcha latte. Mindful sipping.",
            "Grateful for a quiet evening. Reflected on what brought joy this week.",
            "Epic sunset view from the peak. Perfect warm pink hues.",
            "Rain tapping on the window pane. Cozy night in.",
            "Spent the weekend catching up with old friends. Battery fully recharged.",
            "Ten minutes of focused breathing before emails. Try it.",
            "Peaceful coffee walk this morning. Grateful for fresh air.",
            "Reflected on the beauty of nature. The trees, the morning fog.",
            "Had an amazing breathing session. Keeping my head clear.",
            "Setting intentions for the next month. Every small step counts.",
            "Found a hidden trail today. Nature never disappoints.",
            "Journaled for 20 minutes. Thoughts feel lighter now.",
            "Cooked a new recipe tonight. Nourishing body and soul.",
            "Watched the sunrise alone. Pure magic.",
            "Read a whole book in one sitting. Lost in another world.",
            "Danced like nobody was watching. Highly recommend it.",
            "Tried cold plunging for the first time. Invigorating.",
            "Painted for the first time in years. It was therapeutic.",
            "Long phone call with a loved one. Connection matters.",
            "Meditation retreat was life-changing. Inner peace unlocked.",
            "Gardening in the afternoon sun. Grounding experience.",
            "Night sky photography session. The stars were incredible.",
            "Morning yoga on the beach. Salt air and serenity.",
            "Baked sourdough bread from scratch. Patience pays off.",
            "Volunteered at the animal shelter today. Pure joy.",
            "Digital detox day. No screens, just presence.",
            "Finished a challenging puzzle. Satisfying click.",
            "Slow morning with jazz and pancakes. Weekend bliss.",
            "Explored a new neighborhood on foot. Discovered a hidden cafe.",
            "Thunderstorm watching from the porch. Nature's symphony.",
            "Completed my first 5K run. Personal achievement unlocked.",
            "Tried watercolor painting. Messy but beautiful.",
            "Made gratitude cards for friends. Spreading love.",
            "Mountain biking through autumn trails. Crunchy leaves everywhere.",
            "Hosted a mindful dinner party. Deep conversations flowed.",
            "Sunrise paddleboard session. Glassy water meditation.",
            "Photography walk downtown, capturing urban beauty. #photography",
            "Tried a new travel coffee spot. Wanderlust brewing. #travel",
            "Forest bathing session. Nature heals everything. #nature",
            "Homemade ramen from scratch. Four hours well spent. #food",
            "New PR at the gym. Consistency pays off. #fitness",
            "Abstract painting session in the studio. Colors everywhere. #art",
            "Guitar practice at golden hour. Music is meditation. #music",
            "Study marathon with lo-fi beats. Three chapters done. #study",
            "Late night gaming session with the squad. Good games. #gaming",
            "Morning skincare routine. Self-care is not selfish. #lifestyle",
            "Captured the Milky Way on camera last night. In awe of the universe.",
            "Tried stand-up paddleboarding yoga. Balance is everything.",
            "Made a vision board for the rest of the year. Planning big things.",
            "Slow evening with candlelight and a good book. Simple pleasures.",
            "Community cleanup at the local park. Small acts, big impact.",
            "Discovered a vinyl record store. Analog warmth hits different.",
            "Bike ride along the coast. Wind in my hair, peace in my heart.",
            "Homemade herbal tea garden harvest. Nature provides.",
            "Started learning pottery. Getting my hands dirty feels great.",
            "Journaling by moonlight. Some thoughts need the quiet of night.",
            "Walked 10,000 steps in the park this morning. Fresh start. #morningwalk",
            "Study day vibes. Library to coffee shop workflow. #studyday",
            "Weekend plan is hiking and hot chocolate. Perfect combo. #weekend",
            "Self-care Sunday in full effect. Face masks and quiet time.",
            "Gratitude journaling before bed. Three good things today.",
            "Nature vibes at the botanical garden. Every flower is art.",
            "Started my fitness journey today. Day 1 of many. #fitnessjourney",
            "Calm-down techniques that actually work. Sharing my toolkit.",
            "Good vibes at the farmers market. Fresh produce and sunshine.",
            "Mental health check: be gentle with yourself today. #mentalhealth",
            "Inner peace is a practice, not a destination. Keep going.",
            "Daily reflection: what made me smile today?",
            "Positive energy only in this space. You're welcome here.",
            "New journal entry about overcoming challenges. Writing heals.",
            "Notebook update: this week trended upward.",
            "Morning meditation session. The stillness was profound.",
            "Breathwork changed my life. Not exaggerating.",
            "Chased another sunset. Never gets old.",
            "Morning routine upgrade: cold shower, journaling, movement.",
            "Random act of kindness today. Bought coffee for a stranger."
        ]

        let authorIds = discoverAuthorIds

        return (0..<100).map { i in
            let authorId = authorIds[i % authorIds.count]
            let gradient = gradientPairs[i % gradientPairs.count]

            return PostModel(
                id: "dp\(i + 1)",
                authorId: authorId,
                text: captions[i % captions.count],
                images: [],
                visibility: .publicVisibility,
                createdAt: Date().addingTimeInterval(-Double(i * 3600 + Int.random(in: 0...3600))),
                likesCount: Int.random(in: 5...120),
                commentsCount: Int.random(in: 0...25),
                bookmarksCount: 0,
                isLiked: Bool.random(),
                isBookmarked: false,
                quoteText: quotes[i % quotes.count],
                gradientStartHex: gradient.start,
                gradientEndHex: gradient.end
            )
        }
    }
}
