//
//  ThemeColors.swift
//  moodmate
//
//  Created by Antigravity on 26.07.2026.
//

import SwiftUI
import UIKit

extension Color {
    static let theme = ThemeColors()
}

struct ThemeColors {
    // MARK: - Canvas & Surfaces

    var primaryBackground: Color {
        Color(UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(red: 0, green: 0, blue: 0, alpha: 1) // #000000
                : UIColor(red: 1, green: 1, blue: 1, alpha: 1) // #FFFFFF
        })
    }

    var secondaryBackground: Color {
        Color(UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(red: 0.086, green: 0.094, blue: 0.110, alpha: 1) // #16181C
                : UIColor(red: 0.969, green: 0.976, blue: 0.976, alpha: 1) // #F7F9F9
        })
    }

    var surface: Color {
        Color(UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(red: 0.086, green: 0.094, blue: 0.110, alpha: 1) // #16181C
                : UIColor(red: 0.969, green: 0.976, blue: 0.976, alpha: 1) // #F7F9F9
        })
    }

    var cardBackground: Color {
        Color(UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(red: 0.118, green: 0.125, blue: 0.141, alpha: 1) // #1E2024
                : UIColor(red: 0.937, green: 0.953, blue: 0.957, alpha: 1) // #EFF3F4
        })
    }

    var groupedBackground: Color {
        Color(UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(red: 0.086, green: 0.094, blue: 0.110, alpha: 1) // #16181C
                : UIColor(red: 0.969, green: 0.976, blue: 0.976, alpha: 1) // #F7F9F9
        })
    }

    var elevatedSurface: Color { surface }

    // MARK: - Typography

    var primaryText: Color {
        Color(UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(red: 0.906, green: 0.914, blue: 0.918, alpha: 1) // #E7E9EA
                : UIColor(red: 0.059, green: 0.078, blue: 0.098, alpha: 1) // #0F1419
        })
    }

    var secondaryText: Color {
        Color(UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(red: 0.443, green: 0.463, blue: 0.482, alpha: 1) // #71767B
                : UIColor(red: 0.325, green: 0.392, blue: 0.443, alpha: 1) // #536471
        })
    }

    var tertiaryText: Color {
        Color(UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(red: 0.443, green: 0.463, blue: 0.482, alpha: 1) // #71767B
                : UIColor(red: 0.325, green: 0.392, blue: 0.443, alpha: 1) // #536471
        })
    }

    // MARK: - Brand / Action

    var accent: Color {
        Color(red: 0.114, green: 0.608, blue: 0.941) // #1D9BF0 — X Blue
    }

    var accentPressed: Color {
        Color(red: 0.102, green: 0.549, blue: 0.847) // #1A8CD8
    }

    var repostGreen: Color {
        Color(red: 0.000, green: 0.729, blue: 0.486) // #00BA7C
    }

    var likePink: Color {
        Color(red: 0.976, green: 0.094, blue: 0.502) // #F91880
    }

    var verifiedGold: Color {
        Color(red: 0.918, green: 0.702, blue: 0.031) // #EAB308
    }

    var success: Color {
        Color(red: 0.000, green: 0.729, blue: 0.486) // same as repostGreen
    }

    var warning: Color {
        Color(red: 0.918, green: 0.702, blue: 0.031) // same as verifiedGold
    }

    var error: Color {
        Color(red: 0.957, green: 0.129, blue: 0.180) // #F4212E
    }

    // MARK: - Structure, Shadows & Overlays

    var divider: Color {
        Color(UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(red: 0.184, green: 0.200, blue: 0.212, alpha: 1) // #2F3336
                : UIColor(red: 0.937, green: 0.953, blue: 0.957, alpha: 1) // #EFF3F4
        })
    }

    var border: Color {
        Color(UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(red: 0.184, green: 0.200, blue: 0.212, alpha: 1) // #2F3336
                : UIColor(red: 0.937, green: 0.953, blue: 0.957, alpha: 1) // #EFF3F4
        })
    }

    var shadow: Color {
        Color(UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor.black.withAlphaComponent(0.4)
                : UIColor(red: 0.12, green: 0.12, blue: 0.10, alpha: 0.08)
        })
    }

    var overlay: Color {
        Color(UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor.black.withAlphaComponent(0.70)
                : UIColor.black.withAlphaComponent(0.40)
        })
    }

    // MARK: - Mood tokens (kept for compatibility)

    var happy: Color { Color(red: 0.72, green: 0.60, blue: 0.36) }
    var calm: Color { Color(red: 0.40, green: 0.55, blue: 0.62) }
    var excited: Color { Color(red: 0.67, green: 0.39, blue: 0.31) }
    var sad: Color { Color(red: 0.39, green: 0.43, blue: 0.57) }
    var tired: Color { Color(red: 0.48, green: 0.47, blue: 0.43) }
    var anxious: Color { Color(red: 0.55, green: 0.48, blue: 0.60) }
}

