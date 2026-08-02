//
//  RootTabContainerView.swift
//  moodmate
//
//  Created by Nurtore on 03.08.2026.
//
//  Single responsibility: owns all app-level tab navigation state.
//  HomeView and every other tab view are purely feature-scoped —
//  they know nothing about tabs, the nav bar, or the create-post sheet.
//

import SwiftUI

struct RootTabContainerView: View {

    // MARK: - Tab & Sheet State (owned here, nowhere else)

    @State private var selectedTab: HomeTab = .home
    @State private var showCreatePostSheet = false

    // Shared HomeViewModel so HomeView and the container can both
    // react to newly-created posts without prop-drilling through callbacks.
    @StateObject private var homeViewModel = HomeViewModel()

    // MARK: - Body

    var body: some View {
        ZStack(alignment: .bottom) {
            tabContent
                // Inset every tab's scroll content above the floating nav bar.
                .safeAreaInset(edge: .bottom) {
                    // Transparent spacer matching the nav bar height so
                    // ScrollViews know how tall the overlay is.
                    Color.clear.frame(height: 90)
                }

            // Floating custom nav bar — lives above all tab content.
            BottomNavigationBar(selectedTab: $selectedTab) {
                showCreatePostSheet = true
            }
            .padding(.bottom, 8)
        }
        // System tab bar is hidden; we drive everything from BottomNavigationBar.
        .toolbar(.hidden, for: .tabBar)
        // Create-post sheet is owned here so any tab can trigger it.
        .fullScreenCover(isPresented: $showCreatePostSheet) {
            CreatePostView { newPost in
                homeViewModel.addNewlyCreatedPost(newPost)
            }
        }
        .ignoresSafeArea(.keyboard)
    }

    // MARK: - Tab Content

    /// Each tab gets its own NavigationStack so nav stacks are fully isolated
    /// and their state is preserved when switching tabs.
    @ViewBuilder
    private var tabContent: some View {
        TabView(selection: $selectedTab) {

            // ── Home ──────────────────────────────────────────────────────────
            NavigationStack {
                HomeView(
                    viewModel: homeViewModel,
                    onCreatePost: { showCreatePostSheet = true },
                    onNavigateToProfile: { selectedTab = .profile }
                )
            }
            .tag(HomeTab.home)

            // ── Discover ──────────────────────────────────────────────────────
            NavigationStack {
                DiscoverView()
            }
            .tag(HomeTab.discover)

            // ── Add (centre button — TabView entry is never actually selected) ─
            // The real action is handled by BottomNavigationBar's onAddTap.
            // This empty tab exists only to satisfy TabView's tag expectations.
            Color.clear
                .tag(HomeTab.add)

            // ── Insights ──────────────────────────────────────────────────────
            NavigationStack {
                InsightsView(onAddPostTap: { showCreatePostSheet = true })
            }
            .tag(HomeTab.insights)

            // ── Profile ───────────────────────────────────────────────────────
            NavigationStack {
                ProfileView(userId: nil)
            }
            .tag(HomeTab.profile)
        }
        // Disable TabView's built-in swipe-to-switch so only the custom
        // nav bar controls tab selection.
        .tabViewStyle(.page(indexDisplayMode: .never))
    }
}

// MARK: - Preview

#Preview {
    RootTabContainerView()
}
