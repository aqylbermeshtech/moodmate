import Foundation

protocol FollowRepositoryProtocol: AnyObject {
    func toggleFollow(targetId: String) -> UserProfile?

    func getFollowers(forId id: String?) -> [UserProfile]

    func getFollowing(forId id: String?) -> [UserProfile]
}
