//
//  AvatarRepositoryProtocol.swift
//  moodmate
//
//  Avatar persistence contract. Speaks only in `Data` — UIImage compression
//  is a presentation concern (see Core/Utilities/ImageCompressor).
//

import Foundation

nonisolated protocol AvatarRepositoryProtocol: AnyObject {
    func saveAvatar(data: Data, userId: String) async throws -> Data
    func deleteAvatar(userId: String) async throws
}
