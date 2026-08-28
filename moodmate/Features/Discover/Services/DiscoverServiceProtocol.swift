import Foundation

protocol DiscoverServiceProtocol: AnyObject {
    func getSuggestedUsers() async -> [SuggestedUser]

    func getHashtags() async -> [DiscoverHashtag]

    func getCategories() async -> [DiscoverCategory]

    func getDiscoverPosts(page: Int, category: DiscoverCategory?, hashtag: DiscoverHashtag?) async -> [DiscoverPost]

    func search(query: String) async -> [SearchResult]

    func toggleFollow(userId: String)
}

extension DiscoverServiceProtocol {
    func getDiscoverPosts(page: Int, category: DiscoverCategory? = nil, hashtag: DiscoverHashtag? = nil) async -> [DiscoverPost] {
        await getDiscoverPosts(page: page, category: category, hashtag: hashtag)
    }
}
