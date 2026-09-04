//
//  PostRepositoryProtocol.swift
//  moodmate
//

import Foundation
import Combine

protocol PostRepositoryProtocol: AnyObject {
    var allPosts: [PostModel] { get }
    var postsPublisher: AnyPublisher<[PostModel], Never> { get }
    var postUpdatePublisher: AnyPublisher<PostModel, Never> { get }

    func fetchPosts() async throws -> [PostModel]
    func posts(forAuthor authorId: String) -> [PostModel]
    func post(id: String) -> PostModel?
    func createPost(_ post: PostModel) async throws -> PostModel
    func deletePost(id: String) async throws
    func setLike(postId: String, isLiked: Bool) async throws
    func toggleBookmark(postId: String) async throws
}
