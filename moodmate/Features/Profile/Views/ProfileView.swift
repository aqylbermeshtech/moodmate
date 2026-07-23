//
//  ProfileView.swift
//  moodmate
//
//  Created by Nurtore on 23.07.2026.
//

import SwiftUI

struct ProfileView: View {
    let userId: String?
    
    @StateObject private var viewModel: ProfileViewModel
    @State private var showShareSheet = false
    @State private var showShareAlert = false
    
    init(userId: String? = nil) {
        self.userId = userId
        self._viewModel = StateObject(wrappedValue: ProfileViewModel(userId: userId))
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
            
            if viewModel.isLoading {
                ProgressView("Loading Profile...")
                    .font(.system(.body, design: .rounded))
                    .tint(.teal)
            } else if let profile = viewModel.profile {
                ScrollView {
                    VStack(spacing: 24) {
                        // 1. Large Profile Header
                        profileHeaderView(profile: profile)
                            .padding(.horizontal, 20)
                            .padding(.top, 10)
                        
                        // 2. Statistics Section
                        statsView(profile: profile)
                            .padding(.horizontal, 20)
                        
                        // 3. Action Buttons
                        actionsView(profile: profile)
                            .padding(.horizontal, 20)
                        
                        // 4. Mood History (Calendar / Timeline)
                        moodHistoryView(profile: profile)
                            .padding(.horizontal, 20)
                        
                        // 5. Analytics (Weekly chart & insights)
                        analyticsSection(profile: profile)
                            .padding(.horizontal, 20)
                        
                        // 6. Achievements Section
                        achievementsSection(profile: profile)
                        
                        // 7. Posts Section (3-column adaptive grid with lazy loading)
                        postsSection(profile: profile)
                        
                        Spacer(minLength: 100) // Space for bottom tab bar overlay
                    }
                }
                .scrollIndicators(.hidden)
                .refreshable {
                    viewModel.loadProfile()
                }
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "person.crop.circle.badge.exclamationmark")
                        .font(.system(size: 64))
                        .foregroundStyle(.secondary)
                    Text("Profile Not Found")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                    Text("Could not load user profile details. Please try again.")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    Button("Retry") {
                        viewModel.loadProfile()
                    }
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.teal)
                    .clipShape(Capsule())
                }
            }
        }
        .navigationTitle(viewModel.profile?.username != nil ? "@\(viewModel.profile!.username)" : "Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if viewModel.isOwnProfile {
                ToolbarItem(placement: .primaryAction) {
                    NavigationLink(destination: SettingsView(viewModel: viewModel)) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 18))
                            .foregroundStyle(.primary)
                    }
                }
            }
        }
        .onAppear {
            viewModel.loadProfile()
        }
        .alert("Share Profile", isPresented: $showShareAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            if let profile = viewModel.profile {
                Text("Profile link copied! Share @\(profile.username)'s mindful progress with friends.")
            } else {
                Text("Profile link copied!")
            }
        }
    }
    
    // MARK: - 1. Profile Header View
    private func profileHeaderView(profile: UserProfile) -> some View {
        VStack(spacing: 16) {
            // Profile image with initials + current mood badge
            ZStack(alignment: .bottomTrailing) {
                // Main initials bubble
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: profile.avatarColorHex).opacity(0.85), Color(hex: profile.avatarColorHex)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    Text(getInitials(profile.displayName))
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }
                .frame(width: 96, height: 96)
                .shadow(color: Color(hex: profile.avatarColorHex).opacity(0.25), radius: 10, x: 0, y: 6)
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 3)
                )
                
                // Mood Emoji badge overlay
                if let moodEmoji = profile.currentMoodEmoji {
                    ZStack {
                        Circle()
                            .fill(Color(.systemBackground))
                            .frame(width: 32, height: 32)
                            .shadow(color: .black.opacity(0.12), radius: 4, x: 0, y: 2)
                        
                        Text(moodEmoji)
                            .font(.system(size: 18))
                    }
                    .transition(.scale)
                }
            }
            
            // Name, Username & bio
            VStack(spacing: 4) {
                Text(profile.displayName)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                
                Text("@\(profile.username)")
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
                
                if !profile.bio.isEmpty {
                    Text(profile.bio)
                        .font(.system(size: 14))
                        .foregroundStyle(.primary.opacity(0.85))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                        .padding(.top, 4)
                }
            }
            
            // Streak badge
            if profile.moodStreak > 0 {
                HStack(spacing: 6) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(.orange)
                    Text("\(profile.moodStreak) Days Streak")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(.orange)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.orange.opacity(0.08))
                .clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color(.systemBackground).opacity(0.4))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.secondary.opacity(0.08), lineWidth: 1)
        )
    }
    
    // MARK: - 2. Statistics Row
    private func statsView(profile: UserProfile) -> some View {
        HStack {
            statsItem(title: "Posts", count: profile.postsCount)
            
            Divider()
                .frame(height: 30)
                .background(Color.secondary.opacity(0.3))
            
            NavigationLink(destination: FollowListView(type: .followers, viewModel: viewModel)) {
                statsItem(title: "Followers", count: profile.followersCount)
            }
            .buttonStyle(PlainButtonStyle())
            
            Divider()
                .frame(height: 30)
                .background(Color.secondary.opacity(0.3))
            
            NavigationLink(destination: FollowListView(type: .following, viewModel: viewModel)) {
                statsItem(title: "Following", count: profile.followingCount)
            }
            .buttonStyle(PlainButtonStyle())
            
            Divider()
                .frame(height: 30)
                .background(Color.secondary.opacity(0.3))
            
            statsItem(title: "Streak", count: profile.moodStreak)
        }
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground).opacity(0.4))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.secondary.opacity(0.08), lineWidth: 1)
        )
    }
    
    private func statsItem(title: String, count: Int) -> some View {
        VStack(spacing: 4) {
            Text("\(count)")
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - 3. Action Buttons Row
    private func actionsView(profile: UserProfile) -> some View {
        HStack(spacing: 12) {
            if viewModel.isOwnProfile {
                // Edit Profile Button
                NavigationLink(destination: EditProfileView(viewModel: viewModel)) {
                    HStack {
                        Image(systemName: "pencil")
                            .font(.system(size: 14, weight: .bold))
                        Text("Edit Profile")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.teal)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .shadow(color: Color.teal.opacity(0.2), radius: 6, x: 0, y: 3)
                }
                .buttonStyle(ScaleButtonStyle())
            } else {
                // Follow / Unfollow Button
                Button(action: {
                    viewModel.toggleFollow()
                }) {
                    HStack {
                        Image(systemName: profile.isFollowing ? "checkmark" : "person.badge.plus.fill")
                            .font(.system(size: 14, weight: .bold))
                        Text(profile.isFollowing ? "Following" : "Follow")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                    }
                    .foregroundStyle(profile.isFollowing ? Color.primary : Color.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(profile.isFollowing ? Color.secondary.opacity(0.15) : Color.teal)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .shadow(color: profile.isFollowing ? Color.clear : Color.teal.opacity(0.2), radius: 6, x: 0, y: 3)
                }
                .buttonStyle(ScaleButtonStyle())
            }
            
            // Share Button
            Button(action: {
                showShareAlert = true
            }) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 14, weight: .bold))
                    Text("Share")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                }
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color(.systemBackground).opacity(0.6))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.secondary.opacity(0.12), lineWidth: 1)
                )
            }
            .buttonStyle(ScaleButtonStyle())
        }
    }
    
    // MARK: - 4. Mood History Row (Calendar / Timeline)
    private func moodHistoryView(profile: UserProfile) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Mood History")
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
            
            HStack(spacing: 8) {
                // Show last 7 days of mood entries
                ForEach(profile.moodHistory.reversed().prefix(7)) { entry in
                    VStack(spacing: 8) {
                        Text(dayOfWeekAbbreviation(for: entry.date))
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.secondary)
                        
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color(hex: entry.colorHex).opacity(0.8), Color(hex: entry.colorHex)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 36, height: 36)
                            
                            Text(entry.emoji)
                                .font(.system(size: 18))
                        }
                        .overlay(
                            Circle()
                                .stroke(Color.teal, lineWidth: Calendar.current.isDateInToday(entry.date) ? 2 : 0)
                                .frame(width: 40, height: 40)
                        )
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 8)
            .background(Color(.systemBackground).opacity(0.4))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.secondary.opacity(0.08), lineWidth: 1)
            )
        }
    }
    
    // MARK: - 5. Analytics Section (Weekly Chart)
    private func analyticsSection(profile: UserProfile) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Analytics & Insights")
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
            
            VStack(spacing: 16) {
                // 7-day Bar Chart Visualization
                HStack(alignment: .bottom, spacing: 12) {
                    ForEach(profile.moodHistory.reversed().prefix(7)) { entry in
                        VStack(spacing: 8) {
                            Spacer()
                            
                            // Height of bar based on mood value simulator
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [Color(hex: entry.colorHex), Color(hex: entry.colorHex).opacity(0.6)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(height: CGFloat(moodValue(for: entry.emoji) * 22))
                                .frame(width: 20)
                            
                            Text(dayOfWeekAbbreviation(for: entry.date))
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .frame(height: 140)
                .padding(.top, 10)
                
                Divider().opacity(0.3)
                
                // Insights summary
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("MOST COMMON MOOD")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(.secondary)
                        
                        HStack(spacing: 6) {
                            Text(mostCommonMoodEmoji(profile.moodHistory))
                                .font(.system(size: 20))
                            Text(mostCommonMoodText(profile.moodHistory))
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundStyle(.primary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("WEEKLY PROGRESS")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(.secondary)
                        
                        Text("7 / 7 check-ins")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(.teal)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(16)
            .background(Color(.systemBackground).opacity(0.4))
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Color.secondary.opacity(0.08), lineWidth: 1)
            )
        }
    }
    
    // MARK: - 6. Achievements Section
    private func achievementsSection(profile: UserProfile) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Achievements")
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
                .padding(.horizontal, 20)
            
            if profile.achievements.isEmpty {
                Text("No achievements unlocked yet.")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 20)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 14) {
                        ForEach(profile.achievements) { achievement in
                            achievementCard(achievement: achievement)
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
    }
    
    private func achievementCard(achievement: Achievement) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.teal.opacity(0.1))
                    .frame(width: 48, height: 48)
                
                Image(systemName: achievement.icon)
                    .font(.system(size: 20))
                    .foregroundStyle(.teal)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(achievement.title)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                
                Text(achievement.description)
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .frame(width: 140, alignment: .leading)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color(.systemBackground).opacity(0.4))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.secondary.opacity(0.08), lineWidth: 1)
        )
    }
    
    // MARK: - 7. Posts Section (Adaptive Grid)
    private func postsSection(profile: UserProfile) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Logged Moments")
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
                .padding(.horizontal, 20)
            
            if viewModel.posts.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "doc.text.image.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(.secondary)
                    Text("No moments logged yet")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                let columns = Array(repeating: GridItem(.flexible(), spacing: 3), count: 3)
                
                LazyVGrid(columns: columns, spacing: 3) {
                    ForEach(viewModel.posts) { post in
                        NavigationLink(destination: PostDetailView(post: post, user: profile)) {
                            postGridCell(post: post)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .onAppear {
                            // Detect when we reach the last post to simulate lazy loading
                            if post.id == viewModel.posts.last?.id {
                                viewModel.loadMorePosts()
                            }
                        }
                    }
                }
                .padding(.horizontal, 2)
                
                // Show ProgressView while lazy loading
                if viewModel.isLazyLoadingPosts {
                    HStack {
                        Spacer()
                        ProgressView()
                            .tint(.teal)
                            .padding(.vertical, 12)
                        Spacer()
                    }
                }
            }
        }
    }
    
    private func postGridCell(post: ProfilePost) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: post.postGradientStartHex), Color(hex: post.postGradientEndHex)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .aspectRatio(1, contentMode: .fit)
            
            VStack {
                Image(systemName: "quote.opening")
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.5))
                
                Text(post.quoteText)
                    .font(.system(size: 9, weight: .bold, design: .serif))
                    .foregroundStyle(.white)
                    .lineLimit(3)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 6)
                
                Image(systemName: "quote.closing")
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.5))
            }
            .padding(4)
        }
    }
    
    // MARK: - Helpers
    private func getInitials(_ name: String) -> String {
        let parts = name.split(separator: " ")
        if parts.count >= 2, let first = parts[0].first, let second = parts[1].first {
            return "\(first)\(second)".uppercased()
        } else if let first = name.first {
            return String(first).uppercased()
        }
        return "?"
    }
    
    private func dayOfWeekAbbreviation(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E" // Sun, Mon, etc.
        return String(formatter.string(from: date).first ?? "M")
    }
    
    private func moodValue(for emoji: String) -> Int {
        switch emoji {
        case "😊", "🤩": return 5
        case "😌", "🧠": return 4
        case "😴": return 3
        case "😔": return 2
        default: return 3
        }
    }
    
    private func mostCommonMoodEmoji(_ entries: [MoodHistoryEntry]) -> String {
        guard !entries.isEmpty else { return "😊" }
        let counts = entries.map { $0.emoji }.reduce(into: [:]) { counts, emoji in
            counts[emoji, default: 0] += 1
        }
        return counts.max(by: { $0.value < $1.value })?.key ?? "😊"
    }
    
    private func mostCommonMoodText(_ entries: [MoodHistoryEntry]) -> String {
        guard !entries.isEmpty else { return "Happy" }
        let counts = entries.map { $0.text }.reduce(into: [:]) { counts, text in
            counts[text, default: 0] += 1
        }
        return counts.max(by: { $0.value < $1.value })?.key ?? "Happy"
    }
}

#Preview {
    NavigationStack {
        ProfileView()
    }
}
