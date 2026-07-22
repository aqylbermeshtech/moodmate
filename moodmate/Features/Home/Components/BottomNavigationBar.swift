//
//  BottomNavigationBar.swift
//  moodmate
//
//  Created by Nurtore on 22.07.2026.
//

import SwiftUI

enum HomeTab: Int, CaseIterable {
    case home
    case discover
    case add
    case insights
    case profile
    
    var iconName: String {
        switch self {
        case .home: return "house.fill"
        case .discover: return "magnifyingglass"
        case .add: return "plus"
        case .insights: return "chart.bar.fill"
        case .profile: return "person.fill"
        }
    }
    
    var label: String {
        switch self {
        case .home: return "Home"
        case .discover: return "Discover"
        case .add: return "Add"
        case .insights: return "Insights"
        case .profile: return "Profile"
        }
    }
}

struct BottomNavigationBar: View {
    @Binding var selectedTab: HomeTab
    var onAddTap: () -> Void
    
    var body: some View {
        HStack {
            ForEach(HomeTab.allCases, id: \.self) { tab in
                if tab == .add {
                    // Floating Action Button in the center
                    Button(action: onAddTap) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.teal, Color.teal.opacity(0.85)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 52, height: 52)
                                .shadow(color: Color.teal.opacity(0.35), radius: 8, x: 0, y: 4)
                            
                            Image(systemName: tab.iconName)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(.white)
                        }
                    }
                    .buttonStyle(ScaleButtonStyle())
                    .offset(y: -12) // Slightly raised
                    .frame(maxWidth: .infinity)
                } else {
                    // Standard tab item
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                            selectedTab = tab
                        }
                    }) {
                        VStack(spacing: 4) {
                            Image(systemName: tab.iconName)
                                .font(.system(size: 20, weight: selectedTab == tab ? .bold : .medium))
                                .foregroundStyle(selectedTab == tab ? Color.teal : Color.secondary.opacity(0.65))
                                .scaleEffect(selectedTab == tab ? 1.15 : 1.0)
                            
                            Text(tab.label)
                                .font(.system(size: 10, weight: selectedTab == tab ? .bold : .medium))
                                .foregroundStyle(selectedTab == tab ? Color.teal : Color.secondary.opacity(0.65))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background {
            // Glassmorphic background
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color(.systemBackground).opacity(0.72))
                .background(.ultraThinMaterial)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.white.opacity(0.18), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.06), radius: 16, x: 0, y: 10)
        .padding(.horizontal, 24)
    }
}

#Preview {
    ZStack {
        Color.purple.opacity(0.15).ignoresSafeArea()
        VStack {
            Spacer()
            BottomNavigationBar(selectedTab: .constant(.home), onAddTap: {})
        }
    }
}
