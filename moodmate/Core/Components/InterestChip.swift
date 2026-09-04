//
//  InterestChip.swift
//  moodmate
//
//  One interest, as a chip. Tappable when `onTap` is supplied (the pickers),
//  inert when it isn't (the profile's read-only list).
//

import SwiftUI

struct InterestChip: View {
    let interest: Interest
    var isSelected: Bool = false
    var onTap: (() -> Void)? = nil

    var body: some View {
        if let onTap {
            Button(action: onTap) { chip }
                .buttonStyle(XPressableStyle())
                .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
        } else {
            chip
        }
    }

    private var chip: some View {
        HStack(spacing: 6) {
            Image(systemName: interest.iconName)
                .font(.system(size: 13, weight: .semibold))

            Text(interest.name)
                .font(.system(size: 14, weight: .semibold))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 9)
        .background {
            Capsule().fill(isSelected ? Color.theme.accent : Color.theme.secondaryBackground)
        }
        .foregroundStyle(isSelected ? .white : Color.theme.primaryText)
        .overlay(
            Capsule().stroke(isSelected ? Color.clear : Color.theme.divider, lineWidth: 1)
        )
    }
}

#Preview {
    FlowLayout {
        InterestChip(interest: InterestCatalog.all[0], isSelected: true, onTap: {})
        InterestChip(interest: InterestCatalog.all[1], onTap: {})
        InterestChip(interest: InterestCatalog.all[12])
    }
    .padding()
    .background(Color.theme.primaryBackground)
}
