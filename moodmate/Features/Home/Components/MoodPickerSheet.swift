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
                .fill(Color.secondary.opacity(0.3))
                .frame(width: 36, height: 5)
                .padding(.top, 12)

            VStack(spacing: 6) {
                Text("How are you feeling today?")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.theme.primaryText)
                Text("Select a mood to update your daily check-in")
                    .font(.system(size: 14))
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
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundStyle(Color.theme.primaryText)
                        }
                        .frame(width: 100, height: 100)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(
                                    isSelected
                                        ? Color.adaptiveMoodColor(hex: option.colorHex).opacity(0.2)
                                        : Color.theme.surface
                                )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(
                                    isSelected ? Color(hex: option.colorHex) : Color.theme.border,
                                    lineWidth: 2
                                )
                        )
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
            }
            .padding(.horizontal, 24)

            Spacer()
        }
    }
}

#Preview {
    MoodPickerSheet(viewModel: HomeViewModel())
}
