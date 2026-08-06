import SwiftUI

struct HomeView: View {

    // MARK: - Dependencies

    @ObservedObject var viewModel: HomeViewModel

    var onCreatePost: () -> Void
    var onNavigateToProfile: () -> Void

    // MARK: - Body

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 24) {
                GreetingHeader(viewModel: viewModel, onProfileTap: onNavigateToProfile)
                    .padding(.horizontal, 20)
                    .padding(.top, 16)

                MoodCard(viewModel: viewModel)
                    .padding(.horizontal, 20)

                friendsStoriesSection

                feedSection
            }
            .padding(.bottom, 32)
        }
        .scrollIndicators(.hidden)
        .background {
            Color.theme.backgroundGradient.ignoresSafeArea()
        }
        .navigationBarHidden(true)
        .task {
            viewModel.onAppear()
        }
        .alert(
            "Something went wrong",
            isPresented: Binding(
                get: { viewModel.feed.errorMessage != nil },
                set: { if !$0 { viewModel.feed.clearError() } }
            )
        ) {
            Button("OK") { viewModel.feed.clearError() }
        } message: {
            Text(viewModel.feed.errorMessage ?? "")
        }
        .sheet(isPresented: $viewModel.showMoodPickerSheet) {
            MoodPickerSheet(viewModel: viewModel)
                .presentationDetents([.height(380)])
                .presentationDragIndicator(.hidden)
        }
    }

    // MARK: - Friends Stories Section

    private var friendsStoriesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Friends Today")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(Color.theme.primaryText)
                .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(viewModel.friends) { friend in
                        FriendAvatar(user: friend) {
                            if let emoji = friend.currentMoodEmoji,
                               let text  = friend.currentMoodText {
                                viewModel.selectMood(
                                    emoji: emoji,
                                    text: "\(friend.name) is \(text)",
                                    colorHex: friend.currentMoodColorHex ?? "38B2AC"
                                )
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }

    // MARK: - Feed Section

    private var feedSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Today's Feed")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(Color.theme.primaryText)
                .padding(.horizontal, 20)

            LazyVStack(spacing: 24) {
                ForEach(viewModel.feed.posts) { post in
                    PostCardView(
                        post: post,
                        style: .feed,
                        onLike:     { viewModel.feed.toggleLike(for: post) },
                        onBookmark: { viewModel.feed.toggleBookmark(for: post) },
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

// MARK: - Preview

#Preview {
    NavigationStack {
        HomeView(
            viewModel: HomeViewModel(),
            onCreatePost: {},
            onNavigateToProfile: {}
        )
    }
}
