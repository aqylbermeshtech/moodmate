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
                    HStack {
                        Image(systemName: isFollowing ? "checkmark" : "person.badge.plus.fill")
                            .font(.system(size: 14, weight: .bold))
                        Text(isFollowing ? "Following" : "Follow")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                    }
                    .foregroundStyle(isFollowing ? Color.theme.primaryText : Color.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(isFollowing ? Color.theme.groupedBackground : Color.theme.accent)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .shadow(color: isFollowing ? Color.clear : Color.teal.opacity(0.2), radius: 6, x: 0, y: 3)
                }
                .buttonStyle(ScaleButtonStyle())
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
