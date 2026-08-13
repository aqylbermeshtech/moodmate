//
//  SharedModels.swift
//  moodmate
//
//  Types shared across features that would otherwise get redefined
//  identically in more than one place.
//

import Foundation

/// Who can see something — a post, a profile. Previously PostVisibility and
/// PrivacySetting: same three cases, same raw values, same icons, just
/// defined twice. The human-readable description of each case is
/// context-specific (a post's "Visible to everyone on MoodMate" reads
/// differently from a profile's "Anyone on MoodMate can view your profile
/// and public posts") and deliberately stays out of this type — each
/// feature that displays one owns its own wording.
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
