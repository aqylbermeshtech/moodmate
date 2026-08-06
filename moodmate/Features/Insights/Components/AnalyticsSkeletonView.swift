//
//  AnalyticsSkeletonView.swift
//  moodmate
//
//  Created by Nurtore on 26.07.2026.
//

import SwiftUI

struct AnalyticsSkeletonView: View {
    @State private var isAnimating = false
    
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 8) {
                ForEach(0..<4) { _ in
                    Capsule()
                        .fill(Color.primary.opacity(isAnimating ? 0.12 : 0.04))
                        .frame(width: 70, height: 32)
                }
            }
            .padding(.horizontal, 20)
            
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(0..<6) { _ in
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color.primary.opacity(isAnimating ? 0.12 : 0.04))
                        .frame(height: 90)
                }
            }
            .padding(.horizontal, 20)

            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.primary.opacity(isAnimating ? 0.12 : 0.04))
                .frame(height: 240)
                .padding(.horizontal, 20)

            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.primary.opacity(isAnimating ? 0.12 : 0.04))
                .frame(height: 280)
                .padding(.horizontal, 20)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
}
