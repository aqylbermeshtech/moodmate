//
//  ProfileRepositoryProtocol.swift
//  moodmate
//
//  Narrow read-only profile access contract used by HomeViewModel.
//  Keeps HomeViewModel decoupled from the full ProfileServiceProtocol,
//  making it easy to mock in tests.
//

import Combine
import Foundation

protocol ProfileRepositoryProtocol: AnyObject {
    /// Emits whenever any profile is updated anywhere in the app.
    var profileUpdatesPublisher: AnyPublisher<UserProfile, Never> { get }

    /// Returns the profile for the given id synchronously from the in-memory store.
    /// Pass `nil` to get the currently authenticated user's profile.
    func getProfile(forId id: String?) -> UserProfile?

    /// Returns the stable identifier for the currently authenticated user.
    func getCurrentUserId() -> String
}
