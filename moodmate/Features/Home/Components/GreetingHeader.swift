//
//  GreetingHeader.swift
//  moodmate
//
//  Created by Nurtore on 22.07.2026.
//

import SwiftUI

struct GreetingHeader: View {
    @ObservedObject var viewModel: HomeViewModel
    var onProfileTap: () -> Void
    
    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.greetingText)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(Color.theme.secondaryText)
                
                Text("\(viewModel.currentUserDisplayName)")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.theme.primaryText)
                
                Text(viewModel.formattedDate)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.theme.tertiaryText)
            }
            
            Spacer()
            
            // Profile avatar button
            Button(action: onProfileTap) {
                let currentProfile = ProfileService.shared.getProfile(forId: nil)
                AvatarView(
                    imageData: currentProfile?.avatarImageData,
                    name: viewModel.currentUserDisplayName,
                    colorHex: currentProfile?.avatarColorHex ?? "38B2AC",
                    size: 50,
                    showBorder: true
                )
            }
            .buttonStyle(ScaleButtonStyle())
        }
    }
    
}

// Reusable scale effect button style for premium tactile feedback
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.94 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

#Preview {
    ZStack {
        Color.teal.opacity(0.1).ignoresSafeArea()
        GreetingHeader(viewModel: HomeViewModel(), onProfileTap: {})
            .padding()
    }
}
