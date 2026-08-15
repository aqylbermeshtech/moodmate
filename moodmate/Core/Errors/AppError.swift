//
//  AppError.swift
//  moodmate
//

import Foundation

enum AppError: LocalizedError {
    case notFound(String)
    case notAuthenticated
    case imageProcessingFailed
    case underlying(Error)

    var errorDescription: String? {
        switch self {
        case .notFound(let what):
            return "\(what) could not be found."
        case .notAuthenticated:
            return "You need to be signed in to do that."
        case .imageProcessingFailed:
            return "Failed to process the selected image."
        case .underlying(let error):
            return error.localizedDescription
        }
    }
}
