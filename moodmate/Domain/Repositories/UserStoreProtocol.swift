import Foundation

protocol UserStoreProtocol: AnyObject {
    func user(for id: String) -> AppUser?
}
