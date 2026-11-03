//
//  CurrentUserProviderProtocol.swift
//  moodmate
//
//  Read-only access to the signed-in user's id. Replaces the hidden static
//  `AppSessionManager.currentUserId()` dependency that repositories and
//  services used to reach for.
//
//  Empty while signed out. The app UI is gated behind authentication, so
//  callers only ever see a real id from a screen the user can reach.
//

import Foundation

nonisolated protocol CurrentUserProviderProtocol: AnyObject {
    var currentUserId: String { get }
}
