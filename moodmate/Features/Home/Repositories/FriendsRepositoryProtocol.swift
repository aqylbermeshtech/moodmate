//
//  FriendsRepositoryProtocol.swift
//  moodmate
//
//  Contract for supplying the friends list shown on the home feed.
//  Keeping this separate from ProfileRepositoryProtocol gives us a
//  clean boundary and lets us swap in a network-backed implementation later.
//

import Foundation

protocol FriendsRepositoryProtocol: AnyObject {
    func loadFriends() -> [MoodUser]
}
