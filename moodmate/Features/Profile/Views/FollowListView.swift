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
            // Premium background gradient
            LinearGradient(
                colors: [Color.teal.opacity(0.12), Color.purple.opacity(0.08)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Custom Search Bar
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
                .foregroundStyle(.secondary)
            
            TextField("Search users...", text: $searchText)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            
            if !searchText.isEmpty {
                Button(action: { searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color(.systemBackground).opacity(0.8))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.secondary.opacity(0.15), lineWidth: 1)
        )
    }
    
    // MARK: - User Row View
    private func userRow(user: UserProfile) -> some View {
        HStack(spacing: 12) {
            // Gradient Avatar
            ZStack(alignment: .bottomTrailing) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: user.avatarColorHex).opacity(0.85), Color(hex: user.avatarColorHex)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    Text(getInitials(user.displayName))
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }
                .frame(width: 44, height: 44)
                
                // Mini mood emoji badge overlay
                if let emoji = user.currentMoodEmoji {
                    ZStack {
                        Circle()
                            .fill(Color(.systemBackground))
                            .frame(width: 18, height: 18)
                        Text(emoji)
                            .font(.system(size: 11))
                    }
                    .offset(x: 2, y: 2)
                    .shadow(radius: 2)
                }
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(user.displayName)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(.primary)
                
                Text("@\(user.username)")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Follow / Unfollow Button
            if user.id != viewModel.getCurrentUserId() {
                Button(action: {
                    toggleFollow(for: user)
                }) {
                    Text(user.isFollowing ? "Following" : "Follow")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(user.isFollowing ? Color.primary : Color.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(
                            Group {
                                if user.isFollowing {
                                    Color.secondary.opacity(0.15)
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
        .background(Color(.systemBackground).opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.secondary.opacity(0.1), lineWidth: 1)
        )
    }
    
    // MARK: - Empty State View
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "person.2.slash.fill")
                .font(.system(size: 44))
                .foregroundStyle(.secondary)
            Text(searchText.isEmpty ? "No users here yet" : "No results match '\(searchText)'")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(.secondary)
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
    
    private func getInitials(_ name: String) -> String {
        let parts = name.split(separator: " ")
        if parts.count >= 2, let first = parts[0].first, let second = parts[1].first {
            return "\(first)\(second)".uppercased()
        } else if let first = name.first {
            return String(first).uppercased()
        }
        return "?"
    }
}

#Preview {
    NavigationStack {
        FollowListView(type: .followers, viewModel: ProfileViewModel())
    }
}
