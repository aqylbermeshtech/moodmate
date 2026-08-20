//
//  ProfileContentView.swift
//  moodmate
//
//  Created by Nurtore on 23.07.2026.
//

import SwiftUI

/// Presentational profile screen shared by `MyProfileView` and
/// `OtherProfileView`. Everything here is common to viewing your own
/// profile and viewing someone else's; the two things that actually
/// differ — the primary action button and the trailing toolbar item — are
/// injected by the caller instead of being branched on internally.
struct ProfileContentView<PrimaryAction: View, ToolbarTrailing: View>: View {
    @ObservedObject var viewModel: ProfileViewModel
    @EnvironmentObject private var router: AppRouter
    private let primaryAction: () -> PrimaryAction
    private let toolbarTrailing: () -> ToolbarTrailing

    @State private var showShareSheet = false
    @State private var showShareAlert = false

    init(viewModel: ProfileViewModel,
         @ViewBuilder primaryAction: @escaping () -> PrimaryAction,
         @ViewBuilder toolbarTrailing: @escaping () -> ToolbarTrailing) {
        self.viewModel = viewModel
        self.primaryAction = primaryAction
        self.toolbarTrailing = toolbarTrailing
    }

    var body: some View {
        ZStack {
            Color.theme.primaryBackground
                .ignoresSafeArea()

            if viewModel.isLoading {
                ProgressView("Loading Profile...")
                    .font(.xPostBody)
                    .foregroundStyle(Color.theme.secondaryText)
                    .tint(Color.theme.accent)
            } else if let profile = viewModel.profile {
                ScrollView {
                    VStack(spacing: 0) {
                        profileHeaderView(profile: profile)

                        // Stats inline
                        statsView(profile: profile)
                            .padding(.horizontal, 16)
                            .padding(.top, 12)

                        // Bio
                        if !profile.bio.isEmpty {
                            Text(profile.bio)
                                .font(.xPostBody)
                                .foregroundStyle(Color.theme.primaryText)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 16)
                                .padding(.top, 12)
                        }

                        // Action buttons
                        actionsView(profile: profile)
                            .padding(.horizontal, 16)
                            .padding(.top, 16)

                        Rectangle().fill(Color.theme.divider).frame(height: 0.5)
                            .padding(.top, 16)

                        // Mood history
                        moodHistoryView(profile: profile)
                            .padding(.horizontal, 16)
                            .padding(.top, 16)

                        Rectangle().fill(Color.theme.divider).frame(height: 0.5)
                            .padding(.top, 16)

                        // Analytics
                        analyticsSection(profile: profile)
                            .padding(.horizontal, 16)
                            .padding(.top, 16)

                        Rectangle().fill(Color.theme.divider).frame(height: 0.5)
                            .padding(.top, 16)

                        // Achievements
                        achievementsSection(profile: profile)
                            .padding(.top, 16)

                        Rectangle().fill(Color.theme.divider).frame(height: 0.5)
                            .padding(.top, 16)

                        // Posts
                        postsSection(profile: profile)
                            .padding(.top, 16)

                        Spacer(minLength: 100)
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
                        .foregroundStyle(Color.theme.secondaryText)
                    Text("Profile Not Found")
                        .font(.xScreenTitle)
                        .foregroundStyle(Color.theme.primaryText)
                    Text("Could not load user profile details. Please try again.")
                        .font(.xPostBody)
                        .foregroundStyle(Color.theme.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    Button("Retry") {
                        viewModel.loadProfile()
                    }
                    .font(.xButton)
                    .foregroundStyle(.black)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Capsule().fill(Color.theme.primaryText))
                }
            }
        }
        .navigationTitle(viewModel.profile?.username != nil ? "@\(viewModel.profile!.username)" : "Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                toolbarTrailing()
            }
        }
        .task {
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
        .errorAlert($viewModel.errorMessage)
    }

