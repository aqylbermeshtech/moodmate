//
//  AppUser.swift
//  moodmate
//
//  Canonical identity projection (name, username, avatar) for a user id.
//  Posts carry only an authorId; views resolve identity through UserStore.
//

import Foundation

nonisolated struct AppUser: Identifiable, Codable, Equatable {
    let id: String
    var name: String
    var username: String
    var avatarImageName: String?
    var avatarImageData: Data?
    var avatarColorHex: String

    init(
        id: String,
        name: String,
        username: String,
        avatarImageName: String? = nil,
        avatarImageData: Data? = nil,
        avatarColorHex: String = "38B2AC"
    ) {
        self.id = id
        self.name = name
        self.username = username
        self.avatarImageName = avatarImageName
        self.avatarImageData = avatarImageData
        self.avatarColorHex = avatarColorHex
    }
}
