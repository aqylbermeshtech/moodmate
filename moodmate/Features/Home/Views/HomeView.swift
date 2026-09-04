import SwiftUI

struct HomeView: View {

    // MARK: - Dependencies

    @ObservedObject var viewModel: HomeViewModel
    @EnvironmentObject private var router: AppRouter

    private var feedFilter: Binding<Int> {
        Binding(
            get: { viewModel.feed.selectedFilter.rawValue },
            set: { viewModel.feed.selectedFilter = FeedViewModel.FeedFilter(rawValue: $0) ?? .forYou }
        )
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            GreetingHeader(viewModel: viewModel, onProfileTap: { router.switchTab(.profile) })
                .padding(.horizontal, 16)
                .padding(.vertical, 8)

            Rectangle().fill(Color.theme.divider).frame(height: 0.5)

            XFeedFilter(selection: feedFilter)

            ScrollView {
                LazyVStack(spacing: 0) {
                    if viewModel.feed.visiblePosts.isEmpty {
                        emptyState
                    } else {
                        ForEach(viewModel.feed.visiblePosts) { post in
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
                    }

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
    }

    // MARK: - Empty State

    private var emptyState: some View {
        let isFollowingTab = viewModel.feed.selectedFilter == .following

        return VStack(spacing: 8) {
            Image(systemName: isFollowingTab ? "person.2" : "square.and.pencil")
                .font(.system(size: 32))
                .foregroundStyle(Color.theme.secondaryText)
                .padding(.bottom, 4)

            Text("Nothing here yet")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.theme.primaryText)

            Text(isFollowingTab
                 ? "Posts from people you follow will show up here. Switch to \u{201C}For you\u{201D} to discover more."
                 : "Write your first post, or head to Discover to find people to follow.")
                .font(.system(size: 14))
                .foregroundStyle(Color.theme.secondaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 40)
        .padding(.top, 64)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        HomeView(viewModel: HomeViewModel())
    }
    .environmentObject(AppRouter.shared)
}
