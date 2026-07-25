//
//  TopMoodsView.swift
//  moodmate
//
//  Created by Nurtore on 26.07.2026.
//

import SwiftUI

struct TopMoodsView: View {
    let topMoods: [TopMoodItem]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            VStack(alignment: .leading, spacing: 4) {
                Text("Top Moods Ranking")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                
                Text("Your most frequently logged emotions")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)
            }
            
            // List of ranked mood bars
            VStack(spacing: 12) {
                ForEach(topMoods) { item in
                    TopMoodRow(item: item)
                }
            }
        }
        .padding(18)
        .background {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [.white.opacity(0.4), .white.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        }
        .shadow(color: .black.opacity(0.04), radius: 10, x: 0, y: 5)
        .padding(.horizontal, 20)
    }
}

private struct TopMoodRow: View {
    let item: TopMoodItem
    
    var body: some View {
        VStack(spacing: 6) {
            HStack {
                Text("#\(item.rank)")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(.secondary)
                    .frame(width: 24, alignment: .leading)
                
                Text(item.moodEmoji)
                    .font(.system(size: 18))
                
                Text(item.moodName)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                
                Spacer()
                
                Text("\(item.postCount) posts")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)
                
                Text("\(String(format: "%.0f", item.percentage))%")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(hex: item.colorHex))
                    .frame(width: 44, alignment: .trailing)
            }
            
            // Progress Bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.primary.opacity(0.06))
                        .frame(height: 7)
                    
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: item.colorHex), Color(hex: item.colorHex).opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * CGFloat(min(1.0, item.percentage / 40.0)), height: 7)
                }
            }
            .frame(height: 7)
        }
        .padding(10)
        .background {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.primary.opacity(0.02))
        }
    }
}
