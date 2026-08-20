//
//  AppRouter.swift
//  moodmate
//

import SwiftUI
import Combine

/// Single source of truth for navigation: tab selection, one push-stack per
/// tab, and the app's two screen-shaped modals. Every screen dispatches
/// intents here (`push`, `switchTab`, `present`) instead of constructing
/// `NavigationLink`s or owning its own presentation `@State` — which is also
/// what lets `handle(url:)` drive the exact same navigation a tap would.
@MainActor
final class AppRouter: ObservableObject {
    static let shared = AppRouter()

    @Published var selectedTab: HomeTab = .home

    @Published var homePath: [Route] = []
    @Published var discoverPath: [Route] = []
    @Published var chatPath: [Route] = []
    @Published var profilePath: [Route] = []

    @Published var presentedFullScreenCover: FullScreenRoute?

    /// Controls tab bar visibility — driven by scroll direction in child views.
    @Published var showTabBar: Bool = true
    private var lastScrollOffset: CGFloat = 0
    private var scrollAccumulator: CGFloat = 0
    private let scrollThreshold: CGFloat = 15

    private var pendingURL: URL?

    private init() {}

    // MARK: - Scroll-aware tab bar

    /// Call from any scrollable view's onScroll to drive hide/show behaviour.
    /// `offset` is the *content* offset (positive = scrolled down from top).
    func updateTabBarVisibility(scrollOffset offset: CGFloat) {
        let delta = offset - lastScrollOffset
        lastScrollOffset = offset

        // Don't hide near the top of content
        guard offset > 60 else {
            if !showTabBar {
                withAnimation(.easeOut(duration: 0.25)) { showTabBar = true }
            }
            scrollAccumulator = 0
            return
        }

        scrollAccumulator += delta

        if scrollAccumulator > scrollThreshold && showTabBar {
            // Scrolling down → hide
            withAnimation(.easeOut(duration: 0.25)) { showTabBar = false }
            scrollAccumulator = 0
        } else if scrollAccumulator < -scrollThreshold && !showTabBar {
            // Scrolling up → show
            withAnimation(.easeOut(duration: 0.25)) { showTabBar = true }
            scrollAccumulator = 0
        }

        // Clamp accumulator to avoid massive build-up
        scrollAccumulator = max(-scrollThreshold * 3, min(scrollThreshold * 3, scrollAccumulator))
    }

    /// Reset scroll state — call when switching tabs so the bar always starts visible.
    func resetScrollState() {
        lastScrollOffset = 0
        scrollAccumulator = 0
        if !showTabBar {
            withAnimation(.easeOut(duration: 0.25)) { showTabBar = true }
        }
    }

    // MARK: - Push navigation

    func push(_ route: Route, in tab: HomeTab? = nil) {
        switch tab ?? selectedTab {
        case .home: homePath.append(route)
        case .discover: discoverPath.append(route)
        case .chat: chatPath.append(route)
        case .profile: profilePath.append(route)
        case .add: break
        }
    }

    func pop(in tab: HomeTab? = nil) {
        switch tab ?? selectedTab {
        case .home: if !homePath.isEmpty { homePath.removeLast() }
        case .discover: if !discoverPath.isEmpty { discoverPath.removeLast() }
        case .chat: if !chatPath.isEmpty { chatPath.removeLast() }
        case .profile: if !profilePath.isEmpty { profilePath.removeLast() }
        case .add: break
        }
    }

    func popToRoot(in tab: HomeTab? = nil) {
        switch tab ?? selectedTab {
        case .home: homePath.removeAll()
        case .discover: discoverPath.removeAll()
        case .chat: chatPath.removeAll()
        case .profile: profilePath.removeAll()
        case .add: break
        }
    }

    func switchTab(_ tab: HomeTab) {
        selectedTab = tab
    }

    // MARK: - Modal presentation

    func present(_ cover: FullScreenRoute) {
        presentedFullScreenCover = cover
    }

    func dismissFullScreenCover() {
        presentedFullScreenCover = nil
    }

    // MARK: - Tab-bar chrome

    var currentPath: [Route] {
        switch selectedTab {
        case .home: return homePath
        case .discover: return discoverPath
        case .chat: return chatPath
        case .profile: return profilePath
        case .add: return []
        }
    }

    /// Drives whether `RootTabContainerView` hides the custom bottom bar —
    /// replaces the old `NavigationVisibilityCoordinator` environment object.
    /// True for screens that want the full height for their own bottom
    /// chrome (a post's comment bar, a chat thread's message bar).
    var hidesBottomBar: Bool {
        switch currentPath.last {
        case .postDetail, .chatThread: return true
        default: return false
        }
    }

    // MARK: - Deep links

    func handle(url: URL) {
        guard AppSessionManager.shared.isAuthenticated else {
            pendingURL = url
            return
        }
        route(url: url)
    }

    func flushPendingURL() {
        guard let url = pendingURL else { return }
        pendingURL = nil
        route(url: url)
    }

    private func route(url: URL) {
        guard url.scheme == "moodmate", let host = url.host else { return }
        let id = url.pathComponents.first(where: { $0 != "/" })

        switch host {
        case "profile":
            guard let userId = id else { return }
            switchTab(.profile)
            profilePath = userId == AppSessionManager.currentUserId() ? [] : [.otherProfile(userId: userId)]
        case "post":
            guard let postId = id else { return }
            switchTab(.home)
            homePath = [.postDetail(postId: postId)]
        case "settings":
            switchTab(.profile)
            profilePath = [.settings]
        case "compose":
            present(.createPost)
        default:
            break
        }
    }
}
