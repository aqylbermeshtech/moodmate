//
//  OtherProfileView.swift
//  moodmate
//
//  Created by Nurtore on 23.07.2026.
//

import SwiftUI

struct OtherProfileView: View {
    let userId: String

    @StateObject private var viewModel: ProfileViewModel

    init(userId: String) {
        self.userId = userId
        self._viewModel = StateObject(wrappedValue: ProfileViewModel(userId: userId))
    }

    var body: some View {
        ProfileContentView(
            viewModel: viewModel,
            primaryAction: {
                let isFollowing = viewModel.profile?.isFollowing ?? false
                Button(action: {
                    viewModel.toggleFollow()
                }) {
                    Text(isFollowing ? "Following" : "Follow")
                        .font(.xButton)
                        .foregroundStyle(isFollowing ? Color.theme.primaryText : .black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            isFollowing
                                ? Color.clear
                                : Color.theme.primaryText
                        )
                        .clipShape(Capsule())
                        .overlay(
                            Capsule().strokeBorder(
                                isFollowing ? Color.theme.divider : Color.clear,
                                lineWidth: 1
                            )
                        )
                }
                .buttonStyle(XPressableStyle())
            },
            toolbarTrailing: {
                EmptyView()
            }
        )
    }
}

#Preview {
    NavigationStack {
        OtherProfileView(userId: "preview_user")
    }
    .environmentObject(AppRouter.shared)
}
