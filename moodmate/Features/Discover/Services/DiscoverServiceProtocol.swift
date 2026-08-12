import Foundation

protocol DiscoverServiceProtocol: AnyObject {
    func getTrendingMoods() async -> [TrendingMood]

    func getSuggestedUsers() async -> [SuggestedUser]

    func getHashtags() async -> [DiscoverHashtag]

    func getCategories() async -> [DiscoverCategory]

    func getDiscoverPosts(page: Int, mood: TrendingMood?, category: DiscoverCategory?, hashtag: DiscoverHashtag?) async -> [DiscoverPost]

    func search(query: String) async -> [SearchResult]

    func toggleFollow(userId: String)

    func toggleLike(postId: String)
}

extension DiscoverServiceProtocol {
    func getDiscoverPosts(page: Int, mood: TrendingMood? = nil, category: DiscoverCategory? = nil, hashtag: DiscoverHashtag? = nil) async -> [DiscoverPost] {
        await getDiscoverPosts(page: page, mood: mood, category: category, hashtag: hashtag)
    }
}
