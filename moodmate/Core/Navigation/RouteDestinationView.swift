//
//  RouteDestinationView.swift
//  moodmate
//

import SwiftUI

/// Single place mapping a `Route` to the screen it represents — used
/// identically by every tab's `.navigationDestination(for: Route.self)` so
/// the mapping is written once, not once per tab.
struct RouteDestinationView: View {
    let route: Route

    var body: some View {
        switch route {
        case .otherProfile(let userId):
            OtherProfileView(userId: userId)
        case .editProfile:
            EditProfileView()
        case .settings:
            SettingsView(viewModel: OwnProfileViewModel())
        case .followList(let type, let userId):
            FollowListView(type: type, userId: userId)
        case .postDetail(let postId):
            PostDetailView(postId: postId)
        case .chatThread(let userId):
            ChatThreadView(userId: userId)
        }
    }
}
