//
//  MoodCard.swift
//  moodmate
//

import SwiftUI

struct MoodCard: View {
    @ObservedObject var viewModel: HomeViewModel
    private var mood: SelectedMood? { viewModel.selectedMood }

    var body: some View {
        Button(action: {
            viewModel.showMoodPickerSheet = true
        }) {
            HStack(alignment: .center, spacing: 12) {
                // Mood emoji
                Text(mood?.emoji ?? "💭")
                    .font(.system(size: 28))

                VStack(alignment: .leading, spacing: 2) {
                    if let mood {
                        Text("Feeling \(mood.text)")
                            .font(.xDisplayName)
                            .foregroundStyle(Color.theme.primaryText)

                        Text("Tap to update · Daily check-in")
                            .font(.xTrendingMeta)
                            .foregroundStyle(Color.theme.secondaryText)
                    } else {
                        Text("How are you feeling?")
                            .font(.xDisplayName)
                            .foregroundStyle(Color.theme.primaryText)

                        Text("Tap to check in today")
                            .font(.xTrendingMeta)
                            .foregroundStyle(Color.theme.secondaryText)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.theme.secondaryText)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
        .buttonStyle(XPressableStyle())
        .background(Color.theme.primaryBackground)
    }
}

#Preview {
    let vm = HomeViewModel()
    return VStack(spacing: 0) {
        MoodCard(viewModel: vm)
        Divider()
    }
    .background(Color.theme.primaryBackground)
}
