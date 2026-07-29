//
//  DiscoverService.swift
//  moodmate
//
//  Created by Nurtore on 26.07.2026.
//

import Foundation

final class DiscoverService {
    static let shared = DiscoverService()
    
    private var allPosts: [DiscoverPost] = []
    private var trendingMoods: [TrendingMood] = []
    private var suggestedUsers: [SuggestedUser] = []
    private var hashtags: [DiscoverHashtag] = []
    private var categories: [DiscoverCategory] = []
    
    private let pageSize = 20
    
    private init() {
        setupMockData()
    }
    
    // MARK: - Public API
    
    func getTrendingMoods() async -> [TrendingMood] {
        try? await Task.sleep(nanoseconds: 300_000_000)
        return trendingMoods
    }
    
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
    
    func getDiscoverPosts(page: Int, mood: TrendingMood? = nil, category: DiscoverCategory? = nil, hashtag: DiscoverHashtag? = nil) async -> [DiscoverPost] {
        try? await Task.sleep(nanoseconds: UInt64.random(in: 600_000_000...1_000_000_000))
        
        var filtered = allPosts
        
        if let mood {
            filtered = filtered.filter { $0.moodText.lowercased() == mood.name.lowercased() }
        }
        
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
        
        // Search users
        for user in suggestedUsers where user.displayName.lowercased().contains(lowered) || user.username.lowercased().contains(lowered) {
            results.append(SearchResult(
                id: "sr_user_\(user.id)",
                type: .user,
                userName: user.displayName,
                username: user.username,
                avatarColorHex: user.avatarColorHex,
                userMoodEmoji: user.moodEmoji,
                userBio: user.bio
            ))
        }
        
        // Search posts
        for post in allPosts where post.quoteText.lowercased().contains(lowered) || post.caption.lowercased().contains(lowered) {
            results.append(SearchResult(
                id: "sr_post_\(post.id)",
                type: .post,
                userName: post.userName,
                username: post.username,
                postQuote: post.quoteText,
                postCaption: post.caption,
                postGradientStartHex: post.gradientStartHex,
                postGradientEndHex: post.gradientEndHex,
                postLikesCount: post.likesCount,
                postUserId: post.userId
            ))
        }
        
        // Search moods
        for mood in trendingMoods where mood.name.lowercased().contains(lowered) {
            results.append(SearchResult(
                id: "sr_mood_\(mood.id)",
                type: .mood,
                moodEmoji: mood.emoji,
                moodName: mood.name,
                moodColorHex: mood.colorHex,
                moodPostCount: mood.postCount
            ))
        }
        
        // Search hashtags
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
    
    func toggleLike(postId: String) {
        if let index = allPosts.firstIndex(where: { $0.id == postId }) {
            allPosts[index].isLiked.toggle()
            allPosts[index].likesCount += allPosts[index].isLiked ? 1 : -1
        }
    }
    
    // MARK: - Mock Data Setup
    
    private func setupMockData() {
        setupTrendingMoods()
        setupCategories()
        setupHashtags()
        setupSuggestedUsers()
        setupDiscoverPosts()
    }
    
    private func setupTrendingMoods() {
        trendingMoods = [
            TrendingMood(id: "m1",  emoji: "😊", name: "Happy",      postCount: 1247, colorHex: "38B2AC"),
            TrendingMood(id: "m2",  emoji: "😴", name: "Tired",      postCount: 892,  colorHex: "667EEA"),
            TrendingMood(id: "m3",  emoji: "😌", name: "Calm",       postCount: 1034, colorHex: "4A5568"),
            TrendingMood(id: "m4",  emoji: "🤩", name: "Excited",    postCount: 756,  colorHex: "ED64A6"),
            TrendingMood(id: "m5",  emoji: "😢", name: "Sad",        postCount: 543,  colorHex: "A0AEC0"),
            TrendingMood(id: "m6",  emoji: "😤", name: "Frustrated", postCount: 321,  colorHex: "F56565"),
            TrendingMood(id: "m7",  emoji: "🥰", name: "Loved",      postCount: 678,  colorHex: "ED64A6"),
            TrendingMood(id: "m8",  emoji: "🧠", name: "Mindful",    postCount: 489,  colorHex: "805AD5"),
            TrendingMood(id: "m9",  emoji: "😎", name: "Confident",  postCount: 412,  colorHex: "DD6B20"),
            TrendingMood(id: "m10", emoji: "🫣", name: "Anxious",    postCount: 267,  colorHex: "B7791F")
        ]
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
            SuggestedUser(id: "su1",  displayName: "Luna Park",       username: "luna_glow",       avatarColorHex: "ED64A6", bio: "Night owl. Stargazer. Dream chaser.",              moodEmoji: "🌙", moodText: "Dreamy",     moodColorHex: "805AD5", isFollowing: false),
            SuggestedUser(id: "su2",  displayName: "River Stone",     username: "river_flows",     avatarColorHex: "38B2AC", bio: "Kayaker & nature lover. Flow state addict.",       moodEmoji: "🌊", moodText: "Flowing",    moodColorHex: "4DABF7", isFollowing: false),
            SuggestedUser(id: "su3",  displayName: "Maya Chen",       username: "maya_mindful",    avatarColorHex: "805AD5", bio: "Yoga instructor. Mindfulness advocate.",           moodEmoji: "🧘", moodText: "Centered",   moodColorHex: "38B2AC", isFollowing: false),
            SuggestedUser(id: "su4",  displayName: "Kai Nakamura",    username: "kai_runs",        avatarColorHex: "FF6B6B", bio: "Marathon runner. Morning person.",                 moodEmoji: "🏃", moodText: "Energized",  moodColorHex: "F56565", isFollowing: false),
            SuggestedUser(id: "su5",  displayName: "Sage Williams",   username: "sage_reads",      avatarColorHex: "D69E2E", bio: "Bookworm. Tea enthusiast. Quiet observer.",        moodEmoji: "📚", moodText: "Absorbed",   moodColorHex: "4A5568", isFollowing: false),
            SuggestedUser(id: "su6",  displayName: "Aurora James",    username: "aurora_art",      avatarColorHex: "F093FB", bio: "Watercolor artist. Color is my language.",         moodEmoji: "🎨", moodText: "Creative",   moodColorHex: "ED64A6", isFollowing: false),
            SuggestedUser(id: "su7",  displayName: "Jasper Cole",     username: "jasper_hikes",    avatarColorHex: "12B886", bio: "Trail runner. Mountain photographer.",             moodEmoji: "⛰️", moodText: "Adventurous",moodColorHex: "38B2AC", isFollowing: false),
            SuggestedUser(id: "su8",  displayName: "Nova Singh",      username: "nova_codes",      avatarColorHex: "4DABF7", bio: "Developer by day, stargazer by night.",            moodEmoji: "💻", moodText: "Focused",    moodColorHex: "667EEA", isFollowing: false),
            SuggestedUser(id: "su9",  displayName: "Willow Reed",     username: "willow_writes",   avatarColorHex: "A0AEC0", bio: "Poet. Journal keeper. Sunset collector.",          moodEmoji: "✍️", moodText: "Reflective", moodColorHex: "805AD5", isFollowing: false),
            SuggestedUser(id: "su10", displayName: "Finn O'Brien",    username: "finn_surfs",      avatarColorHex: "00B5D8", bio: "Surfer. Ocean lover. Salt in my veins.",           moodEmoji: "🏄", moodText: "Stoked",     moodColorHex: "38B2AC", isFollowing: false),
            SuggestedUser(id: "su11", displayName: "Ivy Martinez",    username: "ivy_grows",       avatarColorHex: "48BB78", bio: "Plant mom. Garden enthusiast.",                    moodEmoji: "🌱", moodText: "Growing",    moodColorHex: "12B886", isFollowing: false),
            SuggestedUser(id: "su12", displayName: "Atlas Kim",       username: "atlas_travels",   avatarColorHex: "E53E3E", bio: "30 countries and counting. Wander often.",         moodEmoji: "✈️", moodText: "Wandering",  moodColorHex: "DD6B20", isFollowing: false),
            SuggestedUser(id: "su13", displayName: "Coral Davis",     username: "coral_sings",     avatarColorHex: "D53F8C", bio: "Singer-songwriter. Music heals.",                  moodEmoji: "🎵", moodText: "Melodic",    moodColorHex: "ED64A6", isFollowing: false),
            SuggestedUser(id: "su14", displayName: "Zane Foster",     username: "zane_lifts",      avatarColorHex: "C05621", bio: "Personal trainer. Discipline is freedom.",         moodEmoji: "💪", moodText: "Strong",     moodColorHex: "DD6B20", isFollowing: false),
            SuggestedUser(id: "su15", displayName: "Pearl Wang",      username: "pearl_cooks",     avatarColorHex: "FAB005", bio: "Home chef. Comfort food creator.",                 moodEmoji: "🍳", moodText: "Nourished",  moodColorHex: "D69E2E", isFollowing: false),
            SuggestedUser(id: "su16", displayName: "Rowan Blake",     username: "rowan_thinks",    avatarColorHex: "718096", bio: "Philosopher. Deep thinker. Quiet rebel.",          moodEmoji: "🤔", moodText: "Thoughtful", moodColorHex: "4A5568", isFollowing: false),
            SuggestedUser(id: "su17", displayName: "Sienna Lopez",    username: "sienna_dances",   avatarColorHex: "F6AD55", bio: "Dancer. Movement is medicine.",                    moodEmoji: "💃", moodText: "Alive",      moodColorHex: "ED64A6", isFollowing: false),
            SuggestedUser(id: "su18", displayName: "Orion Patel",     username: "orion_games",     avatarColorHex: "9F7AEA", bio: "Game designer. Pixel dreamer.",                    moodEmoji: "🎮", moodText: "Playful",    moodColorHex: "805AD5", isFollowing: false),
            SuggestedUser(id: "su19", displayName: "Hazel Brown",     username: "hazel_bakes",     avatarColorHex: "B7791F", bio: "Baker. Spreading sweetness daily.",                moodEmoji: "🧁", moodText: "Sweet",      moodColorHex: "D69E2E", isFollowing: false),
            SuggestedUser(id: "su20", displayName: "Reed Thompson",   username: "reed_meditates",  avatarColorHex: "319795", bio: "Meditation teacher. Stillness is power.",          moodEmoji: "🕯️", moodText: "Serene",     moodColorHex: "38B2AC", isFollowing: false),
            SuggestedUser(id: "su21", displayName: "Ember Fox",       username: "ember_captures",  avatarColorHex: "E53E3E", bio: "Street photographer. Urban stories.",             moodEmoji: "📷", moodText: "Observant",  moodColorHex: "4A5568", isFollowing: false),
            SuggestedUser(id: "su22", displayName: "Sky Tanaka",      username: "sky_breathes",    avatarColorHex: "4299E1", bio: "Breathwork facilitator. Inhale courage.",          moodEmoji: "🌬️", moodText: "Grounded",   moodColorHex: "38B2AC", isFollowing: false),
            SuggestedUser(id: "su23", displayName: "Clover Hayes",    username: "clover_journals", avatarColorHex: "48BB78", bio: "Bullet journal artist. Analog soul.",              moodEmoji: "📓", moodText: "Organized",  moodColorHex: "12B886", isFollowing: false),
            SuggestedUser(id: "su24", displayName: "Blaze Rivera",    username: "blaze_climbs",    avatarColorHex: "DD6B20", bio: "Rock climber. Fear is just a feeling.",            moodEmoji: "🧗", moodText: "Fearless",   moodColorHex: "F56565", isFollowing: false),
            SuggestedUser(id: "su25", displayName: "Iris Zhao",       username: "iris_paints",     avatarColorHex: "9B2C2C", bio: "Oil painter. Every canvas is a conversation.",     moodEmoji: "🖌️", moodText: "Inspired",   moodColorHex: "805AD5", isFollowing: false)
        ]
    }
    
