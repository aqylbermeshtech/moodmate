//
//  ChatListView.swift
//  moodmate
//

import SwiftUI

struct ChatListView: View {
    @StateObject private var viewModel = ChatListViewModel()
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        ZStack {
            Color.theme.primaryBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Text("Messages")
                        .font(.title.weight(.medium))
                        .foregroundStyle(Color.theme.primaryText)

                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 12)

                if viewModel.conversations.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(viewModel.conversations) { conversation in
                                Button {
                                    router.push(.chatThread(userId: conversation.participant.id))
                                } label: {
                                    ConversationRow(conversation: conversation)
                                }
                                .buttonStyle(.plain)
                                .padding(.horizontal, 20)

                                Divider()
                                    .overlay(Color.theme.divider)
                                    .padding(.leading, 84)
                            }
                        }
                        .padding(.bottom, 110)
                    }
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 32))
                .foregroundStyle(Color.theme.secondaryText)
            Text("No conversations yet")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.theme.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }
}

#Preview {
    NavigationStack {
        ChatListView()
    }
    .environmentObject(AppRouter.shared)
}
