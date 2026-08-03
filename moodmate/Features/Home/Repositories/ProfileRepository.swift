//
//  ProfileRepository.swift
//  moodmate
//
//  Thin adapter that satisfies ProfileRepositoryProtocol by delegating
//  to the app-wide ProfileServiceProtocol. HomeViewModel never imports
//  ProfileService directly — it only depends on this narrower protocol.
//

import Combine
import Foundation

final class ProfileRepository: ProfileRepositoryProtocol {

    private let service: ProfileServiceProtocol

    init(service: ProfileServiceProtocol = ProfileService.shared) {
        self.service = service
    }

    var profileUpdatesPublisher: AnyPublisher<UserProfile, Never> {
        service.profileUpdatesPublisher
    }

    func getProfile(forId id: String?) -> UserProfile? {
        service.getProfile(forId: id)
    }

    func getCurrentUserId() -> String {
        service.getCurrentUserId()
    }
}
