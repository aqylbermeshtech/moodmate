//
//  UIImage+Base64.swift
//  moodmate
//
//  Posts carry their photos as base64 strings (see `CreatePostViewModel`),
//  so every surface that renders one needs the same decode.
//

import UIKit

extension UIImage {

    /// Decodes a base64-encoded image, with or without a leading
    /// `data:image/jpeg;base64,` descriptor.
    static func fromBase64(_ string: String) -> UIImage? {
        let encoded: String
        if let separator = string.firstIndex(of: ",") {
            encoded = String(string[string.index(after: separator)...])
        } else {
            encoded = string
        }

        guard let data = Data(base64Encoded: encoded) else { return nil }
        return UIImage(data: data)
    }
}
