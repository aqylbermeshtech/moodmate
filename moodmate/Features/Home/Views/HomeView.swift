//
//  HomeView.swift
//  moodmate
//
//  Created by Nurtore on 22.07.2026.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var selectedTab: HomeTab = .home
    @State private var showSignOutDialog = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Shared premium background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.teal.opacity(0.18), Color.purple.opacity(0.12)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Screen content switcher
            Group {
                switch selectedTab {
                case .home:
                    homeFeedView
                case .discover:
                    TabPlaceholderView(title: "Discover", systemImage: "sparkles") {}
                case .add:
                    TabPlaceholderView(title: "Log a Moment", systemImage: "plus.circle") {}
                case .insights:
                    TabPlaceholderView(title: "Insights & Analytics", systemImage: "chart.bar.xaxis") {}
                case .profile:
                    TabPlaceholderView(title: "Your Profile", systemImage: "person.crop.circle") {
                        showSignOutDialog = true
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Overlaid Glassmorphic Bottom Floating Tab Bar
            BottomNavigationBar(selectedTab: $selectedTab) {
                viewModel.showMoodPickerSheet = true
            }
            .padding(.bottom, 8)
        }
        .sheet(isPresented: $viewModel.showMoodPickerSheet) {
            MoodPickerSheet(viewModel: viewModel)
                .presentationDetents([.height(380)])
                .presentationDragIndicator(.hidden)
        }
        .confirmationDialog("Are you sure you want to sign out?", isPresented: $showSignOutDialog, titleVisibility: .visible) {
            Button("Sign Out", role: .destructive) {
                viewModel.signOut()
            }
            Button("Cancel", role: .cancel) {}
        }
    }
    
    // MARK: - Home Feed Layout
    private var homeFeedView: some View {
        ScrollView {
            LazyVStack(spacing: 24) {
                // Header (Greeting, Date, Avatar)
                GreetingHeader(viewModel: viewModel) {
                    showSignOutDialog = true
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                // Primary Action: Daily check-in card
                MoodCard(viewModel: viewModel)
                    .padding(.horizontal, 20)
                
                // Horizontal Stories: Friends Today
                friendsStoriesSection
                
                // Vertical Feed: Today's Feed
                feedSection
            }
            .padding(.bottom, 100) // Padding for tab bar overlay
        }
        .scrollIndicators(.hidden)
    }
    
    // MARK: - Friends Section
    private var friendsStoriesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Friends Today")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
                .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(viewModel.friends) { friend in
                        FriendAvatar(user: friend) {
                            if let emoji = friend.currentMoodEmoji, let text = friend.currentMoodText {
                                viewModel.selectMood(
                                    emoji: emoji,
                                    text: "\(friend.name) is \(text)",
                                    colorHex: friend.currentMoodColorHex ?? "38B2AC"
                                )
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    // MARK: - Today's Feed
    private var feedSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Today's Feed")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
                .padding(.horizontal, 20)
            
            LazyVStack(spacing: 24) {
                ForEach(viewModel.feedPosts) { post in
                    FeedCard(
                        post: post,
                        onLike: { viewModel.toggleLike(for: post) },
                        onBookmark: { viewModel.toggleBookmark(for: post) },
                        onComment: {
                            viewModel.selectMood(
                                emoji: "💬",
                                text: "Commented on @\(post.user.username)'s post",
                                colorHex: "38B2AC"
                            )
                        }
                    )
                }
            }
        }
    }
}

#Preview {
    HomeView()
}
