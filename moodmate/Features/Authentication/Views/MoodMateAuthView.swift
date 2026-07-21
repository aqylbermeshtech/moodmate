//
//  MoodMateAuthView.swift
//  moodmate
//
//  Created by Nurtore on 20.07.2026.
//

import SwiftUI

enum AuthMode {
    case signIn
    case signUp
}

struct MoodMateAuthView: View {
    @State private var authMode: AuthMode = .signIn

    private func toggleMode() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
            authMode = authMode == .signIn ? .signUp : .signIn
        }
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.teal.opacity(0.28), Color.purple.opacity(0.2)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        VStack(spacing: 10) {
                            Image(systemName: "leaf.circle.fill")
                                .font(.system(size: 44))
                                .foregroundStyle(.teal)

                            Text("MoodMate")
                                .font(.system(size: 34, weight: .bold, design: .rounded))

                            Text(authMode == .signUp ? "Let’s begin your mindful routine." : "Welcome back. How are you feeling today?")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .padding(.top, 24)

                        Group {
                            if authMode == .signUp {
                                SignUpView()
                                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                            } else {
                                SignInView()
                                    .transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .trailing)))
                            }
                        }
                        .frame(maxWidth: 420)
                        .animation(.easeInOut(duration: 0.22), value: authMode)

                        Button(action: toggleMode) {
                            HStack(spacing: 6) {
                                Text(authMode == .signUp ? "Already have an account?" : "New to MoodMate?")
                                    .foregroundStyle(.secondary)
                                Text(authMode == .signUp ? "Sign In" : "Sign Up")
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.teal)
                            }
                            .font(.footnote)
                        }
                        .padding(.bottom, 20)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 28)
                    .frame(minHeight: geometry.size.height)
                    .frame(maxWidth: 560)
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                .scrollDismissesKeyboard(.interactively)
            }
        }
    }
}

#Preview {
    MoodMateAuthView()
}
