//
//  AvatarRepository.swift
//  moodmate
//

import UIKit

final class AvatarRepository: AvatarRepositoryProtocol {
    static let shared = AvatarRepository()

    private let memoryCache = NSCache<NSString, UIImage>()
    private let fileManager = FileManager.default

    private var avatarsDirectory: URL {
        let paths = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        let directory = paths[0].appendingPathComponent("Avatars", isDirectory: true)
        if !fileManager.fileExists(atPath: directory.path) {
            try? fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        }
        return directory
    }

    private init() {
        memoryCache.countLimit = 100
    }

    // MARK: - Compression & Downscaling

    func compressAvatar(_ image: UIImage, maxDimension: CGFloat = 512, compressionQuality: CGFloat = 0.8) -> Data? {
        let scaledImage = downscaleImage(image, maxDimension: maxDimension)
        return scaledImage.jpegData(compressionQuality: compressionQuality)
    }

    func generateThumbnail(from data: Data, size: CGSize = CGSize(width: 120, height: 120)) -> UIImage? {
        guard let originalImage = UIImage(data: data) else { return nil }

        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            originalImage.draw(in: CGRect(origin: .zero, size: size))
        }
    }

    // MARK: - Save & Load

    func saveAvatar(data: Data, userId: String) async throws -> Data {
        guard let image = UIImage(data: data),
              let compressedData = compressAvatar(image) else {
            throw ProfileImageError.compressionFailed
        }

        let fileURL = avatarFileURL(for: userId)
        try compressedData.write(to: fileURL, options: .atomic)

        if let compressedImage = UIImage(data: compressedData) {
            memoryCache.setObject(compressedImage, forKey: userId as NSString)
        }

        return compressedData
    }

    func loadAvatar(for userId: String) -> UIImage? {
        if let cached = memoryCache.object(forKey: userId as NSString) {
            return cached
        }

        let fileURL = avatarFileURL(for: userId)
        guard fileManager.fileExists(atPath: fileURL.path),
              let data = try? Data(contentsOf: fileURL),
              let image = UIImage(data: data) else {
            return nil
        }

        memoryCache.setObject(image, forKey: userId as NSString)
        return image
    }

    func deleteAvatar(userId: String) async throws {
        memoryCache.removeObject(forKey: userId as NSString)
        let fileURL = avatarFileURL(for: userId)
        if fileManager.fileExists(atPath: fileURL.path) {
            try fileManager.removeItem(at: fileURL)
        }
    }

    // MARK: - Helpers

    private func avatarFileURL(for userId: String) -> URL {
        avatarsDirectory.appendingPathComponent("\(userId)_avatar.jpg")
    }

    private func downscaleImage(_ image: UIImage, maxDimension: CGFloat) -> UIImage {
        let size = image.size
        guard size.width > maxDimension || size.height > maxDimension else { return image }

        let aspectWidth = maxDimension / size.width
        let aspectHeight = maxDimension / size.height
        let aspectRatio = min(aspectWidth, aspectHeight)

        let newSize = CGSize(width: size.width * aspectRatio, height: size.height * aspectRatio)
        let renderer = UIGraphicsImageRenderer(size: newSize)

        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}

enum ProfileImageError: LocalizedError {
    case compressionFailed
    case saveFailed

    var errorDescription: String? {
        switch self {
        case .compressionFailed:
            return "Failed to process the selected image."
        case .saveFailed:
            return "Failed to save the avatar image."
        }
    }
}
