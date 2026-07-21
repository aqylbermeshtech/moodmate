//
//  FirebaseAuthManager.swift
//  moodmate
//
//  Created by Nurtore on 21.07.2026.
//

import Foundation
import FirebaseAuth

final class FirebaseAuthService {
    static let shared = FirebaseAuthService()
    private init() {}
    private var authListenerHandles: [AuthStateDidChangeListenerHandle] = []

    func signIn(email: String, password: String) async throws -> User {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        return result.user
    }

    func signUp(email: String, password: String) async throws -> User {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        return result.user
    }

    func signOut() throws {
        try Auth.auth().signOut()
    }

    func addAuthStateListener(_ listener: @escaping (User?) -> Void) {
        let handle = Auth.auth().addStateDidChangeListener { _, user in
            listener(user)
        }
        authListenerHandles.append(handle)
    }

    func removeAllAuthStateListeners() {
        for handle in authListenerHandles {
            Auth.auth().removeStateDidChangeListener(handle)
        }
        authListenerHandles.removeAll()
    }

    var currentUser: User? {
        return Auth.auth().currentUser
    }

    func sendEmailVerification() async throws {
        guard let user = Auth.auth().currentUser else {
            throw NSError(
                domain: "FirebaseAuthService",
                code: 0,
                userInfo: [NSLocalizedDescriptionKey: "No user signed in."]
            )
        }
        try await user.sendEmailVerification()
    }

    func resetPassword(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
}
