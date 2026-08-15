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
                        .font(.system(.body, design: .rounded))
                        .foregroundStyle(Color.theme.secondaryText)
                        .tint(.teal)
                }
            } else {
                ProfileContentView(
                    viewModel: viewModel,
                    primaryAction: {
                        Button {
                            router.push(.editProfile)
                        } label: {
                            HStack {
                                Image(systemName: "pencil")
                                    .font(.system(size: 14, weight: .bold))
                                Text("Edit Profile")
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.theme.accent)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .shadow(color: Color.teal.opacity(0.2), radius: 6, x: 0, y: 3)
                        }
                        .buttonStyle(ScaleButtonStyle())
                    },
                    toolbarTrailing: {
                        Button {
                            router.push(.settings)
                        } label: {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 18))
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
