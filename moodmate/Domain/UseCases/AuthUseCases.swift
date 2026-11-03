//
//  AuthUseCases.swift
//  moodmate
//
//  Authentication use cases. View models depend on these protocols, never
//  on AuthServiceProtocol directly.
//

import Foundation

// MARK: - Sign In

nonisolated protocol SignInUseCaseProtocol {
    func execute(email: String, password: String) async throws -> AuthUser
}

nonisolated final class SignInUseCase: SignInUseCaseProtocol {
    private let authService: AuthServiceProtocol

    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }

    func execute(email: String, password: String) async throws -> AuthUser {
        try await authService.signIn(email: email, password: password)
    }
}

// MARK: - Sign Up

nonisolated protocol SignUpUseCaseProtocol {
    func execute(name: String, email: String, password: String) async throws -> AuthUser
}

/// Creates the account and seeds the local profile. The display name is
/// applied directly to the profile rather than read back from the auth
/// user: Firebase's auth-state listener can fire before the displayName
/// write commits and would fall back to an email-derived name.
nonisolated final class SignUpUseCase: SignUpUseCaseProtocol {
    private let authService: AuthServiceProtocol
    private let profileRepository: ProfileRepositoryProtocol

    init(authService: AuthServiceProtocol, profileRepository: ProfileRepositoryProtocol) {
        self.authService = authService
        self.profileRepository = profileRepository
    }

    func execute(name: String, email: String, password: String) async throws -> AuthUser {
        let displayName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let user = try await authService.signUp(email: email, password: password, displayName: displayName)

        if !displayName.isEmpty {
            var profile = profileRepository.getProfile(forId: user.id)
                ?? UserProfile.newAccount(for: user)
            profile.displayName = displayName
            profileRepository.setProfile(profile)
        }

        return user
    }
}

// MARK: - Sign Out

nonisolated protocol SignOutUseCaseProtocol {
    func execute() throws
}

nonisolated final class SignOutUseCase: SignOutUseCaseProtocol {
    private let authService: AuthServiceProtocol

    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }

    func execute() throws {
        try authService.signOut()
    }
}

// MARK: - Current Auth User

nonisolated protocol FetchCurrentAuthUserUseCaseProtocol {
    func execute() -> AuthUser?
}

nonisolated final class FetchCurrentAuthUserUseCase: FetchCurrentAuthUserUseCaseProtocol {
    private let authService: AuthServiceProtocol

    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }

    func execute() -> AuthUser? {
        authService.currentUser
    }
}
