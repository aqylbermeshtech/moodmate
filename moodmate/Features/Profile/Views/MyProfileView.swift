//
//  MyProfileView.swift
//  moodmate
//
//  Created by Nurtore on 23.07.2026.
//

import SwiftUI

struct MyProfileView: View {
    @StateObject private var viewModel = OwnProfileViewModel()
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        Group {
            if viewModel.isWaitingForAuthentication {
                ZStack {
                    Color.theme.primaryBackground
                        .ignoresSafeArea()
                    ProgressView("Loading Profile...")
                        .font(.xPostBody)
                        .foregroundStyle(Color.theme.secondaryText)
                        .tint(Color.theme.accent)
                }
            } else {
                ProfileContentView(
                    viewModel: viewModel,
                    primaryAction: {
                        Button {
                            router.push(.editProfile)
                        } label: {
                            Text("Edit profile")
                                .font(.xButton)
                                .foregroundStyle(Color.theme.primaryText)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 9999, style: .continuous)
                                        .strokeBorder(Color.theme.divider, lineWidth: 1)
                                )
                        }
                        .buttonStyle(XPressableStyle())
                    },
                    toolbarTrailing: {
                        Button {
                            router.push(.settings)
                        } label: {
                            Image(systemName: "gearshape")
                                .font(.system(size: 20))
                                .foregroundStyle(Color.theme.primaryText)
                        }
                    }
                )
            }
        }
    }
}

#Preview {
    NavigationStack {
        MyProfileView()
    }
    .environmentObject(AppRouter.shared)
}
