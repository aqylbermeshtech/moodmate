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
                // X-style header
                HStack {
                    Text("Messages")
                        .font(.xScreenTitle)
                        .foregroundStyle(Color.theme.primaryText)

                    Spacer()

                    Image(systemName: "gearshape")
                        .font(.system(size: 20))
                        .foregroundStyle(Color.theme.primaryText)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 12)

                Rectangle().fill(Color.theme.divider).frame(height: 0.5)

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
                                .padding(.horizontal, 16)

                                Rectangle().fill(Color.theme.divider).frame(height: 0.5)
                                    .padding(.leading, 76)
                            }
                        }
                        .padding(.bottom, 110)
                    }
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Spacer()
            Text("Welcome to your inbox!")
                .font(.xScreenTitle)
                .foregroundStyle(Color.theme.primaryText)
            Text("Drop a line, share posts and more with private conversations between you and others.")
                .font(.xPostBody)
                .foregroundStyle(Color.theme.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Button("Write a message") {}
                .font(.xButton)
                .foregroundStyle(.black)
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background(Capsule().fill(Color.theme.primaryText))
                .padding(.top, 8)

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    NavigationStack {
        ChatListView()
    }
    .environmentObject(AppRouter.shared)
}
