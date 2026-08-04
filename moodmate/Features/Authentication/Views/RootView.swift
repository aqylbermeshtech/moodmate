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
        .animation(.spring(response: 0.45, dampingFraction: 0.8), value: sessionManager.isAuthenticated)
        .animation(.easeOut(duration: 0.25), value: sessionManager.isResolvingSession)
        .preferredColorScheme(themeManager.selectedAppearance.colorScheme)
    }
    
    private var splashView: some View {
        ZStack {
            Color.theme.backgroundGradient
                .ignoresSafeArea()
            VStack(spacing: 14) {
                Image(systemName: "leaf.circle.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(Color.theme.accent)
                Text("MoodMate")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.theme.primaryText)
            }
        }
    }
}

#Preview {
    RootView()
}
