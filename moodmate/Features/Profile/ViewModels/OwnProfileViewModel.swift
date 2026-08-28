//
//  OwnProfileViewModel.swift
//  moodmate
//
//  Created by Nurtore on 23.07.2026.
//

import SwiftUI
import FirebaseAuth
import Combine

@MainActor
final class OwnProfileViewModel: ProfileViewModel {
    private let authService: AuthServiceProtocol

    init(profileRepository: ProfileRepositoryProtocol = ProfileRepository.shared,
         followRepository: FollowRepositoryProtocol = FollowRepository.shared,
         sessionManager: AppSessionManager = AppSessionManager.shared,
         authService: AuthServiceProtocol = FirebaseAuthService.shared,
         postRepository: PostRepositoryProtocol = PostRepository.shared) {
        self.authService = authService

        // Placeholder — `targetUserId` is overridden, so this value is never read.
        super.init(userId: sessionManager.currentUser?.uid ?? "",
                    profileRepository: profileRepository,
                    followRepository: followRepository,
                    sessionManager: sessionManager,
                    postRepository: postRepository)

        sessionManager.$currentUser
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                guard let self else { return }
                if let user {
                    profileRepository.syncWithFirebaseUser(user: user)
                    self.loadProfile()
                } else {
                    self.profile = nil
                    self.resetPosts()
                    self.isLoading = false
                }
            }
            .store(in: &cancellables)
    }

    override var targetUserId: String { getCurrentUserId() }

    var isWaitingForAuthentication: Bool {
        profile == nil && sessionManager.currentUser == nil
    }

    func signOut() throws {
        try authService.signOut()
    }
}
