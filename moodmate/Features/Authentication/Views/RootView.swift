//
//  RootView.swift
//  moodmate
//
//  Created by Nurtore on 22.07.2026.
//

import SwiftUI

struct RootView: View {
    @StateObject private var sessionManager = AppSessionManager.shared
    @StateObject private var themeManager = ThemeManager.shared
    
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
}
