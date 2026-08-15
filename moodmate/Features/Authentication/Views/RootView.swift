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

    var body: some View {
        Group {
            if sessionManager.isResolvingSession {
                splashView
            } else if sessionManager.isAuthenticated {
                RootTabContainerView()
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            } else {
                MoodMateAuthView()
                    .transition(.opacity)
            }
        }
        .animation(.easeOut(duration: 0.2), value: sessionManager.isAuthenticated)
        .animation(.easeOut(duration: 0.25), value: sessionManager.isResolvingSession)
        .preferredColorScheme(themeManager.selectedAppearance.colorScheme)
        .onChange(of: sessionManager.isAuthenticated) { _, isAuthenticated in
            if isAuthenticated {
                router.flushPendingURL()
            }
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
