//
//  SettingsView.swift
//  moodmate
//
//  Created by Nurtore on 23.07.2026.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: OwnProfileViewModel
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject private var router: AppRouter
    
    @State private var notificationsEnabled = true
    @State private var weeklyDigestEnabled = true
    @State private var showSignOutConfirmation = false
    
    let themes = AppAppearance.allCases
    
    var body: some View {
        ZStack {
            Color.theme.primaryBackground
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {

                    VStack(alignment: .leading, spacing: 0) {
                        Text("Account Settings")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.theme.secondaryText)
                            .padding(.leading, 8)
                            .padding(.bottom, 8)
                        
                        VStack(spacing: 0) {
                            Button {
                                router.push(.editProfile)
                            } label: {
                                settingRow(icon: "person.circle", title: "Edit Profile", subtitle: "Update bio, name, or color")
                            }
                            
                            Divider()
                                .background(Color.theme.divider)
                                .padding(.horizontal, 16)
                            
                            settingRow(icon: "lock.shield", title: "Privacy & Security", subtitle: "Manage accounts & visibility")
                                .opacity(0.8)
                        }
                        .background(Color.theme.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(Color.theme.border, lineWidth: 1)
                        )
                    }
 
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Preferences")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.theme.secondaryText)
                            .padding(.leading, 8)
                            .padding(.bottom, 8)
                        
                        VStack(spacing: 0) {
                            HStack {
                                Label {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Daily Reminders")
                                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                                            .foregroundStyle(Color.theme.primaryText)
                                        Text("Remind me to check in my mood")
                                            .font(.system(size: 11))
                                            .foregroundStyle(Color.theme.secondaryText)
                                    }
                                } icon: {
                                    Image(systemName: "bell.badge.fill")
                                        .font(.system(size: 18))
                                        .foregroundStyle(.teal)
                                }
                                Spacer()
                                Toggle("", isOn: $notificationsEnabled)
                                    .tint(.teal)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            
                            Divider()
                                .background(Color.theme.divider)
                                .padding(.horizontal, 16)
                            

                            HStack {
                                Label {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Weekly Report")
                                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                                            .foregroundStyle(Color.theme.primaryText)
                                        Text("Receive weekly insights & patterns")
                                            .font(.system(size: 11))
                                            .foregroundStyle(Color.theme.secondaryText)
                                    }
                                } icon: {
                                    Image(systemName: "chart.bar.doc.horizontal.fill")
                                        .font(.system(size: 18))
                                        .foregroundStyle(.purple)
                                }
                                Spacer()
                                Toggle("", isOn: $weeklyDigestEnabled)
                                    .tint(.teal)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            
                            Divider()
                                .background(Color.theme.divider)
                                .padding(.horizontal, 16)

                            HStack {
                                Label {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("App Theme")
                                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                                            .foregroundStyle(Color.theme.primaryText)
                                        Text("Customize interface display mode")
                                            .font(.system(size: 11))
                                            .foregroundStyle(Color.theme.secondaryText)
                                    }
                                } icon: {
                                    Image(systemName: "paintpalette.fill")
                                        .font(.system(size: 18))
                                        .foregroundStyle(.pink)
                                }
                                Spacer()
                                Picker("", selection: Binding(
                                    get: { themeManager.selectedAppearance },
                                    set: { themeManager.selectedAppearance = $0 }
                                )) {
                                    ForEach(themes) { theme in
                                        Text(theme.rawValue).tag(theme)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .tint(.teal)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                        }
                        .background(Color.theme.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(Color.theme.border, lineWidth: 1)
                        )
                    }

                    VStack(alignment: .leading, spacing: 0) {
                        Text("Support")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.theme.secondaryText)
                            .padding(.leading, 8)
                            .padding(.bottom, 8)
                        
                        VStack(spacing: 0) {
                            settingRow(icon: "questionmark.circle.fill", title: "Help Center", subtitle: "FAQs and app guides")
                            
                            Divider()
                                .background(Color.theme.divider)
                                .padding(.horizontal, 16)
                            
                            settingRow(icon: "doc.text.fill", title: "Terms of Service", subtitle: "Terms of using MoodMate")
                            
                            Divider()
                                .background(Color.theme.divider)
                                .padding(.horizontal, 16)
                            
                            settingRow(icon: "shield.righthalf.filled", title: "Privacy Policy", subtitle: "Your data rights & rules")
                        }
                        .background(Color.theme.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(Color.theme.border, lineWidth: 1)
                        )
                    }

                    Button(action: {
                        showSignOutConfirmation = true
                    }) {
                        HStack {
                            Spacer()
                            Image(systemName: "power")
                                .font(.system(size: 16, weight: .bold))
                            Text("Sign Out")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                            Spacer()
                        }
                        .foregroundStyle(.white)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(
                                colors: [Color.red, Color.red.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .shadow(color: Color.red.opacity(0.2), radius: 8, x: 0, y: 4)
                    }
                    .buttonStyle(ScaleButtonStyle())
                    .padding(.top, 8)
                }
                .padding(20)
                .padding(.bottom, 100)
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog(
            "Are you sure you want to sign out?",
            isPresented: $showSignOutConfirmation,
            titleVisibility: .visible
        ) {
            Button("Sign Out", role: .destructive) {
                signOutUser()
            }
            Button("Cancel", role: .cancel) {}
        }
        .errorAlert($viewModel.errorMessage)
    }
    
    // MARK: - Row builder
    private func settingRow(icon: String, title: String, subtitle: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(.teal)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.theme.primaryText)
                Text(subtitle)
                    .font(.system(size: 11))
                    .foregroundStyle(Color.theme.secondaryText)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.theme.tertiaryText)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .contentShape(Rectangle())
    }
    
    private func signOutUser() {
        do {
            try viewModel.signOut()
            dismiss()
        } catch {
            viewModel.errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView(viewModel: OwnProfileViewModel())
    }
    .environmentObject(ThemeManager.shared)
    .environmentObject(AppRouter.shared)
}
