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
        GeometryReader { geo in
            let bottomInset = geo.safeAreaInsets.bottom

            ZStack(alignment: .bottom) {
                tabContent

                if !router.hidesBottomBar {
                    // FAB
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            XPostFAB {
                                router.present(.createPost)
                            }
                            .padding(.trailing, 16)
                        }
                        .padding(.bottom, router.showTabBar ? 48 + bottomInset + 16 : 16 + bottomInset)
                        .animation(.easeInOut(duration: 0.3), value: router.showTabBar)
                    }

                    // Tab bar
                    BottomNavigationBar(selectedTab: $router.selectedTab) {
                        router.present(.createPost)
                    }
                    .transition(.move(edge: .bottom))
                    .offset(y: router.showTabBar ? 0 : 48 + bottomInset + 10)
                    .animation(.easeInOut(duration: 0.3), value: router.showTabBar)
                }
            }
        }
        .onChange(of: router.selectedTab) { _, _ in
            router.resetScrollState()
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
