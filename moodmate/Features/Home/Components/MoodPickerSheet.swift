//
//  MoodPickerSheet.swift
//  moodmate
//

import SwiftUI

struct MoodPickerSheet: View {
    @ObservedObject var viewModel: HomeViewModel

    var body: some View {
        VStack(spacing: 24) {
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.theme.secondaryText.opacity(0.4))
                .frame(width: 36, height: 5)
                .padding(.top, 12)

            VStack(spacing: 6) {
                Text("How are you feeling today?")
                    .font(.xScreenTitle)
                    .foregroundStyle(Color.theme.primaryText)
                Text("Select a mood to update your daily check-in")
                    .font(.xTrendingMeta)
                    .foregroundStyle(Color.theme.secondaryText)
            }
            .padding(.top, 6)

            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 100, maximum: 120), spacing: 16)],
                spacing: 20
            ) {
                ForEach(viewModel.moodOptions) { option in
                    let isSelected = viewModel.selectedMood?.emoji == option.emoji

                    Button {
                        viewModel.selectMood(
                            emoji: option.emoji,
                            text: option.text,
                            colorHex: option.colorHex
                        )
                        viewModel.showMoodPickerSheet = false
                    } label: {
                        VStack(spacing: 12) {
                            Text(option.emoji).font(.system(size: 40))
                            Text(option.text)
                                .font(.xDisplayName)
                                .foregroundStyle(Color.theme.primaryText)
                        }
                        .frame(width: 100, height: 100)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(isSelected ? Color.theme.accent.opacity(0.15) : Color.theme.secondaryBackground)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(
                                    isSelected ? Color.theme.accent : Color.theme.divider,
                                    lineWidth: isSelected ? 2 : 1
                                )
                        )
                    }
                    .buttonStyle(XPressableStyle())
                }
            }
            .padding(.horizontal, 24)

            Spacer()
        }
        .background(Color.theme.primaryBackground)
    }
}

#Preview {
    MoodPickerSheet(viewModel: HomeViewModel())
}
