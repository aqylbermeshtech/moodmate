//
//  InterestsOnboardingViewModel.swift
//  moodmate
//

import Foundation
import Combine

@MainActor
final class InterestsOnboardingViewModel: ObservableObject {

    @Published private(set) var selectedIds: Set<String> = []
    @Published private(set) var isSaving = false
    @Published var errorMessage: String?

    /// Picked order is preserved so the profile lists interests the way the
    /// user chose them rather than in catalog order.
    private var pickOrder: [String] = []

    private let profileRepository: ProfileRepositoryProtocol
    private let authService: AuthServiceProtocol

    init(
        profileRepository: ProfileRepositoryProtocol = ProfileRepository.shared,
        authService: AuthServiceProtocol = FirebaseAuthService.shared
    ) {
        self.profileRepository = profileRepository
        self.authService = authService

        if let existing = profileRepository.getProfile(forId: nil)?.interests, !existing.isEmpty {
            pickOrder = existing
            selectedIds = Set(existing)
        }
    }

    // MARK: - Presentation

    var greeting: String {
        guard let name = authService.currentUserDisplayName, !name.isEmpty else {
            return "What are you into?"
        }
        return "What are you into, \(name)?"
    }

    var minimumSelection: Int { InterestCatalog.minimumSelection }

    var canContinue: Bool {
        selectedIds.count >= minimumSelection && !isSaving
    }

    var selectionHint: String {
        let remaining = minimumSelection - selectedIds.count
        if remaining > 0 {
            return "Pick \(remaining) more to continue"
        }
        return "\(selectedIds.count) selected"
    }

    // MARK: - Actions

    func toggle(_ interest: Interest) {
        if selectedIds.contains(interest.id) {
            selectedIds.remove(interest.id)
            pickOrder.removeAll { $0 == interest.id }
        } else {
            selectedIds.insert(interest.id)
            pickOrder.append(interest.id)
        }
    }

    func save() async {
        guard canContinue else { return }

        isSaving = true
        errorMessage = nil

        do {
            _ = try await profileRepository.updateInterests(
                pickOrder,
                forId: AppSessionManager.currentUserId()
            )
        } catch {
            errorMessage = "Couldn't save your interests. Please try again."
        }

        isSaving = false
    }

    /// The only way out of onboarding — without it a signed-in user with an
    /// unsaveable profile would have nowhere to go.
    func signOut() {
        do {
            try authService.signOut()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
