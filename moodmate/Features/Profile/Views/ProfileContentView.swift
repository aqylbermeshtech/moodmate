//
//  ProfileContentView.swift
//  moodmate
//
//  Created by Nurtore on 23.07.2026.
//

import SwiftUI

/// Shared by `MyProfileView` and `OtherProfileView`; the primary action
/// button and trailing toolbar item are injected by the caller.
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

                        statsView(profile: profile)
                            .padding(.horizontal, 16)
                            .padding(.top, 12)

                        if !profile.bio.isEmpty {
                            Text(profile.bio)
                                .font(.xPostBody)
                                .foregroundStyle(Color.theme.primaryText)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 16)
                                .padding(.top, 12)
                        }

                        interestsView(profile: profile)

                        actionsView(profile: profile)
                            .padding(.horizontal, 16)
                            .padding(.top, 16)

                        Rectangle().fill(Color.theme.divider).frame(height: 0.5)
                            .padding(.top, 16)

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
                Text("Profile link copied! Share @\(profile.username)'s profile with friends.")
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
                    showBorder: false
                )

                Spacer()
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
            statsItem(count: viewModel.posts.count, label: "Posts")

            Button {
                router.push(.followList(type: .followers, userId: viewModel.targetUserId))
            } label: {
                statsItem(count: viewModel.followers.count, label: "Followers")
            }
            .buttonStyle(PlainButtonStyle())

            Button {
                router.push(.followList(type: .following, userId: viewModel.targetUserId))
            } label: {
                statsItem(count: viewModel.following.count, label: "Following")
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

    // MARK: - 3. Interests

    @ViewBuilder
    private func interestsView(profile: UserProfile) -> some View {
        let interests = InterestCatalog.interests(ids: profile.interests)

        if !interests.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                Text("Interests")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.theme.secondaryText)

                FlowLayout(spacing: 8, lineSpacing: 8) {
                    ForEach(interests) { interest in
                        InterestChip(interest: interest)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.top, 16)
        }
    }

    // MARK: - 4. Action Buttons Row
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

    // MARK: - 5. Posts Section
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
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func postGridCell(post: PostModel) -> some View {
        Color.clear
            .aspectRatio(1, contentMode: .fit)
            .overlay {
                if let image = firstImage(in: post) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    gradientTextCell(post: post)
                }
            }
            .clipped()
            .contentShape(Rectangle())
    }

    private func gradientTextCell(post: PostModel) -> some View {
        let quote = post.quoteText ?? ""
        let caption = post.text ?? ""
        let body = !quote.isEmpty ? quote : caption

        return ZStack {
            LinearGradient(
                colors: [
                    Color(hex: post.gradientStartHex ?? "38B2AC"),
                    Color(hex: post.gradientEndHex ?? "805AD5")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            if !body.isEmpty {
                VStack(spacing: 2) {
                    if !quote.isEmpty {
                        Image(systemName: "quote.opening")
                            .font(.system(size: 12))
                            .foregroundStyle(.white.opacity(0.5))
                    }

                    Text(body)
                        .font(.system(size: 9, weight: .bold, design: quote.isEmpty ? .rounded : .serif))
                        .foregroundStyle(.white)
                        .lineLimit(4)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 6)

                    if !quote.isEmpty {
                        Image(systemName: "quote.closing")
                            .font(.system(size: 12))
                            .foregroundStyle(.white.opacity(0.5))
                    }
                }
                .padding(4)
            }
        }
    }

    private func firstImage(in post: PostModel) -> UIImage? {
        for raw in post.images {
            let base64 = raw.contains(",") ? String(raw.split(separator: ",").last ?? "") : raw
            if let data = Data(base64Encoded: base64), let image = UIImage(data: data) {
                return image
            }
        }
        return nil
    }

}
