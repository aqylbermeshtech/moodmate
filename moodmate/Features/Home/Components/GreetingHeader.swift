//
//  GreetingHeader.swift
//  moodmate
//

import SwiftUI

struct GreetingHeader: View {
    @ObservedObject var viewModel: HomeViewModel
    var onProfileTap: () -> Void

    var body: some View {
        ZStack {
            appMark
                .frame(maxWidth: .infinity)

            HStack {
                Button(action: onProfileTap) {
                    AvatarView(
                        imageData: viewModel.currentUserAvatarData,
                        name: viewModel.currentUserDisplayName,
                        colorHex: viewModel.currentUserAvatarColorHex,
                        size: 44,
                        showBorder: true
                    )
                }
                .buttonStyle(ScaleButtonStyle())
                .padding(.leading, -8)

                Spacer()
            }
        }
    }

    private var appMark: some View {
        Image(systemName: "leaf.circle.fill")
            .font(.system(size: 32, weight: .regular))
            .foregroundStyle(Color.theme.accent)
            .accessibilityLabel("MoodMate")
    }
}

// MARK: - Scale Button Style

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.94 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

#Preview {
    ZStack {
        Color.theme.primaryBackground.ignoresSafeArea()
        GreetingHeader(viewModel: HomeViewModel(), onProfileTap: {})
            .padding()
    }
}
