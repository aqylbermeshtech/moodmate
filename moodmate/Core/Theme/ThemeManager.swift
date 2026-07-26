//
//  ThemeManager.swift
//  moodmate
//
//  Created by Antigravity on 26.07.2026.
//

import Combine
import SwiftUI

enum AppAppearance: String, CaseIterable, Identifiable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"
    
    var id: String { rawValue }
    
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

final class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    @AppStorage("app_appearance_preference") var selectedAppearanceRaw: String = AppAppearance.system.rawValue {
        didSet {
            objectWillChange.send()
        }
    }
    
    var selectedAppearance: AppAppearance {
        get {
            AppAppearance(rawValue: selectedAppearanceRaw) ?? .system
        }
        set {
            selectedAppearanceRaw = newValue.rawValue
        }
    }
    
    private init() {}
}
