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
    
    @Published var showMoodPickerSheet = false
    
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
    
    init() {
        loadCurrentUser()
        loadFriends()
        loadFeedPosts()
    }
    
    func loadCurrentUser() {
        if let firebaseUser = FirebaseAuthService.shared.currentUser {
            if let displayName = firebaseUser.displayName, !displayName.isEmpty {
                self.currentUserDisplayName = displayName
            } else if let email = firebaseUser.email, !email.isEmpty {
                // Extract from email (e.g. john@example.com -> John)
                let prefix = email.components(separatedBy: "@").first ?? "John"
                self.currentUserDisplayName = prefix.capitalized
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
        }
    }
    
    func toggleBookmark(for post: FeedPost) {
        if let index = feedPosts.firstIndex(where: { $0.id == post.id }) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                feedPosts[index].isBookmarked.toggle()
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
            MoodUser(id: "1", name: "Alex", username: "alex_active", avatarImageName: nil, avatarColorHex: "FF6B6B", currentMoodEmoji: "😊", currentMoodText: "Happy", currentMoodColorHex: "38B2AC"),
            MoodUser(id: "2", name: "Emma", username: "emma_zen", avatarImageName: nil, avatarColorHex: "4DABF7", currentMoodEmoji: "😌", currentMoodText: "Calm", currentMoodColorHex: "4A5568"),
            MoodUser(id: "3", name: "Daniel", username: "daniel_sleeps", avatarImageName: nil, avatarColorHex: "BE4BDF", currentMoodEmoji: "😴", currentMoodText: "Sleepy", currentMoodColorHex: "667EEA"),
            MoodUser(id: "4", name: "Chloe", username: "chloe_shine", avatarImageName: nil, avatarColorHex: "FAB005", currentMoodEmoji: "🤩", currentMoodText: "Excited", currentMoodColorHex: "ED64A6"),
            MoodUser(id: "5", name: "Marcus", username: "marcus_mind", avatarImageName: nil, avatarColorHex: "12B886", currentMoodEmoji: "🧠", currentMoodText: "Mindful", currentMoodColorHex: "805AD5")
        ]
    }
    
    private func loadFeedPosts() {
        feedPosts = [
            FeedPost(
                id: "p1",
                user: MoodUser(id: "2", name: "Emma", username: "emma_zen", avatarImageName: nil, avatarColorHex: "4DABF7", currentMoodEmoji: "😌", currentMoodText: "Calm", currentMoodColorHex: "4A5568"),
                timeAgo: "2 hrs ago",
                postGradientStartHex: "38B2AC",
                postGradientEndHex: "805AD5",
                quoteText: "Breathe in experience, breathe out poetry.",
                caption: "Taking a conscious pause today. A reminder that it is okay to just be, rather than always do. 🌱✨",
                likesCount: 24,
                commentsCount: 3,
                isLiked: false,
                isBookmarked: false
            ),
            FeedPost(
                id: "p2",
                user: MoodUser(id: "3", name: "Daniel", username: "daniel_sleeps", avatarImageName: nil, avatarColorHex: "BE4BDF", currentMoodEmoji: "😴", currentMoodText: "Sleepy", currentMoodColorHex: "667EEA"),
                timeAgo: "3 hrs ago",
                postGradientStartHex: "1A365D",
                postGradientEndHex: "667EEA",
                quoteText: "Rest is a fine medicine.",
                caption: "Listening to my body and getting to sleep early tonight. Recharge session starts now. 💤😴",
                likesCount: 15,
                commentsCount: 1,
                isLiked: true,
                isBookmarked: false
            ),
            FeedPost(
                id: "p3",
                user: MoodUser(id: "1", name: "Alex", username: "alex_active", avatarImageName: nil, avatarColorHex: "FF6B6B", currentMoodEmoji: "😊", currentMoodText: "Happy", currentMoodColorHex: "38B2AC"),
                timeAgo: "5 hrs ago",
                postGradientStartHex: "ED64A6",
                postGradientEndHex: "ECC94B",
                quoteText: "Motion creates emotion.",
                caption: "Morning run cleared my head. Endorphins are flowing! Highly recommend starting your day active! 🏃‍♂️☀️",
                likesCount: 42,
                commentsCount: 8,
                isLiked: false,
                isBookmarked: true
            ),
            FeedPost(
                id: "p4",
                user: MoodUser(id: "4", name: "Chloe", username: "chloe_shine", avatarImageName: nil, avatarColorHex: "FAB005", currentMoodEmoji: "🤩", currentMoodText: "Excited", currentMoodColorHex: "ED64A6"),
                timeAgo: "6 hrs ago",
                postGradientStartHex: "ED64A6",
                postGradientEndHex: "FEFCBF",
                quoteText: "Celebrate the tiny wins.",
                caption: "We launched our beta today! Feeling incredibly excited and grateful for the team's effort! 🚀🎉🙌",
                likesCount: 56,
                commentsCount: 12,
                isLiked: false,
                isBookmarked: false
            ),
            FeedPost(
                id: "p5",
                user: MoodUser(id: "5", name: "Marcus", username: "marcus_mind", avatarImageName: nil, avatarColorHex: "12B886", currentMoodEmoji: "🧠", currentMoodText: "Mindful", currentMoodColorHex: "805AD5"),
                timeAgo: "8 hrs ago",
                postGradientStartHex: "12B886",
                postGradientEndHex: "38B2AC",
                quoteText: "Be here now.",
                caption: "Enjoyed a quiet matcha latte. Mindful sipping: focusing on the warmth, the taste, and the silence. 🍵🧘‍♂️",
                likesCount: 31,
                commentsCount: 4,
                isLiked: false,
                isBookmarked: false
            ),
            FeedPost(
                id: "p6",
                user: MoodUser(id: "2", name: "Emma", username: "emma_zen", avatarImageName: nil, avatarColorHex: "4DABF7", currentMoodEmoji: "😌", currentMoodText: "Calm", currentMoodColorHex: "4A5568"),
                timeAgo: "1 day ago",
                postGradientStartHex: "805AD5",
                postGradientEndHex: "B7791F",
                quoteText: "Peace is not the absence of trouble, but the presence of grace.",
                caption: "Grateful for a quiet Sunday evening. Reflected on what brought joy this week. What are you grateful for? ❤️",
                likesCount: 48,
                commentsCount: 9,
                isLiked: false,
                isBookmarked: false
            ),
            FeedPost(
                id: "p7",
                user: MoodUser(id: "1", name: "Alex", username: "alex_active", avatarImageName: nil, avatarColorHex: "FF6B6B", currentMoodEmoji: "😊", currentMoodText: "Happy", currentMoodColorHex: "38B2AC"),
                timeAgo: "1 day ago",
                postGradientStartHex: "F56565",
                postGradientEndHex: "ED64A6",
                quoteText: "Joy is what happens when we allow ourselves to recognize how good things are.",
                caption: "Epic sunset view from the peak. Captured the perfect warm pink hues. 🌄🏔️",
                likesCount: 65,
                commentsCount: 11,
                isLiked: true,
                isBookmarked: true
            ),
            FeedPost(
                id: "p8",
                user: MoodUser(id: "5", name: "Marcus", username: "marcus_mind", avatarImageName: nil, avatarColorHex: "12B886", currentMoodEmoji: "🧠", currentMoodText: "Mindful", currentMoodColorHex: "805AD5"),
                timeAgo: "2 days ago",
                postGradientStartHex: "4A5568",
                postGradientEndHex: "718096",
                quoteText: "Quiet the mind and the soul will speak.",
                caption: "Ten minutes of focused breathing before checking emails. It completely shifts my response patterns. Try it!",
                likesCount: 19,
                commentsCount: 2,
                isLiked: false,
                isBookmarked: false
            ),
            FeedPost(
                id: "p9",
                user: MoodUser(id: "3", name: "Daniel", username: "daniel_sleeps", avatarImageName: nil, avatarColorHex: "BE4BDF", currentMoodEmoji: "😴", currentMoodText: "Sleepy", currentMoodColorHex: "667EEA"),
                timeAgo: "2 days ago",
                postGradientStartHex: "000000",
                postGradientEndHex: "2D3748",
                quoteText: "Sleep is the best meditation.",
                caption: "Rain tapping on the window pane. Safe to say I'm sleeping in late tomorrow. Rainy night relaxation. 🌧️🕯️",
                likesCount: 29,
                commentsCount: 5,
                isLiked: false,
                isBookmarked: false
            ),
            FeedPost(
                id: "p10",
                user: MoodUser(id: "4", name: "Chloe", username: "chloe_shine", avatarImageName: nil, avatarColorHex: "FAB005", currentMoodEmoji: "🤩", currentMoodText: "Excited", currentMoodColorHex: "ED64A6"),
                timeAgo: "3 days ago",
                postGradientStartHex: "F6AD55",
                postGradientEndHex: "D69E2E",
                quoteText: "Energy is contagious.",
                caption: "Spent the weekend catching up with old high school friends! My battery is 100% full. 😄💃✨",
                likesCount: 51,
                commentsCount: 14,
                isLiked: false,
                isBookmarked: false
            )
        ]
    }
}
