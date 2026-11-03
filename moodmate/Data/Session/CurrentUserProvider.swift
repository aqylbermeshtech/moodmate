//
//  CurrentUserProvider.swift
//  moodmate
//
//  Data-layer implementation of CurrentUserProviderProtocol, backed by the
//  auth service. Injected into repositories and use cases so nothing
//  reaches for a static singleton mid-call.
//

import Foundation

nonisolated final class CurrentUserProvider: CurrentUserProviderProtocol {
    private let authService: AuthServiceProtocol

    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }

    var currentUserId: String {
        authService.currentUser?.id ?? ""
    }
}
