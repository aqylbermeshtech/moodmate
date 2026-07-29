//
//  DiscoverLoadingSkeleton.swift
//  moodmate
//
//  Created by Nurtore on 26.07.2026.
//

import SwiftUI

// MARK: - Shimmer Effect Modifier
struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geo in
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0),
                            Color.white.opacity(0.15),
                            Color.white.opacity(0)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geo.size.width * 2)
                    .offset(x: phase * geo.size.width * 2 - geo.size.width)
                }
                .mask(content)
            )
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}

extension View {
    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }
}

// MARK: - Loading Skeleton View
struct DiscoverLoadingSkeleton: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            skeletonPill(height: 44)
                .padding(.horizontal, 20)
            VStack(alignment: .leading, spacing: 10) {
                skeletonPill(width: 120, height: 14)
                    .padding(.horizontal, 20)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(0..<5, id: \.self) { _ in
                            skeletonPill(width: 100, height: 38)
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(0..<6, id: \.self) { _ in
                        VStack(spacing: 8) {
                            skeletonRect(width: 56, height: 56, cornerRadius: 14)
                            skeletonPill(width: 48, height: 10)
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            HStack(alignment: .top, spacing: 12) {
                VStack(spacing: 12) {
                    skeletonRect(height: 220, cornerRadius: 16)
                    skeletonRect(height: 180, cornerRadius: 16)
                    skeletonRect(height: 260, cornerRadius: 16)
                }
                VStack(spacing: 12) {
                    skeletonRect(height: 180, cornerRadius: 16)
                    skeletonRect(height: 240, cornerRadius: 16)
                    skeletonRect(height: 200, cornerRadius: 16)
                }
            }
            .padding(.horizontal, 20)
        }
        .shimmer()
    }
    
    // MARK: - Skeleton Shapes
    
    private func skeletonPill(width: CGFloat? = nil, height: CGFloat = 16) -> some View {
        RoundedRectangle(cornerRadius: height / 2, style: .continuous)
            .fill(Color.theme.secondaryBackground)
            .frame(width: width, height: height)
    }
    
    private func skeletonRect(width: CGFloat? = nil, height: CGFloat = 100, cornerRadius: CGFloat = 12) -> some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(Color.theme.secondaryBackground)
            .frame(width: width, height: height)
    }
}

#Preview {
    ZStack {
        LinearGradient(
            colors: [.teal.opacity(0.18), .purple.opacity(0.12)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        
        ScrollView {
            DiscoverLoadingSkeleton()
                .padding(.top, 20)
        }
    }
}
