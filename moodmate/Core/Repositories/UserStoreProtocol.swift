import Foundation

protocol UserStoreProtocol: AnyObject {
    /// The canonical display identity (name, username, avatar, current
    /// mood) for a user id, or nil if unknown. Views read this directly at
    /// render time instead of holding their own copy — there is nothing to
    /// keep in sync manually.
    func moodUser(for id: String) -> MoodUser?
}
