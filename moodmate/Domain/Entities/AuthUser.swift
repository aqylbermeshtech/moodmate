//
//  AuthUser.swift
//  moodmate
//
//  Domain representation of the authenticated user. The data layer maps
//  Firebase's `User` onto this type so no domain or presentation code
//  depends on FirebaseAuth.
//

import Foundation

nonisolated struct AuthUser: Equatable {
    let id: String
    let email: String?
    let displayName: String?
    let isEmailVerified: Bool

    /// Display name with an email-prefix fallback, for greetings shown
    /// before the local profile has landed.
    var resolvedDisplayName: String? {
        if let name = displayName, !name.isEmpty { return name }
        if let email,
           let prefix = email.split(separator: "@").first {
            return String(prefix).capitalized
        }
        return nil
    }
}
