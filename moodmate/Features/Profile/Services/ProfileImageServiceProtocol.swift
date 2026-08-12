import UIKit

protocol ProfileImageServiceProtocol: AnyObject {
    func compressAvatar(_ image: UIImage, maxDimension: CGFloat, compressionQuality: CGFloat) -> Data?

    func generateThumbnail(from data: Data, size: CGSize) -> UIImage?

    func saveAvatar(data: Data, userId: String) async throws -> Data

    func loadAvatar(for userId: String) -> UIImage?

    func deleteAvatar(userId: String) async throws
}

extension ProfileImageServiceProtocol {
    func compressAvatar(_ image: UIImage, maxDimension: CGFloat = 512, compressionQuality: CGFloat = 0.8) -> Data? {
        compressAvatar(image, maxDimension: maxDimension, compressionQuality: compressionQuality)
    }

    func generateThumbnail(from data: Data, size: CGSize = CGSize(width: 120, height: 120)) -> UIImage? {
        generateThumbnail(from: data, size: size)
    }
}
