//
//  OwnProfileViewModel.swift
//  moodmate
//
//  Created by Nurtore on 23.07.2026.
//

import SwiftUI
import Combine

@MainActor
final class OwnProfileViewModel: ProfileViewModel {
    private let signOutUseCase: SignOutUseCaseProtocol
    private let syncProfileWithAuthUserUseCase: SyncProfileWithAuthUserUseCaseProtocol

    init(signOutUseCase: SignOutUseCaseProtocol = DIContainer.shared.signOutUseCase,
         syncProfileWithAuthUserUseCase: SyncProfileWithAuthUserUseCaseProtocol = DIContainer.shared.syncProfileWithAuthUserUseCase,
         sessionManager: AppSessionManager? = nil) {
        self.signOutUseCase = signOutUseCase
        self.syncProfileWithAuthUserUseCase = syncProfileWithAuthUserUseCase

        // Resolved in the (MainActor) init body: default argument expressions
        // are nonisolated in Swift 5 language mode.
        let sessionManager = sessionManager ?? DIContainer.shared.sessionManager

        // Placeholder — `targetUserId` is overridden, so this value is never read.
        super.init(userId: sessionManager.currentUser?.id ?? "",
                   sessionManager: sessionManager)

        sessionManager.$currentUser
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                guard let self else { return }
                if let user {
                    self.syncProfileWithAuthUserUseCase.execute(user: user)
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
        try signOutUseCase.execute()
    }
}
