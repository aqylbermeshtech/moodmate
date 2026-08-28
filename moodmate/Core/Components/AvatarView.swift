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
    let overlayAction: (() -> Void)?
    let overlayIcon: String?

    init(
        imageData: Data? = nil,
        image: UIImage? = nil,
        name: String = "",
        colorHex: String = "38B2AC",
        size: CGFloat = 80,
        showBorder: Bool = true,
        overlayAction: (() -> Void)? = nil,
        overlayIcon: String? = nil
    ) {
        self.imageData = imageData
        self.image = image
        self.name = name
        self.colorHex = colorHex
        self.size = size
        self.showBorder = showBorder
        self.overlayAction = overlayAction
        self.overlayIcon = overlayIcon
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
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
