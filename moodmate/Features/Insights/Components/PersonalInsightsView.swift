//
//  PersonalInsightsView.swift
//  moodmate
//
//  Created by Nurtore on 26.07.2026.
//

import SwiftUI

struct PersonalInsightsView: View {
    let insights: [PersonalInsight]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text("Personal AI Insights")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                    
                    Image(systemName: "sparkles")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(colors: [.teal, .purple], startPoint: .leading, endPoint: .trailing)
                        )
                }
                
                Text("Smart patterns detected from your mood logs")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)
            }

            VStack(spacing: 10) {
                ForEach(insights) { insight in
                    InsightCard(insight: insight)
                }
            }
        }
        .padding(18)
        .background {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.theme.surface)
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

private struct InsightCard: View {
    let insight: PersonalInsight
    
    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color(hex: insight.accentColorHex).opacity(0.15))
                    .frame(width: 40, height: 40)
                
                Image(systemName: insight.iconName)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color(hex: insight.accentColorHex))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(insight.title)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                
                Text(insight.message)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(.secondary)
                    .lineSpacing(3)
            }
            
            Spacer(minLength: 0)
        }
        .padding(12)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.primary.opacity(0.03))
        }
    }
}
