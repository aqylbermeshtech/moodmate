//
//  DiscoverSearchBar.swift
//  moodmate
//
//  Created by Nurtore on 26.07.2026.
//

import SwiftUI

struct DiscoverSearchBar: View {
    @Binding var searchText: String
    @Binding var isSearchActive: Bool
    let recentSearches: [String]
    var onRecentSearchTap: (String) -> Void
    var onClearHistory: () -> Void
    var onSubmit: (String) -> Void
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 10) {
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.secondary)
                    
                    TextField("Search users, moods, hashtags…", text: $searchText)
                        .font(.system(size: 15))
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .focused($isFocused)
                        .onSubmit {
                            onSubmit(searchText)
                        }
                    
                    if !searchText.isEmpty {
                        Button {
                            withAnimation(.easeOut(duration: 0.2)) {
                                searchText = ""
                            }
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 15))
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)
                        .transition(.scale.combined(with: .opacity))
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color.theme.surface)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(isFocused ? Color.teal.opacity(0.4) : Color.theme.border, lineWidth: 1)
                )
                
                if isSearchActive {
                    Button("Cancel") {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            searchText = ""
                            isSearchActive = false
                            isFocused = false
                        }
                    }
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.teal)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                }
            }
            .onChange(of: isFocused) { _, focused in
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    if focused {
                        isSearchActive = true
                    }
                }
            }

            if isSearchActive && searchText.isEmpty && !recentSearches.isEmpty {
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text("Recent Searches")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.theme.secondaryText)
                        
                        Spacer()
                        
                        Button("Clear") {
                            withAnimation(.easeOut(duration: 0.2)) {
                                onClearHistory()
                            }
                        }
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.teal)
                    }
                    .padding(.horizontal, 4)
                    .padding(.top, 14)
                    .padding(.bottom, 8)
                    
                    ForEach(recentSearches, id: \.self) { search in
                        Button {
                            searchText = search
                            onRecentSearchTap(search)
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "clock.arrow.circlepath")
                                    .font(.system(size: 13))
                                    .foregroundStyle(Color.theme.secondaryText)
                                
                                Text(search)
                                    .font(.system(size: 14))
                                    .foregroundStyle(Color.theme.primaryText)
                                
                                Spacer()
                                
                                Image(systemName: "arrow.up.left")
                                    .font(.system(size: 11))
                                    .foregroundStyle(Color.theme.tertiaryText)
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 4)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
}

#Preview {
    ZStack {
        LinearGradient(
            colors: [.teal.opacity(0.18), .purple.opacity(0.12)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        
        VStack {
            DiscoverSearchBar(
                searchText: .constant(""),
                isSearchActive: .constant(true),
                recentSearches: ["Happy", "Maya", "MorningWalk"],
                onRecentSearchTap: { _ in },
                onClearHistory: {},
                onSubmit: { _ in }
            )
            .padding(.horizontal, 20)
            
            Spacer()
        }
    }
}
