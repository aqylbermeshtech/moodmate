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
            VStack(spacing: AppSpacing.xl) {
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("DAILY CHECK-IN")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(Color.theme.secondaryText)
                            .tracking(1.5)

                        Text("How are you feeling today?")
                            .font(.title3.weight(.medium))
                            .foregroundStyle(Color.theme.primaryText)
                    }
                    Spacer()
                }

                HStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(Color.theme.secondaryBackground)
                            .frame(width: 80, height: 80)

                        Text(mood?.emoji ?? "💭")
                            .font(.system(size: 46))
                            .scaleEffect(mood != nil ? 1.05 : 1.0)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        if let mood {
                            Text(mood.text)
                                .font(.title3.weight(.medium))
                                .foregroundStyle(Color.theme.primaryText)

                            Text("Mood registered")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(Color.theme.secondaryText)
                        } else {
                            Text("No mood selected")
                                .font(.body.weight(.medium))
                                .foregroundStyle(Color.theme.secondaryText)

                            Text("Tap to check in")
                                .font(.subheadline)
                                .foregroundStyle(Color.theme.tertiaryText)
                        }
                    }

                    Spacer()
                }

                HStack {
                    Spacer()
                    HStack(spacing: 6) {
                        Text(mood != nil ? "Update Mood" : "Choose Today's Mood")
                            .font(.subheadline.weight(.medium))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .bold))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .foregroundStyle(Color.theme.accent)
                }
            }
            .padding(20)
            .background {
                if let hex = mood?.colorHex {
                    Color.theme.surface
                } else {
                    Color.theme.cardBackground
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                    .stroke(Color.theme.border, lineWidth: 0.5)
            )
            .shadow(color: Color.theme.shadow, radius: AppShadow.radius, y: AppShadow.y)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

#Preview {
    let vm = HomeViewModel()
    return VStack(spacing: 20) {
        MoodCard(viewModel: vm)
    }
    .padding()
    .background(Color.teal.opacity(0.1))
}
