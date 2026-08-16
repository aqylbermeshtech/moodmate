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
    case chat
    case profile

    var id: Int { rawValue }

    var iconName: String {
        switch self {
        case .home: return "house.fill"
        case .discover: return "magnifyingglass"
        case .add: return "plus"
        case .chat: return "bubble.left.and.bubble.right.fill"
        case .profile: return "person.fill"
        }
    }

    var label: String {
        switch self {
        case .home: return "Home"
        case .discover: return "Discover"
        case .add: return "Add"
        case .chat: return "Chat"
        case .profile: return "Profile"
        }
    }
}

// MARK: - Integrated Bottom Navigation Bar
struct BottomNavigationBar: View {
    @Binding var selectedTab: HomeTab
    var onAddTap: () -> Void
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(HomeTab.allCases) { tab in
                if tab == .add {
                    Button(action: onAddTap) {
                        ZStack {
                            Circle()
                                .fill(
                                    Color.theme.accent
                                )
                                .frame(width: 52, height: 52)
                            
                            Image(systemName: tab.iconName)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(.white)
                        }
                    }
                    .buttonStyle(ScaleButtonStyle())
                    .offset(y: -12)
                    .frame(maxWidth: .infinity)
                } else {
                    Button {
                        withAnimation(.easeOut(duration: 0.18)) {
                            selectedTab = tab
                        }
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: tab.iconName)
                                .font(.system(size: 18, weight: selectedTab == tab ? .bold : .medium))

                            if selectedTab == tab {
                                    Text(tab.label)
                                    .font(.caption2.weight(.medium))
                                    .transition(.scale.combined(with: .opacity))
                            }
                        }
                        .foregroundStyle(selectedTab == tab ? Color.theme.accent : Color.theme.secondaryText)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background {
                            if selectedTab == tab {
                                    Capsule().fill(Color.theme.accent.opacity(0.12))
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
            Capsule()
                .fill(Color.theme.surface)
                .overlay(
                    Capsule().stroke(Color.theme.border, lineWidth: 0.5)
                )
        }
        .shadow(color: Color.theme.shadow, radius: AppShadow.radius, y: AppShadow.y)
        .padding(.horizontal, 20)
    }
}


// MARK: - Preview
#Preview {
    ZStack {
        Color.theme.primaryBackground
        .ignoresSafeArea()
        
        VStack {
            Spacer()
            BottomNavigationBar(selectedTab: .constant(.home), onAddTap: {})
        }
    }
}
