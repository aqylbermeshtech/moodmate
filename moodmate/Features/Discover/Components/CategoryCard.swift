//
//  CategoryCard.swift
//  moodmate
//
//  Created by Nurtore on 26.07.2026.
//

import SwiftUI

struct CategoryCard: View {
    let category: DiscoverCategory
    let isSelected: Bool
    var onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hex: category.gradientStartHex),
                                    Color(hex: category.gradientEndHex)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 56, height: 56)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(isSelected ? Color.white.opacity(0.5) : Color.clear, lineWidth: 2)
                        )
                        .shadow(
                            color: isSelected
                                ? Color(hex: category.gradientStartHex).opacity(0.4)
                                : Color.black.opacity(0.06),
                            radius: isSelected ? 10 : 6,
                            x: 0,
                            y: 4
                        )
                    
                    Image(systemName: category.iconName)
                        .font(.system(size: 22, weight: .medium))
                        .foregroundStyle(.white)
                }
                
                Text(category.name)
                    .font(.system(size: 11, weight: isSelected ? .bold : .semibold, design: .rounded))
                    .foregroundStyle(isSelected ? .primary : .secondary)
                    .lineLimit(1)
            }
            .frame(width: 76)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

#Preview {
    HStack(spacing: 12) {
        CategoryCard(
            category: DiscoverCategory(
                id: "1", name: "Photography", iconName: "camera.fill",
                gradientStartHex: "667EEA", gradientEndHex: "764BA2"
            ),
            isSelected: false,
            onTap: {}
        )
        CategoryCard(
            category: DiscoverCategory(
                id: "2", name: "Travel", iconName: "airplane",
                gradientStartHex: "F093FB", gradientEndHex: "F5576C"
            ),
            isSelected: true,
            onTap: {}
        )
    }
    .padding()
}
