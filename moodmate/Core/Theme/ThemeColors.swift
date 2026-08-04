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
                ? UIColor(red: 0.07, green: 0.08, blue: 0.11, alpha: 1.0)
                : UIColor(red: 0.97, green: 0.98, blue: 0.99, alpha: 1.0)
        })
    }

    var secondaryBackground: Color {
        Color(UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(red: 0.11, green: 0.13, blue: 0.18, alpha: 1.0)
                : UIColor(red: 0.94, green: 0.95, blue: 0.97, alpha: 1.0)
        })
    }

    var surface: Color {
        Color(UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(red: 0.14, green: 0.16, blue: 0.23, alpha: 1.0)
                : UIColor.white
        })
    }

    var cardBackground: Color {
        Color(UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(red: 0.15, green: 0.17, blue: 0.24, alpha: 0.85)
                : UIColor.white.withAlphaComponent(0.85)
        })
    }
 
    var groupedBackground: Color {
        Color(UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(red: 0.10, green: 0.12, blue: 0.16, alpha: 1.0)
                : UIColor(red: 0.96, green: 0.97, blue: 0.99, alpha: 1.0)
        })
    }
    
    // MARK: - Typography
    
    var primaryText: Color {
        Color(UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(red: 0.95, green: 0.96, blue: 0.98, alpha: 1.0)
                : UIColor(red: 0.10, green: 0.12, blue: 0.18, alpha: 1.0)
        })
    }

    var secondaryText: Color {
        Color(UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(red: 0.68, green: 0.72, blue: 0.80, alpha: 1.0)
                : UIColor(red: 0.42, green: 0.45, blue: 0.52, alpha: 1.0)
        })
    }
  
    var tertiaryText: Color {
        Color(UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(red: 0.48, green: 0.52, blue: 0.60, alpha: 1.0)
                : UIColor(red: 0.62, green: 0.65, blue: 0.72, alpha: 1.0)
        })
    }
    
    // MARK: - Accents & States

    var accent: Color {
        Color(UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(red: 0.12, green: 0.76, blue: 0.74, alpha: 1.0)
                : UIColor(red: 0.22, green: 0.69, blue: 0.67, alpha: 1.0)
        })
    }

    var success: Color {
        Color(UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(red: 0.20, green: 0.83, blue: 0.60, alpha: 1.0)
                : UIColor(red: 0.06, green: 0.73, blue: 0.50, alpha: 1.0)
        })
    }

    var warning: Color {
        Color(UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(red: 0.98, green: 0.75, blue: 0.14, alpha: 1.0)
                : UIColor(red: 0.92, green: 0.64, blue: 0.05, alpha: 1.0)
        })
    }
    
    var error: Color {
        Color(UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(red: 0.97, green: 0.44, blue: 0.44, alpha: 1.0)
                : UIColor(red: 0.88, green: 0.25, blue: 0.25, alpha: 1.0)
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
                ? UIColor.black.withAlphaComponent(0.50)
                : UIColor(red: 0.10, green: 0.15, blue: 0.25, alpha: 0.08)
        })
    }

    var overlay: Color {
        Color(UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor.black.withAlphaComponent(0.70)
                : UIColor.black.withAlphaComponent(0.40)
        })
    }
    
    // MARK: - Background Gradients

    var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(UIColor { trait in
                    trait.userInterfaceStyle == .dark
                        ? UIColor(red: 0.06, green: 0.12, blue: 0.16, alpha: 1.0)
                        : UIColor(red: 0.22, green: 0.69, blue: 0.67, alpha: 0.18)
                }),
                Color(UIColor { trait in
                    trait.userInterfaceStyle == .dark
                        ? UIColor(red: 0.10, green: 0.08, blue: 0.16, alpha: 1.0)
                        : UIColor.purple.withAlphaComponent(0.12)
                })
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
