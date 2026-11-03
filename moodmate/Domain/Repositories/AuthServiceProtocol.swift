//
//  AuthServiceProtocol.swift
//  moodmate
//
//  Domain-facing authentication contract. Implementations live in the data
//  layer (FirebaseAuthService) and speak only in `AuthUser`, never Firebase
//  types.
//

import Foundation

nonisolated protocol AuthServiceProtocol: AnyObject {
    func signIn(email: String, password: String) async throws -> AuthUser
    func signUp(email: String, password: String, displayName: String) async throws -> AuthUser
    func signOut() throws
    func addAuthStateListener(_ listener: @escaping (AuthUser?) -> Void)
    var currentUser: AuthUser? { get }
    var currentUserDisplayName: String? { get }
    func sendEmailVerification() async throws
    func resetPassword(email: String) async throws
}

nonisolated extension AuthServiceProtocol {
    var currentUserDisplayName: String? {
        currentUser?.resolvedDisplayName
    }
}
