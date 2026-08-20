//
//  RootTabContainerView.swift
//  moodmate
//
//  Created by Nurtore on 03.08.2026.
//

import SwiftUI

struct RootTabContainerView: View {
    @EnvironmentObject private var router: AppRouter

    @StateObject private var homeViewModel = HomeViewModel()

    // MARK: - Body
    var body: some View {
        ZStack(alignment: .bottom) {
            tabContent

            if !router.hidesBottomBar {
                // X-style tab bar (anchored at bottom)
                BottomNavigationBar(selectedTab: $router.selectedTab) {
                    router.present(.createPost)
                }

                // Floating compose button (X FAB)
                HStack {
                    Spacer()
                    XPostFAB {
                        router.present(.createPost)
                    }
                    .padding(.trailing, 16)
                    .padding(.bottom, 72) // Above tab bar
                }
            }
        }
        .fullScreenCover(item: $router.presentedFullScreenCover) { cover in
            switch cover {
            case .createPost:
                CreatePostView { newPost in
                    homeViewModel.addNewlyCreatedPost(newPost)
                }
            }
        }
        .ignoresSafeArea(.keyboard)
    }

    // MARK: - Tab Content
    @ViewBuilder
    private var tabContent: some View {
        TabView(selection: $router.selectedTab) {
            NavigationStack(path: $router.homePath) {
                HomeView(viewModel: homeViewModel)
                    .toolbar(.hidden, for: .tabBar)
                    .navigationDestination(for: Route.self) { RouteDestinationView(route: $0) }
            }
            .tag(HomeTab.home)
            NavigationStack(path: $router.discoverPath) {
                DiscoverView()
                    .toolbar(.hidden, for: .tabBar)
                    .navigationDestination(for: Route.self) { RouteDestinationView(route: $0) }
            }
            .tag(HomeTab.discover)
            Color.clear
                .toolbar(.hidden, for: .tabBar)
                .tag(HomeTab.add)
            NavigationStack(path: $router.chatPath) {
                ChatListView()
                    .toolbar(.hidden, for: .tabBar)
                    .navigationDestination(for: Route.self) { RouteDestinationView(route: $0) }
            }
            .tag(HomeTab.chat)
            NavigationStack(path: $router.profilePath) {
                MyProfileView()
                    .toolbar(.hidden, for: .tabBar)
                    .navigationDestination(for: Route.self) { RouteDestinationView(route: $0) }
            }
            .tag(HomeTab.profile)
        }
        .tabViewStyle(.automatic)
    }
}

// MARK: - Preview

#Preview {
    RootTabContainerView()
        .environmentObject(AppRouter.shared)
}
