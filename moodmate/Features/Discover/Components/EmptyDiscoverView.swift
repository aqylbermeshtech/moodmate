//
//  EmptyDiscoverView.swift
//  moodmate
//
//  Created by Nurtore on 26.07.2026.
//

import SwiftUI

struct EmptyDiscoverView: View {
    let hasActiveFilter: Bool
    var onClearFilters: () -> Void
    var onExplore: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color.theme.accent.opacity(0.06))
                    .frame(width: 120, height: 120)

                Circle()
                    .fill(Color.theme.secondaryBackground)
                    .frame(width: 90, height: 90)
                    .offset(x: 15, y: -10)

                Image(systemName: hasActiveFilter ? "line.3.horizontal.decrease.circle" : "sparkle.magnifyingglass")
                    .font(.system(size: 44))
                    .foregroundStyle(Color.theme.accent)
            }
            .padding(.bottom, 4)

            VStack(spacing: 8) {
                Text(hasActiveFilter ? "No results found" : "Nothing to discover yet")
                    .font(.xScreenTitle)
                    .foregroundStyle(Color.theme.primaryText)

                Text(hasActiveFilter
                     ? "Try a different filter or clear your current selection to explore more content."
                     : "Start exploring people, posts, and moments. The community is waiting for you!")
                    .font(.xPostBody)
                    .foregroundStyle(Color.theme.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            VStack(spacing: 10) {
                if hasActiveFilter {
                    Button(action: onClearFilters) {
                        HStack(spacing: 6) {
                            Image(systemName: "xmark.circle")
                                .font(.system(size: 14, weight: .medium))
                            Text("Clear Filters")
                                .font(.xButton)
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.theme.accent)
                        .clipShape(Capsule())
                    }
                    .buttonStyle(XPressableStyle())
                }

                Button(action: onExplore) {
                    HStack(spacing: 6) {
                        Image(systemName: "safari")
                            .font(.system(size: 14, weight: .medium))
                        Text("Explore Trending")
                            .font(.xButton)
                    }
                    .foregroundStyle(Color.theme.accent)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.theme.accent.opacity(0.1))
                    .clipShape(Capsule())
                }
                .buttonStyle(XPressableStyle())
            }
            .padding(.top, 4)
        }
        .padding(.vertical, 60)
    }
}

#Preview {
    VStack(spacing: 40) {
        EmptyDiscoverView(hasActiveFilter: false, onClearFilters: {}, onExplore: {})
        Divider()
        EmptyDiscoverView(hasActiveFilter: true, onClearFilters: {}, onExplore: {})
    }
    .background(Color.theme.primaryBackground)
}
