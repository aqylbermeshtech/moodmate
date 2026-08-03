//
//  MoodCard.swift
//  moodmate
//

import SwiftUI

struct MoodCard: View {
    @ObservedObject var viewModel: HomeViewModel

    // Convenience local alias so the body stays readable.
    private var mood: SelectedMood? { viewModel.selectedMood }

    var body: some View {
        Button(action: {
            viewModel.showMoodPickerSheet = true
        }) {
            VStack(spacing: 20) {
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("DAILY CHECK-IN")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(mood != nil ? .white.opacity(0.8) : .teal)
                            .tracking(1.5)

                        Text("How are you feeling today?")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundStyle(mood != nil ? .white : Color.theme.primaryText)
                    }
                    Spacer()
                }

                HStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(mood != nil ? .white.opacity(0.2) : Color.theme.accent.opacity(0.08))
                            .frame(width: 80, height: 80)

                        Text(mood?.emoji ?? "💭")
                            .font(.system(size: 46))
                            .scaleEffect(mood != nil ? 1.05 : 1.0)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        if let mood {
                            Text(mood.text)
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)

                            Text("Mood registered")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(.white.opacity(0.8))
                        } else {
                            Text("No mood selected")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundStyle(Color.theme.secondaryText)

                            Text("Tap to check in")
                                .font(.system(size: 13))
                                .foregroundStyle(Color.theme.tertiaryText)
                        }
                    }

                    Spacer()
                }

                HStack {
                    Spacer()
                    HStack(spacing: 6) {
                        Text(mood != nil ? "Update Mood" : "Choose Today's Mood")
                            .font(.system(size: 14, weight: .bold))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .bold))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(mood != nil ? .white : Color.teal)
                    .foregroundStyle(mood != nil ? Color(hex: mood?.colorHex ?? "38B2AC") : .white)
                    .clipShape(Capsule())
                    .shadow(color: Color.theme.shadow, radius: 4, x: 0, y: 2)
                }
            }
            .padding(20)
            .background {
                if let hex = mood?.colorHex {
                    LinearGradient(
                        colors: [
                            Color.adaptiveMoodColor(hex: hex),
                            Color.adaptiveMoodColor(hex: hex, darkOpacityMultiplier: 0.75)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                } else {
                    Color.theme.cardBackground
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(
                        mood != nil ? Color.white.opacity(0.2) : Color.theme.border,
                        lineWidth: 1
                    )
            )
            .shadow(
                color: mood.map { Color(hex: $0.colorHex).opacity(0.3) } ?? Color.theme.shadow,
                radius: 12, x: 0, y: 8
            )
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
