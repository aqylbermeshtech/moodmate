//
//  PhotoAttachmentView.swift
//  moodmate
//
//  Created by Antigravity on 31.07.2026.
//

import SwiftUI
import PhotosUI

struct PhotoAttachmentView: View {
    @Binding var images: [UIImage]
    var onAddPhotoTap: () -> Void
    var onRemovePhoto: (Int) -> Void
    var onReplacePhoto: (Int) -> Void
    
    @State private var selectedItem: PhotosPickerItem? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if images.isEmpty {
                Button(action: onAddPhotoTap) {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color.theme.accent.opacity(0.12))
                                .frame(width: 44, height: 44)
                            
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundStyle(Color.theme.accent)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Add Photos")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.theme.primaryText)
                            
                            Text("Share a photo from your day (optional)")
                                .font(.system(size: 13))
                                .foregroundStyle(Color.theme.secondaryText)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(Color.theme.accent)
                    }
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(Color.theme.surface)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(Color.theme.border, style: StrokeStyle(lineWidth: 1, dash: [6]))
                    )
                }
                .buttonStyle(ScaleButtonStyle())
            } else {
                VStack(spacing: 12) {
                    ForEach(Array(images.enumerated()), id: \.offset) { index, image in
                        ImagePreviewCard(
                            image: image,
                            onRemove: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                                    onRemovePhoto(index)
                                }
                            },
                            onReplace: {
                                onReplacePhoto(index)
                            }
                        )
                    }
                    if images.count < 4 {
                        Button(action: onAddPhotoTap) {
                            HStack(spacing: 8) {
                                Image(systemName: "photo.badge.plus")
                                    .font(.system(size: 14, weight: .semibold))
                                Text("Add another photo")
                                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                            }
                            .foregroundStyle(Color.theme.accent)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(Color.theme.accent.opacity(0.1))
                            .clipShape(Capsule())
                        }
                        .buttonStyle(ScaleButtonStyle())
                    }
                }
            }
        }
    }
}

#Preview {
    PhotoAttachmentView(
        images: .constant([]),
        onAddPhotoTap: {},
        onRemovePhoto: { _ in },
        onReplacePhoto: { _ in }
    )
    .padding()
    .background(Color.theme.primaryBackground)
}
