//
//  RootView.swift
//  moodmate
//
//  Created by Nurtore on 22.07.2026.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var sessionManager: AppSessionManager
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var router: AppRouter

    @StateObject private var onboardingGate = OnboardingGateViewModel()

    var body: some View {
        Group {
            if sessionManager.isResolvingSession {
                splashView
            } else if sessionManager.isAuthenticated {
                authenticatedContent
            } else {
                MoodMateAuthView()
                    .transition(.opacity)
            }
        }
        .animation(.easeOut(duration: 0.2), value: sessionManager.isAuthenticated)
        .animation(.easeOut(duration: 0.25), value: sessionManager.isResolvingSession)
        .animation(.easeOut(duration: 0.25), value: onboardingGate.status)
        .preferredColorScheme(themeManager.selectedAppearance.colorScheme)
        .task {
            onboardingGate.refresh(isAuthenticated: sessionManager.isAuthenticated)
        }
        .onChange(of: sessionManager.isAuthenticated) { _, isAuthenticated in
            onboardingGate.refresh(isAuthenticated: isAuthenticated)
            if isAuthenticated {
                router.flushPendingURL()
            }
        }
    }

    /// Interests come first: the rest of the app is shaped by them, so a user
    /// who hasn't picked any never reaches the tab container.
    @ViewBuilder
    private var authenticatedContent: some View {
        switch onboardingGate.status {
        case .undetermined:
            splashView
        case .needsInterests:
            InterestsOnboardingView()
                .transition(.opacity)
        case .ready:
            RootTabContainerView()
                .transition(.opacity.combined(with: .move(edge: .bottom)))
        }
    }
    
    private var splashView: some View {
        ZStack {
            Color.theme.primaryBackground
                .ignoresSafeArea()
            VStack(spacing: AppSpacing.md) {
                Image(systemName: "leaf.circle.fill")
                    .font(.system(size: 48, weight: .regular))
                    .foregroundStyle(Color.theme.accent)
                Text("MoodMate")
                    .font(.title.weight(.medium))
                    .foregroundStyle(Color.theme.primaryText)
            }
        }
    }
}

#Preview {
    RootView()
        .environmentObject(AppSessionManager.shared)
        .environmentObject(ThemeManager.shared)
        .environmentObject(AppRouter.shared)
}
