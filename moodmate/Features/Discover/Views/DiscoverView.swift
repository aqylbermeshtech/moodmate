//
//  DiscoverView.swift
//  moodmate
//
//  Created by Nurtore on 26.07.2026.
//

import SwiftUI

struct DiscoverView: View {
    @StateObject private var viewModel = DiscoverViewModel()
    @State private var selectedPostForDetail: DiscoverPost? = nil
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.theme.backgroundGradient
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    VStack(spacing: 12) {
                        HStack {
                            Text("Discover")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color.teal, Color.purple],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                            
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                        
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
                        .padding(.horizontal, 20)

                        if viewModel.hasActiveFilter {
                            HStack {
                                HStack(spacing: 6) {
                                    Text("Filtered by:")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundStyle(.secondary)
                                    
                                    Text(viewModel.activeFilterLabel)
                                        .font(.system(size: 12, weight: .bold, design: .rounded))
                                        .foregroundStyle(.teal)
                                    
                                    Button {
                                        viewModel.clearFilters()
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.system(size: 13))
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.teal.opacity(0.12))
                                .clipShape(Capsule())
                                
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            .transition(.move(edge: .top).combined(with: .opacity))
                        }
                    }
                    .padding(.bottom, 10)
                    .background(.ultraThinMaterial)
                    
                    ZStack {
                        if viewModel.isSearchActive && !viewModel.searchText.isEmpty {
                            SearchResultsView(
                                results: viewModel.filteredSearchResults,
                                scope: $viewModel.searchScope,
                                searchText: viewModel.searchText,
                                onSelectResult: { result in
                                    if result.type == .user {
                                        viewModel.addRecentSearch(result.userName ?? viewModel.searchText)
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
                                LazyVStack(spacing: 24) {
                                    if let error = viewModel.errorMessage {
                                        DiscoverErrorView(
                                            message: error,
                                            isPartialContent: true,
                                            onRetry: {
                                                Task { await viewModel.refresh() }
                                            }
                                        )
                                    }
                                    if !viewModel.trendingMoods.isEmpty {
                                        VStack(alignment: .leading, spacing: 10) {
                                            SectionHeader(title: "Trending Moods", subtitle: "What the world is feeling")
                                            
                                            ScrollView(.horizontal, showsIndicators: false) {
                                                HStack(spacing: 10) {
                                                    ForEach(viewModel.trendingMoods) { mood in
                                                        TrendingMoodChip(
                                                            mood: mood,
                                                            isSelected: viewModel.selectedMood == mood,
                                                            onTap: {
                                                                viewModel.selectMood(mood)
                                                            }
                                                        )
                                                    }
                                                }
                                                .padding(.horizontal, 20)
                                            }
                                        }
                                    }

                                    if !viewModel.categories.isEmpty {
                                        VStack(alignment: .leading, spacing: 10) {
                                            SectionHeader(title: "Categories", subtitle: "Explore by topic")
                                            
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
                                                .padding(.horizontal, 20)
                                            }
                                        }
                                    }
                                    if !viewModel.suggestedUsers.isEmpty {
                                        VStack(alignment: .leading, spacing: 10) {
                                            SectionHeader(title: "People to Follow", subtitle: "Connect with like minds")
                                            
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
                                                .padding(.horizontal, 20)
                                            }
                                        }
                                    }
                                    if !viewModel.trendingHashtags.isEmpty {
                                        VStack(alignment: .leading, spacing: 10) {
                                            SectionHeader(title: "Popular Hashtags", subtitle: "Trending topics")
                                            
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
                                                .padding(.horizontal, 20)
                                            }
                                        }
                                    }

                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack {
                                            Text(viewModel.hasActiveFilter ? "Filtered Feed" : "Community Discover Feed")
                                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                                .foregroundStyle(.primary)
                                            
                                            Spacer()
                                            
                                            if viewModel.hasActiveFilter {
                                                Button("Clear Filter") {
                                                    viewModel.clearFilters()
                                                }
                                                .font(.system(size: 12, weight: .medium))
                                                .foregroundStyle(.teal)
                                            }
                                        }
                                        .padding(.horizontal, 20)
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
                                                selectedPostForDetail = post
                                            }
                                        )
                                        .padding(.horizontal, 20)

                                        if viewModel.hasMorePages {
                                            ProgressView()
                                                .padding(.vertical, 20)
                                                .onAppear {
                                                    Task {
                                                        await viewModel.loadMorePosts()
                                                    }
                                                }
                                        }
                                    }
                                }
                                .padding(.top, 12)
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

// MARK: - Section Header Component
private struct SectionHeader: View {
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(Color.theme.primaryText)
            
            Text(subtitle)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color.theme.secondaryText)
        }
        .padding(.horizontal, 20)
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
    DiscoverView()
}