    // swiftlint:disable function_body_length
    private func setupDiscoverPosts() {
        let moodSets: [(emoji: String, text: String, colorHex: String)] = [
            ("😊", "Happy",      "38B2AC"),
            ("😴", "Tired",      "667EEA"),
            ("😌", "Calm",       "4A5568"),
            ("🤩", "Excited",    "ED64A6"),
            ("😢", "Sad",        "A0AEC0"),
            ("😤", "Frustrated", "F56565"),
            ("🥰", "Loved",      "ED64A6"),
            ("🧠", "Mindful",    "805AD5"),
            ("😎", "Confident",  "DD6B20"),
            ("🫣", "Anxious",    "B7791F")
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
            "Breathe in experience, breathe out poetry.",
            "Motion creates emotion.",
            "Rest is a fine medicine.",
            "Celebrate the tiny wins.",
            "Be here now.",
            "Peace is a daily practice.",
            "Joy is what happens when we allow ourselves to recognize how good things are.",
            "Sleep is the best meditation.",
            "Energy is contagious.",
            "Quiet the mind and the soul will speak.",
            "The present moment is filled with joy and happiness.",
            "Grateful hearts see awesome things.",
            "Calm is a super power.",
            "Keep moving, keep growing.",
            "Stars can't shine without darkness.",
            "Inhale courage, exhale fear.",
            "Every day is a fresh start.",
            "Let your light shine.",
            "Small steps lead to big changes.",
            "Stillness speaks louder than noise.",
            "Your vibe attracts your tribe.",
            "Embrace the journey.",
            "Find beauty in the ordinary.",
            "Growth happens outside comfort zones.",
            "Water your own garden.",
            "Trust the timing of your life.",
            "Let go of what you can't control.",
            "Kindness is always in season.",
            "Dream without fear.",
            "Love without limits.",
            "Today is a gift.",
            "Create the life you imagine.",
            "Believe in your inner strength.",
            "Silence is golden.",
            "Rise above the storm.",
            "Bloom where you are planted.",
            "Happiness is homemade.",
            "Adventures await the brave.",
            "Be the energy you want to attract.",
            "Simplicity is the ultimate sophistication.",
            "Your only limit is your mind.",
            "Make peace with the mirror.",
            "Stay wild, moon child.",
            "Let nature be your teacher.",
            "The best view comes after the hardest climb.",
            "Collect moments, not things.",
            "Paint your own reality.",
            "Dance in the rain.",
            "Write your own story.",
            "Stars are just the beginning."
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
        
        allPosts = (0..<100).map { i in
            let userIndex = i % suggestedUsers.count
            let user = suggestedUsers[userIndex]
            let moodIndex = i % moodSets.count
            let mood = moodSets[moodIndex]
            let gradientIndex = i % gradientPairs.count
            let gradient = gradientPairs[gradientIndex]
            let quoteIndex = i % quotes.count
            let captionIndex = i % captions.count
            let heightClass = CardHeightClass.allCases[i % CardHeightClass.allCases.count]
            
            return DiscoverPost(
                id: "dp\(i + 1)",
                userId: user.id,
                userName: user.displayName,
                username: user.username,
                avatarColorHex: user.avatarColorHex,
                moodEmoji: mood.emoji,
                moodText: mood.text,
                moodColorHex: mood.colorHex,
                quoteText: quotes[quoteIndex],
                caption: captions[captionIndex],
                gradientStartHex: gradient.start,
                gradientEndHex: gradient.end,
                likesCount: Int.random(in: 5...120),
                commentsCount: Int.random(in: 0...25),
                isLiked: Bool.random(),
                heightClass: heightClass,
                createdAt: Date().addingTimeInterval(-Double(i * 3600 + Int.random(in: 0...3600)))
            )
        }
    }
    // swiftlint:enable function_body_length
}
