//
//  FollowListView.swift
//  moodmate
//
//  Created by Nurtore on 23.07.2026.
//

import SwiftUI

enum FollowType {
    case followers
    case following
}

struct FollowListView: View {
    let type: FollowType
    @ObservedObject var viewModel: ProfileViewModel
    
    @State private var searchText = ""
    @State private var users: [UserProfile] = []
    
    var filteredUsers: [UserProfile] {
        if searchText.isEmpty {
            return users
        } else {
            return users.filter {
                $0.displayName.localizedCaseInsensitiveContains(searchText) ||
                $0.username.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        ZStack {
            Color.theme.backgroundGradient
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                searchBarField
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 16)
                
                if filteredUsers.isEmpty {
                    emptyStateView
                } else {
                    ScrollView {
                        LazyVStack(spacing: 14) {
                            ForEach(filteredUsers) { user in
                                NavigationLink(destination: ProfileView(userId: user.id)) {
                                    userRow(user: user)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 40)
                    }
                }
            }
        }
        .navigationTitle(type == .followers ? "Followers" : "Following")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadUsers()
        }
    }
    
    // MARK: - Search Bar View
    private var searchBarField: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Color.theme.secondaryText)
            
            TextField("Search users...", text: $searchText)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .foregroundStyle(Color.theme.primaryText)
            
            if !searchText.isEmpty {
                Button(action: { searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Color.theme.secondaryText)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.theme.border, lineWidth: 1)
        )
    }
    
    // MARK: - User Row View
    private func userRow(user: UserProfile) -> some View {
        HStack(spacing: 12) {
            AvatarView(
                imageData: user.avatarImageData,
                name: user.displayName,
                colorHex: user.avatarColorHex,
                size: 44,
                showBorder: true,
                moodEmoji: user.currentMoodEmoji
            )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(user.displayName)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.theme.primaryText)
                
                Text("@\(user.username)")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.theme.secondaryText)
            }
            
            Spacer()

            if user.id != viewModel.getCurrentUserId() {
                Button(action: {
                    toggleFollow(for: user)
                }) {
                    Text(user.isFollowing ? "Following" : "Follow")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(user.isFollowing ? Color.theme.primaryText : Color.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(
                            Group {
                                if user.isFollowing {
                                    Color.theme.groupedBackground
                                } else {
                                    Color.teal
                                }
                            }
                        )
                        .clipShape(Capsule())
                }
                .buttonStyle(ScaleButtonStyle())
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color.theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.theme.border, lineWidth: 1)
        )
    }
    
    // MARK: - Empty State View
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "person.2.slash.fill")
                .font(.system(size: 44))
                .foregroundStyle(Color.theme.secondaryText)
            Text(searchText.isEmpty ? "No users here yet" : "No results match '\(searchText)'")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(Color.theme.secondaryText)
            Spacer()
        }
        .padding(.bottom, 60)
    }
    
    // MARK: - Helpers
    private func loadUsers() {
        viewModel.loadFollowersAndFollowing()
        users = type == .followers ? viewModel.followers : viewModel.following
    }
    
    private func toggleFollow(for user: UserProfile) {
        if let idx = users.firstIndex(where: { $0.id == user.id }) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                if let updated = ProfileService.shared.toggleFollow(targetId: user.id) {
                    users[idx] = updated
                }
            }
        }
    }
    
}

#Preview {
    NavigationStack {
        FollowListView(type: .followers, viewModel: ProfileViewModel())
    }
}
