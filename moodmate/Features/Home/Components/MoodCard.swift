//
//  MoodCard.swift
//  moodmate
//
//  Created by Nurtore on 22.07.2026.
//

import SwiftUI

struct MoodCard: View {
    @ObservedObject var viewModel: HomeViewModel
    
    var body: some View {
        Button(action: {
            viewModel.showMoodPickerSheet = true
        }) {
            VStack(spacing: 20) {
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("DAILY CHECK-IN")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(viewModel.selectedMoodEmoji != nil ? .white.opacity(0.8) : .teal)
                            .tracking(1.5)
                        
                        Text("How are you feeling today?")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundStyle(viewModel.selectedMoodEmoji != nil ? .white : .primary)
                    }
                    Spacer()
                }
                
                HStack(spacing: 20) {
                    // Large Mood Emoji with subtle animation
                    ZStack {
                        Circle()
                            .fill(viewModel.selectedMoodEmoji != nil ? .white.opacity(0.2) : Color.teal.opacity(0.08))
                            .frame(width: 80, height: 80)
                        
                        Text(viewModel.selectedMoodEmoji ?? "💭")
                            .font(.system(size: 46))
                            .scaleEffect(viewModel.selectedMoodEmoji != nil ? 1.05 : 1.0)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        if let moodText = viewModel.selectedMoodText {
                            Text(moodText)
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                            
                            Text("Mood registered")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(.white.opacity(0.8))
                        } else {
                            Text("No mood selected")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundStyle(.secondary)
                            
                            Text("Tap to check in")
                                .font(.system(size: 13))
                                .foregroundStyle(.secondary.opacity(0.8))
                        }
                    }
                    
                    Spacer()
                }
                
                // CTA Action button inside the card
                HStack {
                    Spacer()
                    HStack(spacing: 6) {
                        Text(viewModel.selectedMoodEmoji != nil ? "Update Mood" : "Choose Today's Mood")
                            .font(.system(size: 14, weight: .bold))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .bold))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(viewModel.selectedMoodEmoji != nil ? .white : Color.teal)
                    .foregroundStyle(viewModel.selectedMoodEmoji != nil ? Color(hex: viewModel.selectedMoodColorHex ?? "38B2AC") : .white)
                    .clipShape(Capsule())
                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                }
            }
            .padding(20)
            .background {
                if let hex = viewModel.selectedMoodColorHex {
                    // Vibrant gradient based on selected mood
                    LinearGradient(
                        colors: [Color(hex: hex), Color(hex: hex).opacity(0.75)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                } else {
                    // Standard background matching auth cards
                    Color(.systemBackground).opacity(0.78)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(
                        viewModel.selectedMoodEmoji != nil 
                            ? Color.white.opacity(0.2) 
                            : Color.secondary.opacity(0.12),
                        lineWidth: 1
                    )
            )
            .shadow(
                color: viewModel.selectedMoodEmoji != nil 
                    ? Color(hex: viewModel.selectedMoodColorHex!).opacity(0.3) 
                    : .black.opacity(0.04),
                radius: 12,
                x: 0,
                y: 8
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

#Preview {
    VStack(spacing: 20) {
        MoodCard(viewModel: HomeViewModel())
        
        let selectedVm = HomeViewModel()
        let _ = selectedVm.selectMood(emoji: "😊", text: "Happy Today", colorHex: "38B2AC")
        MoodCard(viewModel: selectedVm)
    }
    .padding()
    .background(Color.teal.opacity(0.1))
}
