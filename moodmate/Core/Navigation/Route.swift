//
//  Route.swift
//  moodmate
//

import Foundation

/// Cases carry only primitive ids (never objects) so a deep link can drive
/// the same navigation a tap does.
enum Route: Hashable {
    case otherProfile(userId: String)
    case editProfile
    case settings
    case followList(type: FollowType, userId: String)
    case postDetail(postId: String)
    case chatThread(userId: String)
}

enum FullScreenRoute: Identifiable, Hashable {
    case createPost
    var id: Self { self }
}
