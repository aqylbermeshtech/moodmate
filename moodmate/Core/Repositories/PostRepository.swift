//
//  PostRepository.swift
//  moodmate
//
//  Single source of truth for all posts. Every feature reads a projection
//  from here and routes mutations back through here.
//
//  Persists to a JSON file in the documents directory (like ProfileRepository),
//  so user-created posts survive launches.
//

import Foundation
import Combine
import OSLog

final class PostRepository: PostRepositoryProtocol {
    static let shared = PostRepository()

    @Published private var posts: [PostModel] = [] {
        didSet {
            logger.debug("posts changed: \(self.posts.map(\.id).joined(separator: ","), privacy: .public)")
        }
    }

    var allPosts: [PostModel] { posts }

    var postsPublisher: AnyPublisher<[PostModel], Never> {
        $posts.eraseToAnyPublisher()
    }

    private let postUpdateSubject = PassthroughSubject<PostModel, Never>()
    var postUpdatePublisher: AnyPublisher<PostModel, Never> {
        postUpdateSubject.eraseToAnyPublisher()
    }

    private let logger = Logger(subsystem: "com.moodmate", category: "PostRepository")

    // MARK: - Local store

    private let fileManager = FileManager.default
    private let storageKey = "moodmate_posts_v2.json"

    /// Files written by builds that seeded fake posts. Removed on first launch
    /// so that content can't come back from disk.
    private static let legacyStorageKeys = ["moodmate_posts_v1.json"]
    private static let legacyDefaultsKeys = ["moodmate_post_seed_version"]

    private var storageFileURL: URL {
        documentsDirectory.appendingPathComponent(storageKey)
    }

    private var documentsDirectory: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    init() {
        removeLegacyStorage()
        loadPersistedPosts()
    }

    private func removeLegacyStorage() {
        for key in Self.legacyStorageKeys {
            try? fileManager.removeItem(at: documentsDirectory.appendingPathComponent(key))
        }
        for key in Self.legacyDefaultsKeys {
            UserDefaults.standard.removeObject(forKey: key)
        }
    }

    // MARK: - Reads

    func fetchPosts() async throws -> [PostModel] {
        try await Task.sleep(nanoseconds: 150_000_000)
        return posts
    }

    func posts(forAuthor authorId: String) -> [PostModel] {
        posts.filter { $0.authorId == authorId }
    }

    func post(id: String) -> PostModel? {
        posts.first { $0.id == id }
    }

    // MARK: - Mutations

    func createPost(_ post: PostModel) async throws -> PostModel {
        try await Task.sleep(nanoseconds: 400_000_000)
        posts.insert(post, at: 0)
        persistPosts()
        postUpdateSubject.send(post)
        return post
    }

    func deletePost(id: String) async throws {
        try await Task.sleep(nanoseconds: 100_000_000)
        posts.removeAll { $0.id == id }
        persistPosts()
    }

    func setLike(postId: String, isLiked: Bool) async throws {
        guard let index = posts.firstIndex(where: { $0.id == postId }) else { return }
        guard posts[index].isLiked != isLiked else { return }

        var updated = posts[index]
        updated.isLiked = isLiked
        updated.likesCount += isLiked ? 1 : -1
        posts[index] = updated
        persistPosts()

        logger.debug("like committed for \(postId, privacy: .public): isLiked=\(isLiked, privacy: .public) count=\(updated.likesCount, privacy: .public)")
        postUpdateSubject.send(updated)
    }

    func toggleBookmark(postId: String) async throws {
        guard let index = posts.firstIndex(where: { $0.id == postId }) else { return }
        posts[index].isBookmarked.toggle()
        persistPosts()
        postUpdateSubject.send(posts[index])
    }

    // MARK: - Persistence

    private func persistPosts() {
        do {
            let data = try JSONEncoder().encode(posts)
            try data.write(to: storageFileURL, options: .atomic)
        } catch {
            logger.error("Failed to persist posts: \(error, privacy: .public)")
        }
    }

    private func loadPersistedPosts() {
        guard fileManager.fileExists(atPath: storageFileURL.path) else { return }
        do {
            let data = try Data(contentsOf: storageFileURL)
            posts = try JSONDecoder().decode([PostModel].self, from: data)
        } catch {
            logger.error("Failed to load persisted posts: \(error, privacy: .public)")
        }
    }
}
