//
//  HomeViewModel.swift
//  moodmate
//
//  Created by Nurtore on 22.07.2026.
//

import SwiftUI
import FirebaseAuth
import Combine

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var currentUserDisplayName: String = "John"
    @Published var selectedMoodEmoji: String? = nil
    @Published var selectedMoodText: String? = nil
    @Published var selectedMoodColorHex: String? = nil
    
    @Published var friends: [MoodUser] = []
    @Published var feedPosts: [FeedPost] = []
    
    // Mood picker sheet is presented by HomeView directly (home-feed concern).
    @Published var showMoodPickerSheet = false
    // showCreatePostSheet has moved up to RootTabContainerView.
    // HomeView receives an onCreatePost() callback instead.
    
    private let postService: PostServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // Hardcoded mood options for Today's Mood Card picker
    struct MoodOption: Identifiable {
        let id = UUID()
        let emoji: String
        let text: String
        let colorHex: String
    }
    
    let moodOptions = [
        MoodOption(emoji: "😊", text: "Happy", colorHex: "38B2AC"), // Teal
        MoodOption(emoji: "😌", text: "Calm", colorHex: "4A5568"),  // Charcoal
        MoodOption(emoji: "😴", text: "Sleepy", colorHex: "667EEA"), // Indigo
        MoodOption(emoji: "🤩", text: "Excited", colorHex: "ED64A6"), // Pink
        MoodOption(emoji: "😔", text: "Sad", colorHex: "A0AEC0"),     // Slate
        MoodOption(emoji: "🧠", text: "Mindful", colorHex: "805AD5")  // Purple
    ]
    
    init(postService: PostServiceProtocol = MockPostService.shared) {
        self.postService = postService
        loadCurrentUser()
        loadFriends()
        observePosts()
        observeProfileUpdates()
    }
    
    func loadCurrentUser() {
        let currentUserId = ProfileService.shared.getCurrentUserId()
        if let profile = ProfileService.shared.getProfile(forId: currentUserId) {
            self.currentUserDisplayName = profile.displayName
        } else if let firebaseUser = FirebaseAuthService.shared.currentUser {
            if let displayName = firebaseUser.displayName, !displayName.isEmpty {
                self.currentUserDisplayName = displayName
            } else if let email = firebaseUser.email, !email.isEmpty {
                let prefix = email.components(separatedBy: "@").first ?? "John"
                self.currentUserDisplayName = prefix.capitalized
            }
        }
    }
    
    private func observeProfileUpdates() {
        ProfileService.shared.profileUpdatesPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] updatedProfile in
                guard let self = self else { return }
                let currentUserId = ProfileService.shared.getCurrentUserId()
                if updatedProfile.id == currentUserId {
                    self.currentUserDisplayName = updatedProfile.displayName
                }
                
                // Update friends list if matching
                if let index = self.friends.firstIndex(where: { $0.id == updatedProfile.id }) {
                    self.friends[index].name = updatedProfile.displayName
                    self.friends[index].username = updatedProfile.username
                    self.friends[index].avatarColorHex = updatedProfile.avatarColorHex
                    self.friends[index].avatarImageData = updatedProfile.avatarImageData
                }
                
                // Update feed posts matching author
                for i in 0..<self.feedPosts.count {
                    if self.feedPosts[i].user.id == updatedProfile.id {
                        var updatedUser = self.feedPosts[i].user
                        updatedUser.name = updatedProfile.displayName
                        updatedUser.username = updatedProfile.username
                        updatedUser.avatarColorHex = updatedProfile.avatarColorHex
                        updatedUser.avatarImageData = updatedProfile.avatarImageData
                        
                        let oldPost = self.feedPosts[i]
                        self.feedPosts[i] = FeedPost(
                            id: oldPost.id,
                            user: updatedUser,
                            timeAgo: oldPost.timeAgo,
                            postGradientStartHex: oldPost.postGradientStartHex,
                            postGradientEndHex: oldPost.postGradientEndHex,
                            quoteText: oldPost.quoteText,
                            caption: oldPost.caption,
                            images: oldPost.images,
                            moodEmoji: oldPost.moodEmoji,
                            moodText: oldPost.moodText,
                            moodColorHex: oldPost.moodColorHex,
                            visibility: oldPost.visibility,
                            likesCount: oldPost.likesCount,
                            commentsCount: oldPost.commentsCount,
                            isLiked: oldPost.isLiked,
                            isBookmarked: oldPost.isBookmarked
                        )
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    private func observePosts() {
        postService.postsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] posts in
                guard let self = self else { return }
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    self.feedPosts = posts.map { FeedPost(from: $0) }
                }
            }
            .store(in: &cancellables)
    }
    
    func addNewlyCreatedPost(_ postModel: PostModel) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
            let feedPost = FeedPost(from: postModel)
            if !feedPosts.contains(where: { $0.id == feedPost.id }) {
                feedPosts.insert(feedPost, at: 0)
            }
        }
    }
    
    func selectMood(emoji: String, text: String, colorHex: String) {
        withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
            self.selectedMoodEmoji = emoji
            self.selectedMoodText = text
            self.selectedMoodColorHex = colorHex
        }
    }
    
    func toggleLike(for post: FeedPost) {
        if let index = feedPosts.firstIndex(where: { $0.id == post.id }) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                feedPosts[index].isLiked.toggle()
                if feedPosts[index].isLiked {
                    feedPosts[index].likesCount += 1
                } else {
                    feedPosts[index].likesCount -= 1
                }
            }
            Task {
                try? await postService.toggleLike(postId: post.id)
            }
        }
    }
    
    func toggleBookmark(for post: FeedPost) {
        if let index = feedPosts.firstIndex(where: { $0.id == post.id }) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                feedPosts[index].isBookmarked.toggle()
            }
            Task {
                try? await postService.toggleBookmark(postId: post.id)
            }
        }
    }
    
    func signOut() {
        do {
            try FirebaseAuthService.shared.signOut()
        } catch {
            print("Failed to sign out: \(error.localizedDescription)")
        }
    }
    
    var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 {
            return "Good Morning,"
        } else if hour < 17 {
            return "Good Afternoon,"
        } else {
            return "Good Evening,"
        }
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: Date())
    }
    
    private func loadFriends() {
        friends = [
            MoodUser(id: "1", name: "Pepper", username: "pepperoni", avatarImageName: nil, avatarColorHex: "FF6B6B", currentMoodEmoji: "😊", currentMoodText: "Happy", currentMoodColorHex: "38B2AC"),
            MoodUser(id: "2", name: "Michele", username: "mj", avatarImageName: nil, avatarColorHex: "4DABF7", currentMoodEmoji: "😌", currentMoodText: "Calm", currentMoodColorHex: "4A5568"),
            MoodUser(id: "3", name: "Ned", username: "ceo", avatarImageName: nil, avatarColorHex: "BE4BDF", currentMoodEmoji: "😴", currentMoodText: "Sleepy", currentMoodColorHex: "667EEA"),
            MoodUser(id: "4", name: "Happy", username: "happyaunt", avatarImageName: nil, avatarColorHex: "FAB005", currentMoodEmoji: "🤩", currentMoodText: "Excited", currentMoodColorHex: "ED64A6"),
            MoodUser(id: "5", name: "Alex", username: "alexwang", avatarImageName: nil, avatarColorHex: "12B886", currentMoodEmoji: "🧠", currentMoodText: "Mindful", currentMoodColorHex: "805AD5")
        ]
    }
}
