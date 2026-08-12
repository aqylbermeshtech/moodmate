//
//  PostRepository.swift
//  moodmate
//
//  Single source of truth for all posts across Home, Profile, Discover, and
//  CreatePost. Every feature reads its display projection from here and
//  routes every like/bookmark/create/delete mutation back through here, so a
//  change made in one feature is visible in the others.
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
    private let profileService: ProfileServiceProtocol

    init(profileService: ProfileServiceProtocol = ProfileService.shared) {
        self.profileService = profileService
        seedInitialPosts()
        observeProfileUpdates()
    }

    private func observeProfileUpdates() {
        profileService.profileUpdatesPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] updatedProfile in
                guard let self else { return }

                // The first time a real Firebase user profile comes through,
                // re-author whatever mock-seeded posts still belong to the
                // pre-auth placeholder id — mirrors ProfileService's own
                // mock-profile-to-authenticated-user migration.
                if updatedProfile.id != Self.mockCurrentUserId,
                   !self.posts(forAuthor: Self.mockCurrentUserId).isEmpty {
                    self.migrateAuthor(from: Self.mockCurrentUserId, to: updatedProfile.id)
                }

                for i in 0..<self.posts.count {
                    if self.posts[i].author.id == updatedProfile.id {
                        var updatedAuthor = self.posts[i].author
                        updatedAuthor.name = updatedProfile.displayName
                        updatedAuthor.username = updatedProfile.username
                        updatedAuthor.avatarColorHex = updatedProfile.avatarColorHex
                        updatedAuthor.avatarImageData = updatedProfile.avatarImageData
                        self.posts[i].author = updatedAuthor
                    }
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
        posts.filter { $0.author.id == authorId }
    }

    // MARK: - Mutations

    func createPost(_ post: PostModel) async throws -> PostModel {
        try await Task.sleep(nanoseconds: 400_000_000)
        posts.insert(post, at: 0)
        postUpdateSubject.send(post)
        return post
    }

    func deletePost(id: String) async throws {
        try await Task.sleep(nanoseconds: 100_000_000)
        posts.removeAll { $0.id == id }
    }

    func setLike(postId: String, isLiked: Bool) async throws {
        guard let index = posts.firstIndex(where: { $0.id == postId }) else { return }
        guard posts[index].isLiked != isLiked else { return }

        var updated = posts[index]
        updated.isLiked = isLiked
        updated.likesCount += isLiked ? 1 : -1
        posts[index] = updated

        logger.debug("like committed for \(postId, privacy: .public): isLiked=\(isLiked, privacy: .public) count=\(updated.likesCount, privacy: .public)")
        postUpdateSubject.send(updated)
    }

    func toggleBookmark(postId: String) async throws {
        guard let index = posts.firstIndex(where: { $0.id == postId }) else { return }
        posts[index].isBookmarked.toggle()
        postUpdateSubject.send(posts[index])
    }

    func migrateAuthor(from oldAuthorId: String, to newAuthorId: String) {
        for i in 0..<posts.count where posts[i].author.id == oldAuthorId {
            var migratedAuthor = posts[i].author
            migratedAuthor = MoodUser(
                id: newAuthorId,
                name: migratedAuthor.name,
                username: migratedAuthor.username,
                avatarImageName: migratedAuthor.avatarImageName,
                avatarImageData: migratedAuthor.avatarImageData,
                avatarColorHex: migratedAuthor.avatarColorHex,
                currentMoodEmoji: migratedAuthor.currentMoodEmoji,
                currentMoodText: migratedAuthor.currentMoodText,
                currentMoodColorHex: migratedAuthor.currentMoodColorHex
            )
            posts[i].author = migratedAuthor
        }
    }

    // MARK: - Mock Data Seeding

    private static let mockCurrentUserId = "current_user_mock"

    private func seedInitialPosts() {
        posts = handAuthoredPosts + currentUserSeedPosts + generatedDiscoverPosts
    }

    /// The original 5 hand-authored feed posts.
    private var handAuthoredPosts: [PostModel] {
        [
            PostModel(
                id: "p1",
                author: MoodUser(id: "2", name: "Michele", username: "mj", avatarImageName: nil, avatarColorHex: "4DABF7", currentMoodEmoji: "😌", currentMoodText: "Calm", currentMoodColorHex: "4A5568"),
                mood: "Calm",
                moodEmoji: "😌",
                moodColorHex: "4A5568",
                text: "Taking a conscious pause today. A reminder that it is okay to just be, rather than always do. 🌱✨",
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
                author: MoodUser(id: "3", name: "Ned", username: "ceo", avatarImageName: nil, avatarColorHex: "BE4BDF", currentMoodEmoji: "😴", currentMoodText: "Sleepy", currentMoodColorHex: "667EEA"),
                mood: "Sleepy",
                moodEmoji: "😴",
                moodColorHex: "667EEA",
                text: "Listening to my body and getting to sleep early tonight. Recharge session starts now. 💤😴 #nightroutine #rest",
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
                author: MoodUser(id: "1", name: "Pepper", username: "pepperoni", avatarImageName: nil, avatarColorHex: "FF6B6B", currentMoodEmoji: "😊", currentMoodText: "Happy", currentMoodColorHex: "38B2AC"),
                mood: "Happy",
                moodEmoji: "😊",
                moodColorHex: "38B2AC",
                text: "Morning run cleared my head. Endorphins are flowing! Highly recommend starting your day active! 🏃‍♂️☀️ #fitness #mindset",
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
                author: MoodUser(id: "4", name: "Happy", username: "happyaunt", avatarImageName: nil, avatarColorHex: "FAB005", currentMoodEmoji: "🤩", currentMoodText: "Excited", currentMoodColorHex: "ED64A6"),
                mood: "Excited",
                moodEmoji: "🤩",
                moodColorHex: "ED64A6",
                text: "We launched our beta today! Feeling incredibly excited and grateful for the team's effort! 🚀🎉🙌 #launchday",
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
                author: MoodUser(id: "5", name: "Alex", username: "alexwang", avatarImageName: nil, avatarColorHex: "12B886", currentMoodEmoji: "🧠", currentMoodText: "Mindful", currentMoodColorHex: "805AD5"),
                mood: "Mindful",
                moodEmoji: "🧠",
                moodColorHex: "805AD5",
                text: "Enjoyed a quiet matcha latte. Mindful sipping: focusing on the warmth, the taste, and the silence. 🍵🧘‍♂️",
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
    /// against `mockCurrentUserId`; `migrateAuthor` re-points them at the
    /// real Firebase uid the first time `ProfileService.syncWithFirebaseUser`
    /// runs, mirroring how ProfileService migrates the mock profile itself.
    private var currentUserSeedPosts: [PostModel] {
        let viewer = MoodUser(id: Self.mockCurrentUserId, name: "John", username: "johndoe", avatarColorHex: "38B2AC")
        return [
            PostModel(
                id: "up1",
                author: viewer,
                mood: nil,
                moodEmoji: nil,
                moodColorHex: nil,
                text: "Enjoyed a peaceful coffee walk this morning. Grateful for the fresh air. ☕️🍃",
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
                author: viewer,
                mood: nil,
                moodEmoji: nil,
                moodColorHex: nil,
                text: "Spend 10 minutes writing down my worries. Writing them helps letting them go. 📝🧘‍♂️",
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
                author: viewer,
                mood: nil,
                moodEmoji: nil,
                moodColorHex: nil,
                text: "Revisited my goals today. Taking it day by day. Every small step counts. 💪✨",
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

    /// A compact identity table (id/name/username/color only) for authoring
    /// the 100 generated Discover posts below. Intentionally not the same
    /// type as DiscoverService.SuggestedUser — that carries Discover-catalog
    /// fields (bio, isFollowing) this repository has no use for.
    private struct SeedAuthorIdentity {
        let id: String
        let name: String
        let username: String
        let colorHex: String
    }

    private var discoverAuthorPool: [SeedAuthorIdentity] {
        [
            SeedAuthorIdentity(id: "su1", name: "Luna Park", username: "luna_glow", colorHex: "ED64A6"),
            SeedAuthorIdentity(id: "su2", name: "River Stone", username: "river_flows", colorHex: "38B2AC"),
            SeedAuthorIdentity(id: "su3", name: "Maya Chen", username: "maya_mindful", colorHex: "805AD5"),
            SeedAuthorIdentity(id: "su4", name: "Kai Nakamura", username: "kai_runs", colorHex: "FF6B6B"),
            SeedAuthorIdentity(id: "su5", name: "Sage Williams", username: "sage_reads", colorHex: "D69E2E"),
            SeedAuthorIdentity(id: "su6", name: "Aurora James", username: "aurora_art", colorHex: "F093FB"),
            SeedAuthorIdentity(id: "su7", name: "Jasper Cole", username: "jasper_hikes", colorHex: "12B886"),
            SeedAuthorIdentity(id: "su8", name: "Nova Singh", username: "nova_codes", colorHex: "4DABF7"),
            SeedAuthorIdentity(id: "su9", name: "Willow Reed", username: "willow_writes", colorHex: "A0AEC0"),
            SeedAuthorIdentity(id: "su10", name: "Finn O'Brien", username: "finn_surfs", colorHex: "00B5D8"),
            SeedAuthorIdentity(id: "su11", name: "Ivy Martinez", username: "ivy_grows", colorHex: "48BB78"),
            SeedAuthorIdentity(id: "su12", name: "Atlas Kim", username: "atlas_travels", colorHex: "E53E3E"),
            SeedAuthorIdentity(id: "su13", name: "Coral Davis", username: "coral_sings", colorHex: "D53F8C"),
            SeedAuthorIdentity(id: "su14", name: "Zane Foster", username: "zane_lifts", colorHex: "C05621"),
            SeedAuthorIdentity(id: "su15", name: "Pearl Wang", username: "pearl_cooks", colorHex: "FAB005"),
            SeedAuthorIdentity(id: "su16", name: "Rowan Blake", username: "rowan_thinks", colorHex: "718096"),
            SeedAuthorIdentity(id: "su17", name: "Sienna Lopez", username: "sienna_dances", colorHex: "F6AD55"),
            SeedAuthorIdentity(id: "su18", name: "Orion Patel", username: "orion_games", colorHex: "9F7AEA"),
            SeedAuthorIdentity(id: "su19", name: "Hazel Brown", username: "hazel_bakes", colorHex: "B7791F"),
            SeedAuthorIdentity(id: "su20", name: "Reed Thompson", username: "reed_meditates", colorHex: "319795"),
            SeedAuthorIdentity(id: "su21", name: "Ember Fox", username: "ember_captures", colorHex: "E53E3E"),
            SeedAuthorIdentity(id: "su22", name: "Sky Tanaka", username: "sky_breathes", colorHex: "4299E1"),
            SeedAuthorIdentity(id: "su23", name: "Clover Hayes", username: "clover_journals", colorHex: "48BB78"),
            SeedAuthorIdentity(id: "su24", name: "Blaze Rivera", username: "blaze_climbs", colorHex: "DD6B20"),
            SeedAuthorIdentity(id: "su25", name: "Iris Zhao", username: "iris_paints", colorHex: "9B2C2C")
        ]
    }

    /// The 100 generated Discover-feed posts, ported from what used to be
    /// DiscoverService.setupDiscoverPosts() — same generator, same content
    /// pools, now producing canonical PostModel instead of a Discover-only
    /// DiscoverPost that no other feature could see.
    private var generatedDiscoverPosts: [PostModel] {
        let moodSets: [(emoji: String, text: String, colorHex: String)] = [
            ("😊", "Happy", "38B2AC"), ("😴", "Tired", "667EEA"), ("😌", "Calm", "4A5568"),
            ("🤩", "Excited", "ED64A6"), ("😢", "Sad", "A0AEC0"), ("😤", "Frustrated", "F56565"),
            ("🥰", "Loved", "ED64A6"), ("🧠", "Mindful", "805AD5"), ("😎", "Confident", "DD6B20"),
            ("🫣", "Anxious", "B7791F")
        ]

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
            "The present moment is filled with joy and happiness.", "Grateful hearts see awesome things.",
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
            "Your only limit is your mind.", "Make peace with the mirror.", "Stay wild, moon child.",
            "Let nature be your teacher.", "The best view comes after the hardest climb.",
            "Collect moments, not things.", "Paint your own reality.", "Dance in the rain.",
            "Write your own story.", "Stars are just the beginning."
        ]

        let captions = [
            "Taking a conscious pause today. A reminder that it is okay to just be. 🌱✨",
            "Morning run cleared my head. Endorphins are flowing! 🏃‍♂️☀️",
            "Listening to my body and getting to sleep early tonight. 💤😴",
            "We launched our project today! Feeling incredibly grateful! 🚀🎉",
            "Enjoyed a quiet matcha latte. Mindful sipping. 🍵🧘‍♂️",
            "Grateful for a quiet evening. Reflected on what brought joy this week. ❤️",
            "Epic sunset view from the peak. Perfect warm pink hues. 🌄🏔️",
            "Rain tapping on the window pane. Cozy night in. 🌧️🕯️",
            "Spent the weekend catching up with old friends! Battery 100% full. 😄💃",
            "Ten minutes of focused breathing before emails. Try it! 🧘‍♂️",
            "Peaceful coffee walk this morning. Grateful for fresh air. ☕️🍃",
            "Reflected on the beauty of nature. The trees, the morning fog. 🌲🌫️",
            "Had an amazing breathing session. Keeping my head clear. 🌬️",
            "Setting intentions for the next month. Every small step counts. 💪✨",
            "Found a hidden trail today. Nature never disappoints. 🥾🌿",
            "Journaled for 20 minutes. Thoughts feel lighter now. 📝💫",
            "Cooked a new recipe tonight. Nourishing body and soul. 🍲🥗",
            "Watched the sunrise alone. Pure magic. 🌅✨",
            "Read a whole book in one sitting. Lost in another world. 📖🌙",
            "Danced like nobody was watching. Highly recommend it. 💃🎶",
            "Tried cold plunging for the first time. Invigorating! 🥶💪",
            "Painted for the first time in years. It was therapeutic. 🎨🖼️",
            "Long phone call with a loved one. Connection matters. 📞❤️",
            "Meditation retreat was life-changing. Inner peace unlocked. 🧘‍♀️🕊️",
            "Gardening in the afternoon sun. Grounding experience. 🌻🪴",
            "Night sky photography session. The stars were incredible. 🌌📷",
            "Morning yoga on the beach. Salt air and serenity. 🏖️🧘",
            "Baked sourdough bread from scratch. Patience pays off. 🍞😊",
            "Volunteered at the animal shelter today. Pure joy. 🐾💛",
            "Digital detox day. No screens, just presence. 📵🌿",
            "Finished a challenging puzzle. Satisfying click. 🧩✅",
            "Slow morning with jazz and pancakes. Weekend bliss. 🎷🥞",
            "Explored a new neighborhood on foot. Discovered a hidden café. 🚶☕️",
            "Thunderstorm watching from the porch. Nature's symphony. ⛈️🎵",
            "Completed my first 5K run! Personal achievement unlocked. 🏅🎉",
            "Tried watercolor painting. Messy but beautiful. 🎨💧",
            "Made gratitude cards for friends. Spreading love. 💌🌸",
            "Mountain biking through autumn trails. Crunchy leaves everywhere. 🚵🍂",
            "Hosted a mindful dinner party. Deep conversations flowed. 🍽️💬",
            "Sunrise paddleboard session. Glassy water meditation. 🏄‍♀️🌅",
            "Photography walk downtown — capturing urban beauty. 📷🏙️ #photography",
            "Tried a new travel coffee spot. Wanderlust brewing. ☕✈️ #travel",
            "Forest bathing session. Nature heals everything. 🌲🍃 #nature",
            "Homemade ramen from scratch. Four hours well spent. 🍜😋 #food",
            "New PR at the gym! Consistency pays off. 🏋️‍♂️🔥 #fitness",
            "Abstract painting session in the studio. Colors everywhere. 🎨🖌️ #art",
            "Guitar practice at golden hour. Music is meditation. 🎸🌅 #music",
            "Study marathon with lo-fi beats. Three chapters done. 📚🎧 #study",
            "Late night gaming session with the squad. GG! 🎮🌙 #gaming",
            "Morning skincare routine. Self-care is not selfish. 🧴✨ #lifestyle",
            "Captured the Milky Way on camera last night. In awe of the universe. 🌌🔭",
            "Tried stand-up paddleboarding yoga. Balance is everything! 🧘‍♀️🏄",
            "Made a vision board for the rest of the year. Manifesting big things. 🎯✨",
            "Slow evening with candlelight and a good book. Simple pleasures. 🕯️📖",
            "Community cleanup at the local park. Small acts, big impact. 🌍🤝",
            "Discovered a vinyl record store. Analog warmth hits different. 🎶📀",
            "Bike ride along the coast. Wind in my hair, peace in my heart. 🚲🌊",
            "Homemade herbal tea garden harvest. Nature provides. 🌿☕",
            "Started learning pottery. Getting my hands dirty feels great. 🏺🤲",
            "Journaling by moonlight. Some thoughts need the quiet of night. 🌙✍️",
            "Walked 10,000 steps in the morningwalk park. Fresh start! 🚶‍♂️🌅",
            "studyday vibes. Library to coffee shop workflow. 📖☕",
            "weekendmood is hiking and hot chocolate. Perfect combo. 🥾🍫",
            "selfcare Sunday in full effect. Face masks and meditation. 🧖‍♀️🧘",
            "gratitude journaling before bed. Three good things today. 📝🙏",
            "naturevibes at the botanical garden. Every flower is art. 🌺🎨",
            "Started my fitnessjourney today. Day 1 of many! 💪🔥",
            "calmdown techniques that actually work. Sharing my toolkit. 🧊🌬️",
            "goodvibesonly at the farmers market. Fresh produce and sunshine. 🥬☀️",
            "mentalhealth check: be gentle with yourself today. 🧠💛",
            "innerpeace is a practice, not a destination. Keep going. 🕊️🌸",
            "dailyreflection: what made me smile today? 😊📝",
            "positiveenergy only in this space. You're welcome here. ⚡🌈",
            "New journalentry about overcoming challenges. Writing heals. 📓✨",
            "moodtracker update: trending upward this week! 📈😊",
            "Morning meditation session. The stillness was profound. 🧘‍♂️🌅",
            "breathwork changed my life. Not exaggerating. 🌬️💫",
            "Chased another sunset. Never gets old. 🌅📷",
            "morningroutine upgrade: cold shower + journaling + movement. ❄️📝🏃",
            "Random act of kindness today. Bought coffee for a stranger. ☕💫"
        ]

        let authors = discoverAuthorPool

        return (0..<100).map { i in
            let author = authors[i % authors.count]
            let mood = moodSets[i % moodSets.count]
            let gradient = gradientPairs[i % gradientPairs.count]

            return PostModel(
                id: "dp\(i + 1)",
                author: MoodUser(id: author.id, name: author.name, username: author.username, avatarColorHex: author.colorHex),
                mood: mood.text,
                moodEmoji: mood.emoji,
                moodColorHex: mood.colorHex,
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
