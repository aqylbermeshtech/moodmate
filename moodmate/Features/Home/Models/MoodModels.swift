//
//  MoodModels.swift
//  moodmate
//
//  Domain models for the mood-selection feature.
//  Kept separate from HomeViewModel so they can be used by any layer.
//

import Foundation

// MARK: - Selected Mood

/// A single value type representing the user's currently chosen mood.
/// Replaces the previous three parallel published properties
/// (selectedMoodEmoji / selectedMoodText / selectedMoodColorHex).
struct SelectedMood: Equatable {
    let emoji: String
    let text: String
    let colorHex: String
}

// MARK: - Mood Option

/// One entry in the mood-picker grid.
/// Previously defined as a nested type inside HomeViewModel.
struct MoodOption: Identifiable, Equatable {
    let id = UUID()
    let emoji: String
    let text: String
    let colorHex: String
}

// MARK: - Catalog

extension MoodOption {
    /// The full set of moods available in the picker.
    /// Centralised here so both HomeViewModel and CreatePostViewModel
    /// can share the same source of truth.
    static let catalog: [MoodOption] = [
        MoodOption(emoji: "😊", text: "Happy",     colorHex: "38B2AC"),
        MoodOption(emoji: "😌", text: "Calm",      colorHex: "4A5568"),
        MoodOption(emoji: "😴", text: "Sleepy",    colorHex: "667EEA"),
        MoodOption(emoji: "🤩", text: "Excited",   colorHex: "ED64A6"),
        MoodOption(emoji: "😔", text: "Sad",       colorHex: "A0AEC0"),
        MoodOption(emoji: "🧠", text: "Mindful",   colorHex: "805AD5"),
    ]
}
