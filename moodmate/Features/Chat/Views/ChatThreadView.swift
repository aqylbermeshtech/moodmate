//
//  ChatThreadView.swift
//  moodmate
//

import SwiftUI

struct ChatThreadView: View {
    @StateObject private var viewModel: ChatThreadViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var draftText = ""

    init(userId: String) {
        _viewModel = StateObject(wrappedValue: ChatThreadViewModel(userId: userId))
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.theme.primaryBackground
                .ignoresSafeArea()

            if viewModel.participant != nil {
                ScrollView {
                    LazyVStack(spacing: 14) {
                        ForEach(viewModel.messages) { message in
                            MessageBubble(message: message)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 24)
                }
                .scrollDismissesKeyboard(.interactively)

                messageInputBar
            } else {
                notFoundView
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                }
                .accessibilityLabel("Back")
            }
            ToolbarItem(placement: .principal) {
                if let participant = viewModel.participant {
                    HStack(spacing: 8) {
                        AvatarView(
                            imageData: participant.avatarImageData,
                            name: participant.name,
                            colorHex: participant.avatarColorHex,
                            size: 28,
                            showBorder: false
                        )
                        Text(participant.name)
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color.theme.primaryText)
                    }
                }
            }
        }
    }

    private var notFoundView: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.crop.circle.badge.questionmark")
                .font(.system(size: 40))
                .foregroundStyle(Color.theme.secondaryText)
            Text("Conversation Not Found")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(Color.theme.primaryText)
        }
    }

    private var messageInputBar: some View {
        HStack(spacing: 12) {
            TextField("Message...", text: $draftText)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color.theme.surface)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(Color.theme.border, lineWidth: 1)
                )
                .foregroundStyle(Color.theme.primaryText)

            Button {} label: {
                ZStack {
                    Circle()
                        .fill(draftText.isEmpty ? Color.theme.accent.opacity(0.5) : Color.theme.accent)
                        .frame(width: 38, height: 38)

                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(.white)
                }
            }
            .disabled(draftText.isEmpty)
            .buttonStyle(ScaleButtonStyle())
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.theme.cardBackground)
    }
}

#Preview {
    NavigationStack {
        ChatThreadView(userId: "1")
    }
}
