//
//  ImagePreviewCard.swift
//  moodmate
//
//  Created by Antigravity on 31.07.2026.
//

import SwiftUI

struct ImagePreviewCard: View {
    let image: UIImage
    var onRemove: () -> Void
    var onReplace: () -> Void
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity)
                .frame(height: 240)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.theme.border, lineWidth: 1)
                )
                .shadow(color: Color.theme.shadow, radius: 10, x: 0, y: 5)
            
            // Action Overlay Buttons
            HStack(spacing: 8) {
                // Replace button
                Button(action: onReplace) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.system(size: 12, weight: .bold))
                        Text("Replace")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.black.opacity(0.65))
                    .clipShape(Capsule())
                }
                .buttonStyle(ScaleButtonStyle())
                
                // Remove button
                Button(action: onRemove) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 28, height: 28)
                        .background(Color.black.opacity(0.65))
                        .clipShape(Circle())
                }
                .buttonStyle(ScaleButtonStyle())
            }
            .padding(12)
        }
    }
}
