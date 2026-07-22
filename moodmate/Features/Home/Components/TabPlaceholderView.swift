//
//  TabPlaceholderView.swift
//  moodmate
//
//  Created by Nurtore on 22.07.2026.
//

import SwiftUI

struct TabPlaceholderView: View {
    let title: String
    let systemImage: String
    var onSignOut: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: systemImage)
                .font(.system(size: 54))
                .foregroundStyle(.teal.gradient)
                .padding()
                .background(Circle().fill(.teal.opacity(0.08)))
            
            Text(title)
                .font(.system(size: 22, weight: .bold, design: .rounded))
            
            Text("This screen is currently under active development. Stay tuned for mindfulness updates!")
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            if title == "Your Profile" {
                Button(action: onSignOut) {
                    Text("Sign Out")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.red)
                        .clipShape(Capsule())
                }
                .padding(.top, 10)
            }
        }
        .padding(.bottom, 60)
    }
}

#Preview {
    TabPlaceholderView(title: "Insights", systemImage: "chart.bar.xaxis", onSignOut: {})
}
