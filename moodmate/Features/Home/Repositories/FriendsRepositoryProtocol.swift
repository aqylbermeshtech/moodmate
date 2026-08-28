import Foundation

protocol FriendsRepositoryProtocol: AnyObject {
    func loadFriends() -> [AppUser]
}
