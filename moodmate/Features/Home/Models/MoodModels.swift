//
//  MoodModels.swift
//  moodmate
//
//  Domain models for the mood-selection feature.
//  Kept separate from HomeViewModel so they can be used by any layer.
//

import Foundation

// MARK: - Selected Mood

struct SelectedMood: Equatable {
    let emoji: String
    let text: String
    let colorHex: String
}

// MARK: - Mood Option

struct MoodOption: Identifiable, Equatable {
    let id = UUID()
    let emoji: String
    let text: String
    let colorHex: String
}

// MARK: - Catalog

extension MoodOption {
    static let catalog: [MoodOption] = [
        MoodOption(emoji: "😊", text: "Happy",     colorHex: "38B2AC"),
        MoodOption(emoji: "😌", text: "Calm",      colorHex: "4A5568"),
        MoodOption(emoji: "😴", text: "Sleepy",    colorHex: "667EEA"),
        MoodOption(emoji: "🤩", text: "Excited",   colorHex: "ED64A6"),
        MoodOption(emoji: "😔", text: "Sad",       colorHex: "A0AEC0"),
        MoodOption(emoji: "🧠", text: "Mindful",   colorHex: "805AD5"),
        MoodOption(emoji: "🔥", text: "Motivated", colorHex: "DD6B20"),
        MoodOption(emoji: "✨", text: "Inspired",  colorHex: "D69E2E"),
    ]
}
