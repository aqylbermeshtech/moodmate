//
//  SearchResultsView.swift
//  moodmate
//
//  Created by Nurtore on 26.07.2026.
//

import SwiftUI

struct SearchResultsView: View {
    let results: [SearchResult]
    @Binding var scope: SearchScope
    let searchText: String
    var onSelectResult: (SearchResult) -> Void
    var onFollowUser: (String) -> Void
    var onLikePost: (String) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(SearchScope.allCases, id: \.self) { item in
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                scope = item
                            }
                        } label: {
                            Text(item.rawValue)
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background {
                                    if scope == item {
                                        Capsule().fill(Color.theme.accent)
                                    } else {
                                        Capsule().fill(Color.theme.surface)
                                    }
                                }
                                .foregroundStyle(scope == item ? .white : Color.theme.primaryText)
                                .overlay(
                                    Capsule()
                                        .stroke(
                                            scope == item ? Color.clear : Color.theme.border,
                                            lineWidth: 1
                                        )
                                )
                        }
                        .buttonStyle(ScaleButtonStyle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
            }
            
            if results.isEmpty {
                VStack(spacing: 16) {
                    Spacer(minLength: 40)
                    
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 40))
                        .foregroundStyle(Color.theme.secondaryText)
                    
                    Text("No results for \"\(searchText)\"")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.theme.secondaryText)
                    
                    Spacer(minLength: 40)
                }
            } else {
                List {
                    ForEach(results) { result in
                        SearchResultRow(
                            result: result,
                            onFollowUser: onFollowUser,
                            onLikePost: onLikePost
                        )
                        .contentShape(Rectangle())
                        .onTapGesture {
                            onSelectResult(result)
                        }
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 4, leading: 20, bottom: 4, trailing: 20))
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
    }
}

private struct SearchResultRow: View {
    let result: SearchResult
    var onFollowUser: (String) -> Void
    var onLikePost: (String) -> Void
    var userStore: UserStoreProtocol = UserStore.shared

    private var postAuthor: AppUser? {
        guard let postUserId = result.postUserId else { return nil }
        return userStore.user(for: postUserId)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            switch result.type {
            case .user:
                AvatarView(
                    imageData: result.avatarImageData,
                    name: result.userName ?? "",
                    colorHex: result.avatarColorHex ?? "38B2AC",
                    size: 44,
                    showBorder: true
                )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(result.userName ?? "")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.theme.primaryText)

                    Text("@\(result.username ?? "")")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.theme.secondaryText)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.theme.tertiaryText)
                
            case .post:
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.adaptiveColor(hex: result.postGradientStartHex ?? "38B2AC"),
                                Color.adaptiveColor(hex: result.postGradientEndHex ?? "805AD5")
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 44, height: 44)
                    .overlay(
                        Image(systemName: "quote.bubble.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(.white.opacity(0.8))
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(result.postQuote ?? result.postCaption ?? "")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color.theme.primaryText)
                        .lineLimit(1)
                    
                    Text("by \(postAuthor?.name ?? "User")")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.theme.secondaryText)
                }
                
                Spacer()
                
                HStack(spacing: 3) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 11))
                        .foregroundStyle(.red.opacity(0.8))
                    Text("\(result.postLikesCount ?? 0)")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.theme.secondaryText)
                }
                
            case .hashtag:
                ZStack {
                    Circle()
                        .fill(Color.theme.accent.opacity(0.12))
                    Text("#")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.theme.accent)
                }
                .frame(width: 44, height: 44)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("#\(result.hashtagName ?? "")")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.theme.primaryText)
                    
                    Text("\(result.hashtagPostCount ?? 0) posts")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.theme.secondaryText)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.theme.tertiaryText)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color.theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.theme.border, lineWidth: 1)
        )
    }
    
}

#Preview {
    SearchResultsView(
        results: [
            SearchResult(id: "1", type: .user, userName: "Luna Park", username: "luna_glow", avatarColorHex: "ED64A6"),
            SearchResult(id: "2", type: .hashtag, hashtagName: "MorningWalk", hashtagPostCount: 3421)
        ],
        scope: .constant(.all),
        searchText: "Luna",
        onSelectResult: { _ in },
        onFollowUser: { _ in },
        onLikePost: { _ in }
    )
}
