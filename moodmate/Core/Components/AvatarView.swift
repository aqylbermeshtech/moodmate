//
//  AvatarView.swift
//  moodmate
//
//  Created by Antigravity on 31.07.2026.
//

import SwiftUI

struct AvatarView: View {
    let imageData: Data?
    let image: UIImage?
    let name: String
    let colorHex: String
    let size: CGFloat
    let showBorder: Bool
    let moodEmoji: String?
    let overlayAction: (() -> Void)?
    let overlayIcon: String?

    init(
        imageData: Data? = nil,
        image: UIImage? = nil,
        name: String = "",
        colorHex: String = "38B2AC",
        size: CGFloat = 80,
        showBorder: Bool = true,
        moodEmoji: String? = nil,
        overlayAction: (() -> Void)? = nil,
        overlayIcon: String? = nil
    ) {
        self.imageData = imageData
        self.image = image
        self.name = name
        self.colorHex = colorHex
        self.size = size
        self.showBorder = showBorder
        self.moodEmoji = moodEmoji
        self.overlayAction = overlayAction
        self.overlayIcon = overlayIcon
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // Main Avatar Base
            Group {
                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: size, height: size)
                        .clipShape(Circle())
                } else if let imageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: size, height: size)
                        .clipShape(Circle())
                } else {
                    // Initials fallback — X-style neutral surface
                    ZStack {
                        Circle()
                            .fill(Color.theme.secondaryBackground)

                        Text(getInitials(name))
                            .font(.system(size: size * 0.38, weight: .semibold))
                            .foregroundStyle(Color.theme.primaryText)
                    }
                    .frame(width: size, height: size)
                }
            }
            .overlay(
                Circle()
                    .stroke(Color.theme.divider, lineWidth: showBorder ? max(1.5, size * 0.03) : 0)
            )

            // Mood Emoji Badge Overlay
            if let moodEmoji {
                ZStack {
                    Circle()
                        .fill(Color.theme.primaryBackground)
                        .frame(width: size * 0.33, height: size * 0.33)

                    Text(moodEmoji)
                        .font(.system(size: size * 0.2))
                }
                .offset(x: size * 0.04, y: size * 0.04)
            }

            // Action Icon Overlay (Camera edit button)
            if let overlayAction, let overlayIcon {
                Button(action: overlayAction) {
                    ZStack {
                        Circle()
                            .fill(Color.theme.accent)
                            .frame(width: size * 0.32, height: size * 0.32)

                        Image(systemName: overlayIcon)
                            .font(.system(size: size * 0.16, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .offset(x: size * 0.02, y: size * 0.02)
                .accessibilityLabel("Change avatar photo")
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(name)'s profile picture")
    }
}
