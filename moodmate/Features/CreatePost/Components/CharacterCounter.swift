//
//  CharacterCounter.swift
//  moodmate
//
//  Created by Antigravity on 31.07.2026.
//

import SwiftUI

struct CharacterCounter: View {
    let currentLength: Int
    let maxLength: Int
    
    private var progress: Double {
        min(Double(currentLength) / Double(maxLength), 1.0)
    }
    
    private var isNearLimit: Bool {
        currentLength > maxLength - 30
    }
    
    private var isOverLimit: Bool {
        currentLength > maxLength
    }
    
    private var counterColor: Color {
        if isOverLimit {
            return Color.theme.error
        } else if isNearLimit {
            return Color.theme.warning
        } else {
            return Color.theme.tertiaryText
        }
    }
    
    var body: some View {
        HStack(spacing: 8) {
            // Circular progress indicator
            ZStack {
                Circle()
                    .stroke(Color.theme.border, lineWidth: 2)
                    .frame(width: 18, height: 18)
                
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(counterColor, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                    .frame(width: 18, height: 18)
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: progress)
            }
            
            Text("\(maxLength - currentLength)")
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundStyle(counterColor)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(counterColor.opacity(0.1))
        .clipShape(Capsule())
    }
}

#Preview {
    HStack(spacing: 12) {
        CharacterCounter(currentLength: 120, maxLength: 500)
        CharacterCounter(currentLength: 480, maxLength: 500)
        CharacterCounter(currentLength: 510, maxLength: 500)
    }
    .padding()
}
