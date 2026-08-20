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
                        .foregroundStyle(Color.theme.secondaryText)

                    TextField("Search", text: $searchText)
                        .font(.xPostBody)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .focused($isFocused)
                        .foregroundStyle(Color.theme.primaryText)
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
                                .foregroundStyle(Color.theme.secondaryText)
                        }
                        .buttonStyle(.plain)
                        .transition(.scale.combined(with: .opacity))
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color.theme.secondaryBackground)
                .clipShape(Capsule())

                if isSearchActive {
                    Button("Cancel") {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            searchText = ""
                            isSearchActive = false
                            isFocused = false
                        }
                    }
                    .font(.xButton)
                    .foregroundStyle(Color.theme.primaryText)
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
                        Text("Recent")
                            .font(.xSectionHeader)
                            .foregroundStyle(Color.theme.primaryText)

                        Spacer()

                        Button("Clear all") {
                            withAnimation(.easeOut(duration: 0.2)) {
                                onClearHistory()
                            }
                        }
                        .font(.xTrendingMeta)
                        .foregroundStyle(Color.theme.accent)
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
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 13))
                                    .foregroundStyle(Color.theme.secondaryText)

                                Text(search)
                                    .font(.xPostBody)
                                    .foregroundStyle(Color.theme.primaryText)

                                Spacer()

                                Image(systemName: "xmark")
                                    .font(.system(size: 11))
                                    .foregroundStyle(Color.theme.secondaryText)
                            }
                            .padding(.vertical, 10)
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
        Color.theme.primaryBackground
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
            .padding(.horizontal, 16)

            Spacer()
        }
    }
}
