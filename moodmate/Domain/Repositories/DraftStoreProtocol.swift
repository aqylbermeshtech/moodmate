//
//  DraftStoreProtocol.swift
//  moodmate
//
//  Persistence contract for the create-post draft.
//

import Foundation

nonisolated protocol DraftStoreProtocol: AnyObject {
    func saveDraft(_ draft: PostDraft)
    func loadDraft() -> PostDraft?
    func clearDraft()
    var hasDraft: Bool { get }
}
