//
//  MockPostService.swift
//  moodmate
//
//  Created by Antigravity on 31.07.2026.
//

import Foundation
import Combine
import OSLog

final class MockPostService: PostServiceProtocol {
    static let shared = MockPostService()
    
    @Published private var posts: [PostModel] = [] {
        didSet {
            logger.debug("service posts changed: \(self.posts.map(\.id).joined(separator: ","), privacy: .public)")
        }
    }
    
    var postsPublisher: AnyPublisher<[PostModel], Never> {
        $posts.eraseToAnyPublisher()
    }
    
    private var cancellables = Set<AnyCancellable>()
    private let logger = Logger(subsystem: "com.moodmate", category: "PostService")
    
    init() {
        seedInitialPosts()
        observeProfileUpdates()
    }
    
    private func observeProfileUpdates() {
        ProfileService.shared.profileUpdatesPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] updatedProfile in
                guard let self = self else { return }
                for i in 0..<self.posts.count {
                    if self.posts[i].author.id == updatedProfile.id {
                        var updatedAuthor = self.posts[i].author
                        updatedAuthor.name = updatedProfile.displayName
                        updatedAuthor.username = updatedProfile.username
                        updatedAuthor.avatarColorHex = updatedProfile.avatarColorHex
                        updatedAuthor.avatarImageData = updatedProfile.avatarImageData
                        self.posts[i].author = updatedAuthor
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    func fetchPosts() async throws -> [PostModel] {
        try await Task.sleep(nanoseconds: 150_000_000)
        return posts
    }
    
    func createPost(_ post: PostModel) async throws -> PostModel {
        try await Task.sleep(nanoseconds: 400_000_000)
        posts.insert(post, at: 0)
        return post
    }
    
    func deletePost(id: String) async throws {
        try await Task.sleep(nanoseconds: 100_000_000)
        posts.removeAll { $0.id == id }
    }
    
    func setLike(postId: String, isLiked: Bool) async throws {
        if let index = posts.firstIndex(where: { $0.id == postId }) {
            var updatedPosts = posts
            let previousLiked = posts[index].isLiked
            let previousCount = posts[index].likesCount
            guard previousLiked != isLiked else { return }

            updatedPosts[index].isLiked = isLiked
            if isLiked {
                updatedPosts[index].likesCount += 1
            } else {
                updatedPosts[index].likesCount -= 1
            }

            posts = updatedPosts
            logger.debug(
                "like committed for \(postId, privacy: .public): liked \(previousLiked, privacy: .public)->\(self.posts[index].isLiked, privacy: .public), count \(previousCount, privacy: .public)->\(self.posts[index].likesCount, privacy: .public)"
            )
        }
    }
    
    func toggleBookmark(postId: String) async throws {
        if let index = posts.firstIndex(where: { $0.id == postId }) {
            posts[index].isBookmarked.toggle()
        }
    }
    
    private func seedInitialPosts() {
        posts = [
            PostModel(
                id: "p1",
                author: MoodUser(id: "2", name: "Michele", username: "mj", avatarImageName: nil, avatarColorHex: "4DABF7", currentMoodEmoji: "😌", currentMoodText: "Calm", currentMoodColorHex: "4A5568"),
                mood: "Calm",
                moodEmoji: "😌",
                moodColorHex: "4A5568",
                text: "Taking a conscious pause today. A reminder that it is okay to just be, rather than always do. 🌱✨",
                images: [],
                visibility: .publicVisibility,
                createdAt: Date().addingTimeInterval(-7200),
                likesCount: 24,
                commentsCount: 3,
                bookmarksCount: 5,
                isLiked: false,
                isBookmarked: false,
                quoteText: "Breathe in experience, breathe out poetry.",
                gradientStartHex: "38B2AC",
                gradientEndHex: "805AD5"
            ),
            PostModel(
                id: "p2",
                author: MoodUser(id: "3", name: "Ned", username: "ceo", avatarImageName: nil, avatarColorHex: "BE4BDF", currentMoodEmoji: "😴", currentMoodText: "Sleepy", currentMoodColorHex: "667EEA"),
                mood: "Sleepy",
                moodEmoji: "😴",
                moodColorHex: "667EEA",
                text: "Listening to my body and getting to sleep early tonight. Recharge session starts now. 💤😴 #nightroutine #rest",
                images: [],
                visibility: .publicVisibility,
                createdAt: Date().addingTimeInterval(-10800),
                likesCount: 15,
                commentsCount: 1,
                bookmarksCount: 2,
                isLiked: true,
                isBookmarked: false,
                quoteText: "Rest is a fine medicine.",
                gradientStartHex: "1A365D",
                gradientEndHex: "667EEA"
            ),
            PostModel(
                id: "p3",
                author: MoodUser(id: "1", name: "Pepper", username: "pepperoni", avatarImageName: nil, avatarColorHex: "FF6B6B", currentMoodEmoji: "😊", currentMoodText: "Happy", currentMoodColorHex: "38B2AC"),
                mood: "Happy",
                moodEmoji: "😊",
                moodColorHex: "38B2AC",
                text: "Morning run cleared my head. Endorphins are flowing! Highly recommend starting your day active! 🏃‍♂️☀️ #fitness #mindset",
                images: [],
                visibility: .publicVisibility,
                createdAt: Date().addingTimeInterval(-18000),
                likesCount: 42,
                commentsCount: 8,
                bookmarksCount: 12,
                isLiked: false,
                isBookmarked: true,
                quoteText: "Motion creates emotion.",
                gradientStartHex: "ED64A6",
                gradientEndHex: "ECC94B"
            ),
            PostModel(
                id: "p4",
                author: MoodUser(id: "4", name: "Happy", username: "happyaunt", avatarImageName: nil, avatarColorHex: "FAB005", currentMoodEmoji: "🤩", currentMoodText: "Excited", currentMoodColorHex: "ED64A6"),
                mood: "Excited",
                moodEmoji: "🤩",
                moodColorHex: "ED64A6",
                text: "We launched our beta today! Feeling incredibly excited and grateful for the team's effort! 🚀🎉🙌 #launchday",
                images: [],
                visibility: .publicVisibility,
                createdAt: Date().addingTimeInterval(-21600),
                likesCount: 56,
                commentsCount: 12,
                bookmarksCount: 4,
                isLiked: false,
                isBookmarked: false,
                quoteText: "Celebrate the tiny wins.",
                gradientStartHex: "ED64A6",
                gradientEndHex: "FEFCBF"
            ),
            PostModel(
                id: "p5",
                author: MoodUser(id: "5", name: "Alex", username: "alexwang", avatarImageName: nil, avatarColorHex: "12B886", currentMoodEmoji: "🧠", currentMoodText: "Mindful", currentMoodColorHex: "805AD5"),
                mood: "Mindful",
                moodEmoji: "🧠",
                moodColorHex: "805AD5",
                text: "Enjoyed a quiet matcha latte. Mindful sipping: focusing on the warmth, the taste, and the silence. 🍵🧘‍♂️",
                images: [],
                visibility: .publicVisibility,
                createdAt: Date().addingTimeInterval(-28800),
                likesCount: 31,
                commentsCount: 4,
                bookmarksCount: 3,
                isLiked: false,
                isBookmarked: false,
                quoteText: "Be here now.",
                gradientStartHex: "12B886",
                gradientEndHex: "38B2AC"
            )
        ]
    }
}
