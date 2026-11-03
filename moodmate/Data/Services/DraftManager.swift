//
//  DraftManager.swift
//  moodmate
//
//  Created by Antigravity on 31.07.2026.
//

import Foundation
import OSLog

nonisolated final class DraftManager: DraftStoreProtocol {
    private let draftKey = "MoodMate_CreatePost_Draft"
    private let logger = Logger(subsystem: "com.moodmate", category: "DraftManager")

    init() {}

    func saveDraft(_ draft: PostDraft) {
        do {
            let data = try JSONEncoder().encode(draft)
            UserDefaults.standard.set(data, forKey: draftKey)
        } catch {
            logger.error("Failed to save draft: \(error.localizedDescription, privacy: .public)")
        }
    }

    func loadDraft() -> PostDraft? {
        guard let data = UserDefaults.standard.data(forKey: draftKey) else { return nil }
        do {
            return try JSONDecoder().decode(PostDraft.self, from: data)
        } catch {
            logger.error("Failed to load draft: \(error.localizedDescription, privacy: .public)")
            return nil
        }
    }
    
    func clearDraft() {
        UserDefaults.standard.removeObject(forKey: draftKey)
    }
    
    var hasDraft: Bool {
        return UserDefaults.standard.data(forKey: draftKey) != nil
    }
}
