//
//  RootView.swift
//  moodmate
//
//  Created by Nurtore on 22.07.2026.
//

import SwiftUI

struct RootView: View {
    @StateObject private var sessionManager = AppSessionManager.shared
    
    var body: some View {
        Group {
            if sessionManager.isAuthenticated {
                HomeView()
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            } else {
                MoodMateAuthView()
                    .transition(.opacity)
            }
        }
        .animation(.spring(response: 0.45, dampingFraction: 0.8), value: sessionManager.isAuthenticated)
    }
}

#Preview {
    RootView()
}
