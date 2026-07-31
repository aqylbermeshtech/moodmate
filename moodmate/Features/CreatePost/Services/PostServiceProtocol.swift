//
//  PostServiceProtocol.swift
//  moodmate
//
//  Created by Antigravity on 31.07.2026.
//

import Foundation
import Combine

protocol PostServiceProtocol {
    var postsPublisher: AnyPublisher<[PostModel], Never> { get }
    func fetchPosts() async throws -> [PostModel]
    func createPost(_ post: PostModel) async throws -> PostModel
    func deletePost(id: String) async throws
    func toggleLike(postId: String) async throws
    func toggleBookmark(postId: String) async throws
}
