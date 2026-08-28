//
//  DiscoverView.swift
//  moodmate
//
//  Created by Nurtore on 26.07.2026.
//

import SwiftUI

struct DiscoverView: View {
    @StateObject private var viewModel = DiscoverViewModel()
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        Group {
            ZStack {
                Color.theme.primaryBackground
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    VStack(spacing: 0) {
                        DiscoverSearchBar(
                            searchText: $viewModel.searchText,
                            isSearchActive: $viewModel.isSearchActive,
                            recentSearches: viewModel.recentSearches,
                            onRecentSearchTap: { query in
                                viewModel.searchText = query
                                viewModel.addRecentSearch(query)
                            },
                            onClearHistory: {
                                viewModel.clearRecentSearches()
                            },
                            onSubmit: { query in
                                viewModel.addRecentSearch(query)
                            }
                        )
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)

                        Rectangle().fill(Color.theme.divider).frame(height: 0.5)

                        if viewModel.hasActiveFilter {
                            HStack {
                                HStack(spacing: 6) {
                                    Text("Filtered:")
                                        .font(.xTrendingMeta)
                                        .foregroundStyle(Color.theme.secondaryText)

                                    Text(viewModel.activeFilterLabel)
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundStyle(Color.theme.accent)

                                    Button {
                                        viewModel.clearFilters()
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.system(size: 14))
                                            .foregroundStyle(Color.theme.secondaryText)
                                    }
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.theme.accent.opacity(0.1))
                                .clipShape(Capsule())

                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .transition(.move(edge: .top).combined(with: .opacity))
                        }
                    }
                    .background(Color.theme.primaryBackground)

                    ZStack {
                        if viewModel.isSearchActive && !viewModel.searchText.isEmpty {
                            SearchResultsView(
                                results: viewModel.filteredSearchResults,
                                scope: $viewModel.searchScope,
                                searchText: viewModel.searchText,
                                onSelectResult: { result in
                                    if result.type == .user {
                                        viewModel.addRecentSearch(result.userName ?? viewModel.searchText)
                                        if let userId = result.userId {
                                            router.push(.otherProfile(userId: userId))
                                        }
                                    }
                                },
                                onFollowUser: { userId in
                                    if let user = viewModel.suggestedUsers.first(where: { $0.id == userId }) {
                                        viewModel.toggleFollow(user: user)
                                    }
                                },
                                onLikePost: { postId in
                                    if let post = viewModel.discoverPosts.first(where: { $0.id == postId }) {
                                        viewModel.toggleLike(post: post)
                                    }
                                }
                            )
                            .transition(.opacity)
                        } else if viewModel.isLoading {
                            ScrollView {
                                DiscoverLoadingSkeleton()
                                    .padding(.top, 16)
                            }
                        } else if let error = viewModel.errorMessage, viewModel.discoverPosts.isEmpty {
                            DiscoverErrorView(
                                message: error,
                                isPartialContent: false,
                                onRetry: {
                                    Task { await viewModel.loadInitialData() }
                                }
                            )
                        } else {
                            ScrollView {
                                LazyVStack(spacing: 0) {
                                    if let error = viewModel.errorMessage {
                                        DiscoverErrorView(
                                            message: error,
                                            isPartialContent: true,
                                            onRetry: {
                                                Task { await viewModel.refresh() }
                                            }
                                        )
                                    }

                                    if !viewModel.categories.isEmpty {
                                        VStack(alignment: .leading, spacing: 10) {
                                            Text("Topics")
                                                .font(.xScreenTitle)
                                                .foregroundStyle(Color.theme.primaryText)
                                                .padding(.horizontal, 16)

                                            ScrollView(.horizontal, showsIndicators: false) {
                                                HStack(spacing: 12) {
                                                    ForEach(viewModel.categories) { category in
                                                        CategoryCard(
                                                            category: category,
                                                            isSelected: viewModel.selectedCategory == category,
                                                            onTap: {
                                                                viewModel.selectCategory(category)
                                                            }
                                                        )
                                                    }
                                                }
                                                .padding(.horizontal, 16)
                                            }
                                        }
                                        .padding(.vertical, 12)

                                        Rectangle().fill(Color.theme.divider).frame(height: 0.5)
                                    }

                                    if !viewModel.suggestedUsers.isEmpty {
                                        VStack(alignment: .leading, spacing: 10) {
                                            Text("Who to follow")
                                                .font(.xSectionHeader)
                                                .foregroundStyle(Color.theme.primaryText)
                                                .padding(.horizontal, 16)

                                            ScrollView(.horizontal, showsIndicators: false) {
                                                HStack(spacing: 12) {
                                                    ForEach(viewModel.suggestedUsers) { user in
                                                        SuggestedUserCard(
                                                            user: user,
                                                            onFollow: {
                                                                viewModel.toggleFollow(user: user)
                                                            }
                                                        )
                                                    }
                                                }
                                                .padding(.horizontal, 16)
                                            }
                                        }
                                        .padding(.vertical, 12)

                                        Rectangle().fill(Color.theme.divider).frame(height: 0.5)
                                    }

                                    if !viewModel.trendingHashtags.isEmpty {
                                        VStack(alignment: .leading, spacing: 10) {
                                            Text("Popular Hashtags")
                                                .font(.xSectionHeader)
                                                .foregroundStyle(Color.theme.primaryText)
                                                .padding(.horizontal, 16)

                                            ScrollView(.horizontal, showsIndicators: false) {
                                                HStack(spacing: 8) {
                                                    ForEach(viewModel.trendingHashtags) { hashtag in
                                                        HashtagChip(
                                                            hashtag: hashtag,
                                                            isSelected: viewModel.selectedHashtag == hashtag,
                                                            onTap: {
                                                                viewModel.selectHashtag(hashtag)
                                                            }
                                                        )
                                                    }
                                                }
                                                .padding(.horizontal, 16)
                                            }
                                        }
                                        .padding(.vertical, 12)

                                        Rectangle().fill(Color.theme.divider).frame(height: 0.5)
                                    }

                                    if viewModel.discoverPosts.isEmpty {
                                        EmptyDiscoverView(
                                            hasActiveFilter: viewModel.hasActiveFilter,
                                            onClearFilters: { viewModel.clearFilters() },
                                            onExplore: { viewModel.clearFilters() }
                                        )
                                    } else {
                                        MasonryGrid(
                                            posts: viewModel.discoverPosts,
                                            onLike: { post in
                                                viewModel.toggleLike(post: post)
                                            },
                                            onSelectPost: { post in
                                                router.push(.postDetail(postId: post.id))
                                            }
                                        )
                                        .padding(.horizontal, 16)
                                        .padding(.top, 16)

                                        if viewModel.hasMorePages {
                                            ProgressView()
                                                .tint(Color.theme.accent)
                                                .padding(.vertical, 20)
                                                .onAppear {
                                                    Task {
                                                        await viewModel.loadMorePosts()
                                                    }
                                                }
                                        }
                                    }
                                }
                                .padding(.bottom, 100)
                            }
                            .refreshable {
                                await viewModel.refresh()
                            }
                        }
                    }
                }
            }
            .task {
                if viewModel.discoverPosts.isEmpty {
                    await viewModel.loadInitialData()
                }
            }
        }
    }
}

