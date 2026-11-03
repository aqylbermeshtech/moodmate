//
//  AuthUser+Mapping.swift
//  moodmate
//
//  FirebaseAuth → domain mapping. This is the only place outside the auth
//  service itself that knows Firebase's `User` exists.
//

import Foundation
import FirebaseAuth

nonisolated extension AuthUser {
    init(firebaseUser: User) {
        self.init(
            id: firebaseUser.uid,
            email: firebaseUser.email,
            displayName: firebaseUser.displayName,
            isEmailVerified: firebaseUser.isEmailVerified
        )
    }
}
