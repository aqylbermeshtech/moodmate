//
//  Route.swift
//  moodmate
//

import Foundation

/// A pushed destination within one of the app's per-tab navigation stacks.
/// Every case carries only primitive ids, never a hydrated object or view
/// model — that's what lets a deep link (which only ever has an id) drive
/// the same navigation a tap does.
enum Route: Hashable {
    case otherProfile(userId: String)
    case editProfile
    case settings
    case followList(type: FollowType, userId: String)
    case postDetail(postId: String)
}

/// A screen-shaped full-screen modal, addressable by the router.
enum FullScreenRoute: Identifiable, Hashable {
    case createPost
    var id: Self { self }
}

/// A screen-shaped sheet, addressable by the router.
enum SheetRoute: Identifiable, Hashable {
    case dayDetail(recordId: String)
    var id: Self { self }
}
