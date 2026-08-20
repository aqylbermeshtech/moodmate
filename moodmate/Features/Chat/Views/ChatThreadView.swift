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
                    .padding(.bottom, 80)
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
                        .foregroundStyle(Color.theme.primaryText)
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
                            .font(.xDisplayName)
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
                .font(.xSectionHeader)
                .foregroundStyle(Color.theme.primaryText)
        }
    }

    private var messageInputBar: some View {
        HStack(spacing: 12) {
            TextField("Start a new message", text: $draftText)
                .font(.xDMBody)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color.theme.secondaryBackground)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(Color.theme.divider, lineWidth: 1)
                )
                .foregroundStyle(Color.theme.primaryText)

            Button {} label: {
                ZStack {
                    Circle()
                        .fill(draftText.isEmpty ? Color.theme.accent.opacity(0.4) : Color.theme.accent)
                        .frame(width: 36, height: 36)

                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(.white)
                }
            }
            .disabled(draftText.isEmpty)
            .buttonStyle(XPressableStyle())
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            Color.theme.primaryBackground
                .overlay(alignment: .top) {
                    Rectangle().fill(Color.theme.divider).frame(height: 0.5)
                }
        )
    }
}

#Preview {
    NavigationStack {
        ChatThreadView(userId: "1")
    }
}
