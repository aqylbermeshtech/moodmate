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
    // MARK: - Backgrounds

    var primaryBackground: Color {
        Color(UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(red: 0.10, green: 0.105, blue: 0.10, alpha: 1.0)
                : UIColor(red: 0.965, green: 0.955, blue: 0.93, alpha: 1.0)
        })
    }

    var secondaryBackground: Color {
        Color(UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(red: 0.135, green: 0.14, blue: 0.135, alpha: 1.0)
                : UIColor(red: 0.935, green: 0.925, blue: 0.90, alpha: 1.0)
        })
    }

    var surface: Color {
        Color(UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(red: 0.17, green: 0.175, blue: 0.165, alpha: 1.0)
                : UIColor(red: 0.985, green: 0.98, blue: 0.96, alpha: 1.0)
        })
    }

    var cardBackground: Color {
        Color(UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(red: 0.17, green: 0.175, blue: 0.165, alpha: 1.0)
                : UIColor(red: 0.985, green: 0.98, blue: 0.96, alpha: 1.0)
        })
    }
 
    var groupedBackground: Color {
        Color(UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(red: 0.12, green: 0.125, blue: 0.12, alpha: 1.0)
                : UIColor(red: 0.95, green: 0.94, blue: 0.915, alpha: 1.0)
        })
    }

    var elevatedSurface: Color { surface }
    
    // MARK: - Typography
    
    var primaryText: Color {
        Color(UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(red: 0.93, green: 0.925, blue: 0.89, alpha: 1.0)
                : UIColor(red: 0.16, green: 0.155, blue: 0.14, alpha: 1.0)
        })
    }

    var secondaryText: Color {
        Color(UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(red: 0.67, green: 0.67, blue: 0.63, alpha: 1.0)
                : UIColor(red: 0.43, green: 0.42, blue: 0.39, alpha: 1.0)
        })
    }
  
    var tertiaryText: Color {
        Color(UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(red: 0.48, green: 0.49, blue: 0.46, alpha: 1.0)
                : UIColor(red: 0.60, green: 0.59, blue: 0.55, alpha: 1.0)
        })
    }
    
    // MARK: - Accents & States

    var accent: Color {
        Color(UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(red: 0.52, green: 0.66, blue: 0.60, alpha: 1.0)
                : UIColor(red: 0.32, green: 0.48, blue: 0.40, alpha: 1.0)
        })
    }

    var success: Color {
        Color(UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(red: 0.49, green: 0.68, blue: 0.56, alpha: 1.0)
                : UIColor(red: 0.31, green: 0.54, blue: 0.40, alpha: 1.0)
        })
    }

    var warning: Color {
        Color(UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(red: 0.76, green: 0.64, blue: 0.39, alpha: 1.0)
                : UIColor(red: 0.64, green: 0.48, blue: 0.22, alpha: 1.0)
        })
    }
    
    var error: Color {
        Color(UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(red: 0.82, green: 0.52, blue: 0.50, alpha: 1.0)
                : UIColor(red: 0.68, green: 0.32, blue: 0.30, alpha: 1.0)
        })
    }
    
    // MARK: - Structure, Shadows & Overlays

    var divider: Color {
        Color(UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(white: 1.0, alpha: 0.12)
                : UIColor(white: 0.0, alpha: 0.08)
        })
    }

    var border: Color {
        Color(UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(white: 1.0, alpha: 0.15)
                : UIColor(white: 0.0, alpha: 0.10)
        })
    }
    
    var shadow: Color {
        Color(UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor.black.withAlphaComponent(0.22)
                : UIColor(red: 0.12, green: 0.12, blue: 0.10, alpha: 0.06)
        })
    }

    var overlay: Color {
        Color(UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor.black.withAlphaComponent(0.70)
                : UIColor.black.withAlphaComponent(0.40)
        })
    }
    
    // MARK: - Mood tokens

    var happy: Color { Color(red: 0.72, green: 0.60, blue: 0.36) }
    var calm: Color { Color(red: 0.40, green: 0.55, blue: 0.62) }
    var excited: Color { Color(red: 0.67, green: 0.39, blue: 0.31) }
    var sad: Color { Color(red: 0.39, green: 0.43, blue: 0.57) }
    var tired: Color { Color(red: 0.48, green: 0.47, blue: 0.43) }
    var anxious: Color { Color(red: 0.55, green: 0.48, blue: 0.60) }
}

enum AppSpacing {
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 20
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
    static let xxxl: CGFloat = 40
}

enum AppRadius {
    static let control: CGFloat = 10
    static let card: CGFloat = 14
    static let image: CGFloat = 12
}

enum AppShadow {
    static let radius: CGFloat = 4
    static let y: CGFloat = 2
}

extension View {
    func quietCard() -> some View {
        background(Color.theme.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                    .stroke(Color.theme.border, lineWidth: 0.5)
            }
            .shadow(color: Color.theme.shadow, radius: AppShadow.radius, y: AppShadow.y)
    }
}
