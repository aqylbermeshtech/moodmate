//
//  RootTabContainerView.swift
//  moodmate
//
//  Created by Nurtore on 03.08.2026.
//

import SwiftUI

struct RootTabContainerView: View {
    // MARK: - Tab & Sheet State (owned here, nowhere else)
    @State private var selectedTab: HomeTab = .home
    @State private var showCreatePostSheet = false

    @StateObject private var homeViewModel = HomeViewModel()

    // MARK: - Body
    var body: some View {
        ZStack(alignment: .bottom) {
            tabContent
                .safeAreaInset(edge: .bottom) {
                    Color.clear.frame(height: 90)
                }
            BottomNavigationBar(selectedTab: $selectedTab) {
                showCreatePostSheet = true
            }
            .padding(.bottom, 8)
        }
        .fullScreenCover(isPresented: $showCreatePostSheet) {
            CreatePostView { newPost in
                homeViewModel.addNewlyCreatedPost(newPost)
            }
        }
        .ignoresSafeArea(.keyboard)
    }

    // MARK: - Tab Content
    @ViewBuilder
    private var tabContent: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                HomeView(
                    viewModel: homeViewModel,
                    onCreatePost: { showCreatePostSheet = true },
                    onNavigateToProfile: { selectedTab = .profile }
                )
                .toolbar(.hidden, for: .tabBar)
            }
            .tag(HomeTab.home)
            NavigationStack {
                DiscoverView()
                    .toolbar(.hidden, for: .tabBar)
            }
            .tag(HomeTab.discover)
            Color.clear
                .toolbar(.hidden, for: .tabBar)
                .tag(HomeTab.add)
            NavigationStack {
                InsightsView(onAddPostTap: { showCreatePostSheet = true })
                    .toolbar(.hidden, for: .tabBar)
            }
            .tag(HomeTab.insights)
            NavigationStack {
                ProfileView(userId: nil)
                    .toolbar(.hidden, for: .tabBar)
            }
            .tag(HomeTab.profile)
        }
        .tabViewStyle(.automatic)
    }
}

// MARK: - Preview

#Preview {
    RootTabContainerView()
}
