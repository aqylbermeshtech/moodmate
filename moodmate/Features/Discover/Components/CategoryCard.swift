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
                                .stroke(isSelected ? Color.theme.accent : Color.clear, lineWidth: 2)
                        )

                    Image(systemName: category.iconName)
                        .font(.system(size: 22, weight: .medium))
                        .foregroundStyle(.white)
                }

                Text(category.name)
                    .font(.system(size: 11, weight: isSelected ? .bold : .semibold))
                    .foregroundStyle(isSelected ? Color.theme.primaryText : Color.theme.secondaryText)
                    .lineLimit(1)
            }
            .frame(width: 76)
        }
        .buttonStyle(XPressableStyle())
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
    .background(Color.theme.primaryBackground)
}
