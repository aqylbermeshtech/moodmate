import SwiftUI

struct HomeView: View {

    // MARK: - Dependencies

    @ObservedObject var viewModel: HomeViewModel
    @EnvironmentObject private var router: AppRouter

    @State private var feedFilter: Int = 0

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            // X-style top bar
            GreetingHeader(viewModel: viewModel, onProfileTap: { router.switchTab(.profile) })
                .padding(.horizontal, 16)
                .padding(.vertical, 8)

            // Divider below header
            Rectangle().fill(Color.theme.divider).frame(height: 0.5)

            // Feed filter tabs
            XFeedFilter(selection: $feedFilter)

            // Timeline with scroll tracking
            ScrollView {
                LazyVStack(spacing: 0) {
                    // Mood check-in row (compact)
                    MoodCard(viewModel: viewModel)

                    Divider().background(Color.theme.divider)

                    // Friends row
                    if !viewModel.friends.isEmpty {
                        friendsStoriesSection
                        Divider().background(Color.theme.divider)
                    }

                    // Feed posts
                    ForEach(viewModel.feed.posts) { post in
                        PostCardView(
                            post: post,
                            style: .feed,
                            onLike:     { viewModel.feed.toggleLike(for: post) },
                            onBookmark: { viewModel.feed.toggleBookmark(for: post) },
                            onComment: {
                                router.push(.postDetail(postId: post.id))
                            }
                        )
                    }

                    // Bottom spacer so content doesn't hide behind tab bar
                    Spacer()
                        .frame(height: 100)
                }
            }
            .onScrollGeometryChange(for: CGFloat.self) { geo in
                geo.contentOffset.y
            } action: { _, newOffset in
                router.updateTabBarVisibility(scrollOffset: newOffset)
            }
            .scrollIndicators(.hidden)
            .refreshable {
                // Pull to refresh
            }
        }
        .background {
            Color.theme.primaryBackground.ignoresSafeArea()
        }
        .navigationBarHidden(true)
        .task {
            viewModel.onAppear()
        }
        .errorAlert(Binding(
            get: { viewModel.feed.errorMessage },
            set: { if $0 == nil { viewModel.feed.clearError() } }
        ))
        .sheet(isPresented: $viewModel.showMoodPickerSheet) {
            MoodPickerSheet(viewModel: viewModel)
                .presentationDetents([.height(380)])
                .presentationDragIndicator(.hidden)
        }
    }

    // MARK: - Friends Stories Section

    private var friendsStoriesSection: some View {
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
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        HomeView(viewModel: HomeViewModel())
    }
    .environmentObject(AppRouter.shared)
}
