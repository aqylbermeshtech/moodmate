//
//  BottomNavigationBar.swift
//  moodmate
//
//  Created by Nurtore on 22.07.2026.
//

import SwiftUI

// MARK: - Tab Enum
enum HomeTab: Int, CaseIterable, Identifiable {
    case home
    case discover
    case add
    case insights
    case profile
    
    var id: Int { rawValue }
    
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

// MARK: - Glass Bottom Navigation Bar
struct BottomNavigationBar: View {
    @Binding var selectedTab: HomeTab
    var onAddTap: () -> Void
    
    @Namespace private var activeTabAnimation
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(HomeTab.allCases) { tab in
                if tab == .add {
                    // Elevated Center Action Button
                    Button(action: onAddTap) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [.teal, .teal.opacity(0.85)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 52, height: 52)
                                .shadow(color: .teal.opacity(0.35), radius: 8, x: 0, y: 4)
                            
                            Image(systemName: tab.iconName)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(.white)
                        }
                    }
                    .buttonStyle(ScaleButtonStyle())
                    .offset(y: -12)
                    .frame(maxWidth: .infinity)
                } else {
                    // Glass Tab Item with Sliding Highlight
                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                            selectedTab = tab
                        }
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: tab.iconName)
                                .font(.system(size: 18, weight: selectedTab == tab ? .bold : .medium))
                            
                            if selectedTab == tab {
                                Text(tab.label)
                                    .font(.system(size: 10, weight: .bold))
                                    .transition(.scale.combined(with: .opacity))
                            }
                        }
                        .foregroundStyle(selectedTab == tab ? Color.teal : Color.secondary.opacity(0.7))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background {
                            if selectedTab == tab {
                                Capsule()
                                    .fill(Color.teal.opacity(0.12))
                                    .matchedGeometryEffect(id: "ACTIVE_TAB_HIGHLIGHT", in: activeTabAnimation)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background {
            // Liquid Glass Capsule Container
            Capsule()
                .fill(.ultraThinMaterial)
                .overlay(
                    Capsule()
                        .stroke(
                            LinearGradient(
                                colors: [.white.opacity(0.35), .white.opacity(0.08)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        }
        .shadow(color: .black.opacity(0.08), radius: 16, x: 0, y: 8)
        .padding(.horizontal, 20)
    }
}


// MARK: - Preview
#Preview {
    ZStack {
        // Gradient background to test the Glass effect
        LinearGradient(
            colors: [.purple.opacity(0.3), .blue.opacity(0.2)],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
        
        VStack {
            Spacer()
            BottomNavigationBar(selectedTab: .constant(.home), onAddTap: {})
        }
    }
}
