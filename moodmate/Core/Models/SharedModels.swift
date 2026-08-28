//
//  SharedModels.swift
//  moodmate
//
//  Types shared across features that would otherwise get redefined
//  identically in more than one place.
//

import Foundation

/// Case descriptions are context-specific, so each feature owns its own wording.
enum Visibility: String, Codable, CaseIterable, Identifiable {
    case publicVisibility = "Public"
    case friendsOnly = "Friends"
    case privateVisibility = "Private"

    var id: String { rawValue }

    var iconName: String {
        switch self {
        case .publicVisibility: return "globe"
        case .friendsOnly: return "person.2.fill"
        case .privateVisibility: return "lock.fill"
        }
    }
}