// MARK: - Two-Column Masonry Grid
private struct MasonryGrid: View {
    let posts: [DiscoverPost]
    var onLike: (DiscoverPost) -> Void
    var onSelectPost: (DiscoverPost) -> Void

    private var leftColumnPosts: [DiscoverPost] {
        var left: [DiscoverPost] = []
        var right: [DiscoverPost] = []
        var leftHeight: CGFloat = 0
        var rightHeight: CGFloat = 0

        for post in posts {
            let h = post.heightClass.heightValue
            if leftHeight <= rightHeight {
                left.append(post)
                leftHeight += h
            } else {
                right.append(post)
                rightHeight += h
            }
        }
        return left
    }

    private var rightColumnPosts: [DiscoverPost] {
        var left: [DiscoverPost] = []
        var right: [DiscoverPost] = []
        var leftHeight: CGFloat = 0
        var rightHeight: CGFloat = 0

        for post in posts {
            let h = post.heightClass.heightValue
            if leftHeight <= rightHeight {
                left.append(post)
                leftHeight += h
            } else {
                right.append(post)
                rightHeight += h
            }
        }
        return right
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            LazyVStack(spacing: 12) {
                ForEach(leftColumnPosts) { post in
                    DiscoverCard(
                        post: post,
                        onLike: { onLike(post) }
                    )
                    .onTapGesture {
                        onSelectPost(post)
                    }
                }
            }

            LazyVStack(spacing: 12) {
                ForEach(rightColumnPosts) { post in
                    DiscoverCard(
                        post: post,
                        onLike: { onLike(post) }
                    )
                    .onTapGesture {
                        onSelectPost(post)
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        DiscoverView()
    }
    .environmentObject(AppRouter.shared)
}
