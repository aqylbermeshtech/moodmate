//
//  FirebaseAuthService.swift
//  moodmate
//
//  Created by Nurtore on 21.07.2026.
//
//  Firebase implementation of AuthServiceProtocol. All Firebase types are
//  mapped to domain `AuthUser` at this boundary.
//

import Foundation
import FirebaseAuth

nonisolated final class FirebaseAuthService: AuthServiceProtocol {
    private var authListenerHandles: [AuthStateDidChangeListenerHandle] = []

    init() {}

    func signIn(email: String, password: String) async throws -> AuthUser {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        return AuthUser(firebaseUser: result.user)
    }

    func signUp(email: String, password: String, displayName: String) async throws -> AuthUser {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)

        let trimmedName = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedName.isEmpty {
            let changeRequest = result.user.createProfileChangeRequest()
            changeRequest.displayName = trimmedName
            try await changeRequest.commitChanges()
        }

        return AuthUser(firebaseUser: result.user)
    }

    func signOut() throws {
        try Auth.auth().signOut()
    }

    func addAuthStateListener(_ listener: @escaping (AuthUser?) -> Void) {
        let handle = Auth.auth().addStateDidChangeListener { _, user in
            listener(user.map(AuthUser.init(firebaseUser:)))
        }
        authListenerHandles.append(handle)
    }

    func removeAllAuthStateListeners() {
        for handle in authListenerHandles {
            Auth.auth().removeStateDidChangeListener(handle)
        }
        authListenerHandles.removeAll()
    }

    var currentUser: AuthUser? {
        Auth.auth().currentUser.map(AuthUser.init(firebaseUser:))
    }

    func sendEmailVerification() async throws {
        guard let user = Auth.auth().currentUser else {
            throw AppError.notAuthenticated
        }
        try await user.sendEmailVerification()
    }

    func resetPassword(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
}
