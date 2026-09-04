//
//  Interest.swift
//  moodmate
//
//  The interest taxonomy the app is built around: picked during onboarding,
//  shown on the profile, and the signal any interest-aware feature reads.
//
//  Profiles store interest *ids*, never display names, so the wording of a
//  chip can change without rewriting everybody's stored profile.
//

import Foundation

struct Interest: Identifiable, Equatable, Hashable {
    let id: String
    let name: String
    let iconName: String
    let group: InterestGroup
}

enum InterestGroup: String, CaseIterable, Identifiable {
    case mindAndBody
    case outdoors
    case creative
    case foodAndDrink
    case culture
    case socialAndPlay

    var id: String { rawValue }

    var title: String {
        switch self {
        case .mindAndBody:   return "Mind & Body"
        case .outdoors:      return "Outdoors"
        case .creative:      return "Creative"
        case .foodAndDrink:  return "Food & Drink"
        case .culture:       return "Culture & Learning"
        case .socialAndPlay: return "Social & Play"
        }
    }
}

enum InterestCatalog {

    /// How many interests a person must pick before they can finish onboarding.
    static let minimumSelection = 3

    static let all: [Interest] = [
        // Mind & Body
        Interest(id: "meditation",  name: "Meditation",   iconName: "figure.mind.and.body", group: .mindAndBody),
        Interest(id: "yoga",        name: "Yoga",         iconName: "figure.yoga",          group: .mindAndBody),
        Interest(id: "running",     name: "Running",      iconName: "figure.run",           group: .mindAndBody),
        Interest(id: "strength",    name: "Strength",     iconName: "dumbbell.fill",        group: .mindAndBody),
        Interest(id: "cycling",     name: "Cycling",      iconName: "bicycle",              group: .mindAndBody),
        Interest(id: "sleep",       name: "Sleep",        iconName: "bed.double.fill",      group: .mindAndBody),

        // Outdoors
        Interest(id: "hiking",      name: "Hiking",       iconName: "figure.hiking",        group: .outdoors),
        Interest(id: "nature",      name: "Nature",       iconName: "leaf.fill",            group: .outdoors),
        Interest(id: "travel",      name: "Travel",       iconName: "airplane",             group: .outdoors),
        Interest(id: "camping",     name: "Camping",      iconName: "tent.fill",            group: .outdoors),
        Interest(id: "sunrises",    name: "Sunrises",     iconName: "sun.max.fill",         group: .outdoors),
        Interest(id: "animals",     name: "Animals",      iconName: "pawprint.fill",        group: .outdoors),

        // Creative
        Interest(id: "photography", name: "Photography",  iconName: "camera.fill",          group: .creative),
        Interest(id: "writing",     name: "Writing",      iconName: "pencil.and.outline",   group: .creative),
        Interest(id: "painting",    name: "Painting",     iconName: "paintpalette.fill",    group: .creative),
        Interest(id: "music",       name: "Music",        iconName: "music.note",           group: .creative),
        Interest(id: "design",      name: "Design",       iconName: "wand.and.rays",        group: .creative),
        Interest(id: "crafts",      name: "Crafts",       iconName: "scissors",             group: .creative),

        // Food & Drink
        Interest(id: "cooking",     name: "Cooking",      iconName: "fork.knife",           group: .foodAndDrink),
        Interest(id: "coffee",      name: "Coffee",       iconName: "cup.and.saucer.fill",  group: .foodAndDrink),
        Interest(id: "baking",      name: "Baking",       iconName: "takeoutbag.and.cup.and.straw.fill", group: .foodAndDrink),
        Interest(id: "healthyfood", name: "Eating Well",  iconName: "carrot.fill",          group: .foodAndDrink),

        // Culture & Learning
        Interest(id: "reading",     name: "Reading",      iconName: "book.fill",            group: .culture),
        Interest(id: "films",       name: "Films",        iconName: "film.fill",            group: .culture),
        Interest(id: "theatre",     name: "Theatre",      iconName: "theatermasks.fill",    group: .culture),
        Interest(id: "languages",   name: "Languages",    iconName: "globe",                group: .culture),
        Interest(id: "science",     name: "Science",      iconName: "brain.head.profile",   group: .culture),
        Interest(id: "podcasts",    name: "Podcasts",     iconName: "newspaper.fill",       group: .culture),

        // Social & Play
        Interest(id: "gaming",      name: "Gaming",       iconName: "gamecontroller.fill",  group: .socialAndPlay),
        Interest(id: "boardgames",  name: "Board Games",  iconName: "puzzlepiece.fill",     group: .socialAndPlay),
        Interest(id: "sports",      name: "Sports",       iconName: "sportscourt.fill",     group: .socialAndPlay),
        Interest(id: "friends",     name: "Friends",      iconName: "person.2.fill",        group: .socialAndPlay),
        Interest(id: "volunteering", name: "Volunteering", iconName: "heart.fill",          group: .socialAndPlay),
        Interest(id: "tech",        name: "Tech",         iconName: "laptopcomputer",       group: .socialAndPlay)
    ]

    private static let byId: [String: Interest] = Dictionary(
        uniqueKeysWithValues: all.map { ($0.id, $0) }
    )

    static func interests(in group: InterestGroup) -> [Interest] {
        all.filter { $0.group == group }
    }

    static func interest(id: String) -> Interest? {
        byId[id]
    }

    /// Resolves stored ids in the order they were saved, dropping any id that
    /// is no longer in the catalog.
    static func interests(ids: [String]) -> [Interest] {
        ids.compactMap { byId[$0] }
    }
}