    // MARK: - 1. Profile Header View
    private func profileHeaderView(profile: UserProfile) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                AvatarView(
                    imageData: profile.avatarImageData,
                    name: profile.displayName,
                    colorHex: profile.avatarColorHex,
                    size: 80,
                    showBorder: false,
                    moodEmoji: profile.currentMoodEmoji
                )

                Spacer()

                if profile.moodStreak > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(.orange)
                        Text("\(profile.moodStreak)")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(.orange)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.theme.secondaryBackground)
                    .clipShape(Capsule())
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(profile.displayName)
                    .font(.xScreenTitle)
                    .foregroundStyle(Color.theme.primaryText)

                HStack(spacing: 6) {
                    Text("@\(profile.username)")
                        .font(.xHandle)
                        .foregroundStyle(Color.theme.secondaryText)

                    if profile.privacySetting != .publicVisibility {
                        Image(systemName: profile.privacySetting.iconName)
                            .font(.system(size: 12))
                            .foregroundStyle(Color.theme.secondaryText)
                    }
                }

                if let location = profile.location, !location.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.and.ellipse")
                            .font(.system(size: 12))
                            .foregroundStyle(Color.theme.secondaryText)
                        Text(location)
                            .font(.xTrendingMeta)
                            .foregroundStyle(Color.theme.secondaryText)
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
    }

    // MARK: - 2. Statistics Row (inline text, X-style)
    private func statsView(profile: UserProfile) -> some View {
        HStack(spacing: 16) {
            statsItem(count: profile.postsCount, label: "Posts")

            Button {
                router.push(.followList(type: .followers, userId: viewModel.targetUserId))
            } label: {
                statsItem(count: profile.followersCount, label: "Followers")
            }
            .buttonStyle(PlainButtonStyle())

            Button {
                router.push(.followList(type: .following, userId: viewModel.targetUserId))
            } label: {
                statsItem(count: profile.followingCount, label: "Following")
            }
            .buttonStyle(PlainButtonStyle())

            Spacer()
        }
    }

    private func statsItem(count: Int, label: String) -> some View {
        HStack(spacing: 4) {
            Text("\(count)")
                .font(.xDisplayName)
                .foregroundStyle(Color.theme.primaryText)
            Text(label)
                .font(.xHandle)
                .foregroundStyle(Color.theme.secondaryText)
        }
    }

    // MARK: - 3. Action Buttons Row
    private func actionsView(profile: UserProfile) -> some View {
        HStack(spacing: 12) {
            primaryAction()

            Button(action: {
                showShareAlert = true
            }) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.theme.primaryText)
                    .frame(width: 36, height: 36)
                    .overlay(
                        Circle().strokeBorder(Color.theme.divider, lineWidth: 1)
                    )
            }
            .buttonStyle(XPressableStyle())
        }
    }

    // MARK: - 4. Mood History Row
    private func moodHistoryView(profile: UserProfile) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Mood History")
                .font(.xSectionHeader)
                .foregroundStyle(Color.theme.primaryText)

            HStack(spacing: 8) {
                ForEach(profile.moodHistory.reversed().prefix(7)) { entry in
                    VStack(spacing: 8) {
                        Text(dayOfWeekAbbreviation(for: entry.date))
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(Color.theme.secondaryText)

                        ZStack {
                            Circle()
                                .fill(Color.theme.secondaryBackground)
                                .frame(width: 36, height: 36)

                            Text(entry.emoji)
                                .font(.system(size: 18))
                        }
                        .overlay(
                            Circle()
                                .stroke(Color.theme.accent, lineWidth: Calendar.current.isDateInToday(entry.date) ? 2 : 0)
                                .frame(width: 40, height: 40)
                        )
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 8)
            .background(Color.theme.secondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }

    // MARK: - 5. Analytics Section
    private func analyticsSection(profile: UserProfile) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Analytics & Insights")
                .font(.xSectionHeader)
                .foregroundStyle(Color.theme.primaryText)

            VStack(spacing: 16) {
                HStack(alignment: .bottom, spacing: 12) {
                    ForEach(profile.moodHistory.reversed().prefix(7)) { entry in
                        VStack(spacing: 8) {
                            Spacer()
                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .fill(Color.theme.accent)
                                .frame(height: CGFloat(moodValue(for: entry.emoji) * 22))
                                .frame(width: 20)

                            Text(dayOfWeekAbbreviation(for: entry.date))
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(Color.theme.secondaryText)
                        }
                    }
                }
                .frame(height: 140)
                .padding(.top, 10)

                Rectangle().fill(Color.theme.divider).frame(height: 0.5)

                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("MOST COMMON MOOD")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(Color.theme.secondaryText)

                        HStack(spacing: 6) {
                            Text(mostCommonMoodEmoji(profile.moodHistory))
                                .font(.system(size: 20))
                            Text(mostCommonMoodText(profile.moodHistory))
                                .font(.xDisplayName)
                                .foregroundStyle(Color.theme.primaryText)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("WEEKLY PROGRESS")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(Color.theme.secondaryText)

                        Text("7 / 7 check-ins")
                            .font(.xDisplayName)
                            .foregroundStyle(Color.theme.accent)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(16)
            .background(Color.theme.secondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }

    // MARK: - 6. Achievements Section
    private func achievementsSection(profile: UserProfile) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Achievements")
                .font(.xSectionHeader)
                .foregroundStyle(Color.theme.primaryText)
                .padding(.horizontal, 16)

            if profile.achievements.isEmpty {
                Text("No achievements unlocked yet.")
                    .font(.xTrendingMeta)
                    .foregroundStyle(Color.theme.secondaryText)
                    .padding(.horizontal, 16)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 14) {
                        ForEach(profile.achievements) { achievement in
                            achievementCard(achievement: achievement)
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
        }
    }

    private func achievementCard(achievement: Achievement) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.theme.accent.opacity(0.15))
                    .frame(width: 44, height: 44)

                Image(systemName: achievement.icon)
                    .font(.system(size: 18))
                    .foregroundStyle(Color.theme.accent)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(achievement.title)
                    .font(.xDisplayName)
                    .foregroundStyle(Color.theme.primaryText)

                Text(achievement.description)
                    .font(.xTrendingMeta)
                    .foregroundStyle(Color.theme.secondaryText)
                    .lineLimit(2)
                    .frame(width: 140, alignment: .leading)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color.theme.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.theme.divider, lineWidth: 1)
        )
    }

    // MARK: - 7. Posts Section
    private func postsSection(profile: UserProfile) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Posts")
                .font(.xSectionHeader)
                .foregroundStyle(Color.theme.primaryText)
                .padding(.horizontal, 16)

            if viewModel.posts.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "doc.text.image.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(Color.theme.secondaryText)
                    Text("No posts yet")
                        .font(.xDisplayName)
                        .foregroundStyle(Color.theme.secondaryText)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                let columns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 3)

                LazyVGrid(columns: columns, spacing: 2) {
                    ForEach(viewModel.posts) { post in
                        Button {
                            router.push(.postDetail(postId: post.id))
                        } label: {
                            postGridCell(post: post)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .onAppear {
                            if post.id == viewModel.posts.last?.id {
                                viewModel.loadMorePosts()
                            }
                        }
                    }
                }

                if viewModel.isLazyLoadingPosts {
                    HStack {
                        Spacer()
                        ProgressView()
                            .tint(Color.theme.accent)
                            .padding(.vertical, 12)
                        Spacer()
                    }
                }
            }
        }
    }

    private func postGridCell(post: PostModel) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 2)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: post.gradientStartHex ?? "38B2AC"),
                            Color(hex: post.gradientEndHex ?? "805AD5")
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .aspectRatio(1, contentMode: .fit)

            VStack {
                Image(systemName: "quote.opening")
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.5))

                Text(post.quoteText ?? "")
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
    private func dayOfWeekAbbreviation(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
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
