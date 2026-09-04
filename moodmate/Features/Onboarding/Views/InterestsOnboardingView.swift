//
//  InterestsOnboardingView.swift
//  moodmate
//
//  Shown between sign-in and the app itself, until the user has picked their
//  interests. Saving flips `hasCompletedOnboarding`, which is what
//  `OnboardingGateViewModel` watches to hand over to the tab container.
//

import SwiftUI

struct InterestsOnboardingView: View {
    @StateObject private var viewModel = InterestsOnboardingViewModel()

    var body: some View {
        ZStack {
            Color.theme.primaryBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                header

                ScrollView {
                    InterestPickerGrid(
                        selectedIds: viewModel.selectedIds,
                        onToggle: { interest in
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                viewModel.toggle(interest)
                            }
                        }
                    )
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 24)
                }
                .scrollIndicators(.hidden)

                footer
            }
        }
        .errorAlert($viewModel.errorMessage)
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "leaf.circle.fill")
                    .font(.system(size: 26))
                    .foregroundStyle(Color.theme.accent)

                Spacer()

                Button("Sign out") {
                    viewModel.signOut()
                }
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.theme.secondaryText)
            }

            Text(viewModel.greeting)
                .font(.system(size: 26, weight: .bold))
                .foregroundStyle(Color.theme.primaryText)
                .fixedSize(horizontal: false, vertical: true)

            Text("Pick at least \(viewModel.minimumSelection). We'll use these to shape what MoodMate shows you — you can change them any time from your profile.")
                .font(.xPostBody)
                .foregroundStyle(Color.theme.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 16)
    }

    // MARK: - Footer

    private var footer: some View {
        VStack(spacing: 10) {
            Text(viewModel.selectionHint)
                .font(.xTrendingMeta)
                .foregroundStyle(Color.theme.secondaryText)
                .contentTransition(.numericText())

            Button {
                Task { await viewModel.save() }
            } label: {
                ZStack {
                    if viewModel.isSaving {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Continue")
                            .font(.xButton)
                    }
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background {
                    Capsule().fill(
                        viewModel.canContinue ? Color.theme.accent : Color.theme.accent.opacity(0.35)
                    )
                }
            }
            .buttonStyle(XPressableStyle())
            .disabled(!viewModel.canContinue)
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 8)
        .background(
            Color.theme.primaryBackground
                .overlay(alignment: .top) {
                    Rectangle().fill(Color.theme.divider).frame(height: 0.5)
                }
                .ignoresSafeArea(edges: .bottom)
        )
    }
}

#Preview {
    InterestsOnboardingView()
}
