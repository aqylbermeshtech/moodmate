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
    @Published var insightsPath: [Route] = []
    @Published var profilePath: [Route] = []

    @Published var presentedFullScreenCover: FullScreenRoute?
    @Published var presentedSheet: SheetRoute?

    private var pendingURL: URL?

    private init() {}

    // MARK: - Push navigation

    func push(_ route: Route, in tab: HomeTab? = nil) {
        switch tab ?? selectedTab {
        case .home: homePath.append(route)
        case .discover: discoverPath.append(route)
        case .insights: insightsPath.append(route)
        case .profile: profilePath.append(route)
        case .add: break
        }
    }

    func pop(in tab: HomeTab? = nil) {
        switch tab ?? selectedTab {
        case .home: if !homePath.isEmpty { homePath.removeLast() }
        case .discover: if !discoverPath.isEmpty { discoverPath.removeLast() }
        case .insights: if !insightsPath.isEmpty { insightsPath.removeLast() }
        case .profile: if !profilePath.isEmpty { profilePath.removeLast() }
        case .add: break
        }
    }

    func popToRoot(in tab: HomeTab? = nil) {
        switch tab ?? selectedTab {
        case .home: homePath.removeAll()
        case .discover: discoverPath.removeAll()
        case .insights: insightsPath.removeAll()
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

    func present(_ sheet: SheetRoute) {
        presentedSheet = sheet
    }

    func dismissSheet() {
        presentedSheet = nil
    }

    // MARK: - Tab-bar chrome

    var currentPath: [Route] {
        switch selectedTab {
        case .home: return homePath
        case .discover: return discoverPath
        case .insights: return insightsPath
        case .profile: return profilePath
        case .add: return []
        }
    }

    /// Drives whether `RootTabContainerView` hides the custom bottom bar —
    /// replaces the old `NavigationVisibilityCoordinator` environment object.
    var isShowingPostDetail: Bool {
        if case .postDetail = currentPath.last { return true }
        return false
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
