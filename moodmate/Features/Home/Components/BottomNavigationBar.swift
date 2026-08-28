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
    case add        // Kept for routing — intercepted by FAB
    case chat
    case profile

    var id: Int { rawValue }

    var iconName: String {
        switch self {
        case .home: return "house"
        case .discover: return "magnifyingglass"
        case .add: return "plus"
        case .chat: return "envelope"
        case .profile: return "person"
        }
    }

    var selectedIconName: String {
        switch self {
        case .home: return "house.fill"
        case .discover: return "magnifyingglass"
        case .add: return "plus"
        case .chat: return "envelope.fill"
        case .profile: return "person.fill"
        }
    }

    var label: String {
        switch self {
        case .home: return "Home"
        case .discover: return "Search"
        case .add: return "Add"
        case .chat: return "Messages"
        case .profile: return "Profile"
        }
    }
}

// MARK: - X-Style Tab Bar (icon-only, blur background)
struct BottomNavigationBar: View {
    @Binding var selectedTab: HomeTab
    var onAddTap: () -> Void

    private var visibleTabs: [HomeTab] {
        HomeTab.allCases.filter { $0 != .add }
    }

    var body: some View {
        VStack(spacing: 0) {
            Rectangle().fill(Color.theme.divider).frame(height: 0.5)

            HStack(spacing: 0) {
                ForEach(visibleTabs) { tab in
                    Button {
                        withAnimation(.easeOut(duration: 0.15)) {
                            selectedTab = tab
                        }
                    } label: {
                        Image(systemName: selectedTab == tab ? tab.selectedIconName : tab.iconName)
                            .font(.system(size: 24, weight: selectedTab == tab ? .bold : .regular))
                            .foregroundStyle(selectedTab == tab ? Color.theme.primaryText : Color.theme.secondaryText)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 8)
        }
        .background(
            ZStack {
                Rectangle()
                    .fill(.ultraThinMaterial)
                Color.theme.primaryBackground.opacity(0.85)
            }
            .ignoresSafeArea(.container, edges: .bottom)
        )
    }
}

// MARK: - Floating Post Button (X FAB)
struct XPostFAB: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "pencil.and.outline")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(.black)
                .frame(width: 56, height: 56)
                .background(Circle().fill(Color.white))
                .shadow(color: .black.opacity(0.35), radius: 12, y: 4)
        }
        .buttonStyle(XPressableStyle(pressedScale: 0.95))
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