// MARK: - X Typography Scale (SF Pro fallback)

extension Font {
    static let xScreenTitle   = Font.system(size: 20, weight: .bold)
    static let xSectionHeader = Font.system(size: 17, weight: .bold)
    static let xDisplayName   = Font.system(size: 15, weight: .bold)
    static let xPostBody      = Font.system(size: 15, weight: .regular)
    static let xQuotedBody    = Font.system(size: 14, weight: .regular)
    static let xHandle        = Font.system(size: 15, weight: .regular)
    static let xActionCount   = Font.system(size: 13, weight: .regular)
    static let xTrendingTopic = Font.system(size: 15, weight: .bold)
    static let xTrendingMeta  = Font.system(size: 13, weight: .regular)
    static let xButton        = Font.system(size: 15, weight: .bold)
    static let xDMBody        = Font.system(size: 15, weight: .regular)
    static let xDMTimestamp   = Font.system(size: 11, weight: .regular)
}

// MARK: - Spacing & Radius

enum AppSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 20
    static let xxl: CGFloat = 24
    static let xxxl: CGFloat = 32
}

enum AppRadius {
    static let control: CGFloat = 9999  // Capsule
    static let card: CGFloat = 0        // X uses flat rows, no card rounding
    static let image: CGFloat = 16
}

// MARK: - X Pressable Button Style

struct XPressableStyle: ButtonStyle {
    var pressedScale: CGFloat = 0.97
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? pressedScale : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: - X Action Icon (Reply, Repost, Like, Views, Share)

struct XActionIcon: View {
    let systemName: String
    let count: Int
    let color: Color
    let active: Bool

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: systemName)
                .font(.system(size: 18.75, weight: active ? .semibold : .regular))
                .foregroundStyle(color)
            if count > 0 {
                Text(formatted(count))
                    .font(.xActionCount)
                    .foregroundStyle(color)
            }
        }
        .frame(minWidth: 44, minHeight: 44, alignment: .leading)
    }

    private func formatted(_ n: Int) -> String {
        switch n {
        case 1_000_000...: return String(format: "%.1fM", Double(n)/1_000_000)
        case 1_000...:     return String(format: "%.1fK", Double(n)/1_000)
        default:           return "\(n)"
        }
    }
}

// MARK: - X Feed Filter Tabs ("For you" / "Following")

struct XFeedFilter: View {
    @Binding var selection: Int
    private let titles = ["For you", "Following"]
    @Namespace private var indicator

    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<2) { i in
                VStack(spacing: 12) {
                    Text(titles[i])
                        .font(.xButton)
                        .foregroundStyle(selection == i ? Color.theme.primaryText : Color.theme.secondaryText)
                    if selection == i {
                        Capsule()
                            .fill(Color.theme.accent)
                            .frame(width: 40, height: 4)
                            .matchedGeometryEffect(id: "indicator", in: indicator)
                    } else {
                        Color.clear.frame(height: 4)
                    }
                }
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        selection = i
                    }
                }
            }
        }
        .frame(height: 48)
        .overlay(alignment: .bottom) {
            Rectangle().fill(Color.theme.divider).frame(height: 1)
        }
    }
}

