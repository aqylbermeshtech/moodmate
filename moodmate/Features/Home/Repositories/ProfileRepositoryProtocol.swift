import Combine
import Foundation

protocol ProfileRepositoryProtocol: AnyObject {
    var profileUpdatesPublisher: AnyPublisher<UserProfile, Never> { get }

    func getProfile(forId id: String?) -> UserProfile?

    func getCurrentUserId() -> String
}
