//
//  ImageCompressor.swift
//  moodmate
//
//  UIImage downscaling + JPEG compression. This is a presentation-layer
//  concern: the domain and data layers speak only in `Data`.
//

import UIKit

enum ImageCompressor {
    static func compress(_ image: UIImage, maxDimension: CGFloat = 512, compressionQuality: CGFloat = 0.8) -> Data? {
        let scaledImage = downscale(image, maxDimension: maxDimension)
        return scaledImage.jpegData(compressionQuality: compressionQuality)
    }

    private static func downscale(_ image: UIImage, maxDimension: CGFloat) -> UIImage {
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
