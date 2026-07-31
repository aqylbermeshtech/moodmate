//
//  VisibilitySelector.swift
//  moodmate
//
//  Created by Antigravity on 31.07.2026.
//

import SwiftUI

struct VisibilitySelector: View {
    @Binding var selectedVisibility: PostVisibility
    @Namespace private var segmentAnimation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Who can see this?")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.theme.secondaryText)
                    .textCase(.uppercase)
                
                Spacer()
                
                Text(selectedVisibility.description)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Color.theme.tertiaryText)
                    .lineLimit(1)
            }
            .padding(.horizontal, 4)
            
            HStack(spacing: 6) {
                ForEach(PostVisibility.allCases) { visibility in
                    let isSelected = selectedVisibility == visibility
                    
                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                            selectedVisibility = visibility
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: visibility.iconName)
                                .font(.system(size: 13, weight: isSelected ? .bold : .medium))
                            
                            Text(visibility.rawValue)
                                .font(.system(size: 13, weight: isSelected ? .bold : .semibold, design: .rounded))
                        }
                        .foregroundStyle(isSelected ? Color.theme.primaryText : Color.theme.secondaryText)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background {
                            if isSelected {
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(Color.theme.surface)
                                    .matchedGeometryEffect(id: "ACTIVE_VISIBILITY_HIGHLIGHT", in: segmentAnimation)
                                    .shadow(color: Color.theme.shadow, radius: 4, x: 0, y: 2)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(4)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.theme.secondaryBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.theme.border, lineWidth: 1)
            )
        }
    }
}

#Preview {
    VisibilitySelector(selectedVisibility: .constant(.publicVisibility))
        .padding()
        .background(Color.theme.primaryBackground)
}
