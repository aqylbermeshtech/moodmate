import Foundation

nonisolated protocol FriendsRepositoryProtocol: AnyObject {
    func loadFriends() -> [AppUser]
}
