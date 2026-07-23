//
//  EditProfileView.swift
//  moodmate
//
//  Created by Nurtore on 23.07.2026.
//

import SwiftUI

struct EditProfileView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var displayName: String = ""
    @State private var username: String = ""
    @State private var bio: String = ""
    @State private var avatarColorHex: String = "38B2AC"
    
    // Curated gradient avatar background choices
    let avatarColors = [
        "38B2AC", // Teal
        "4DABF7", // Blue
        "BE4BDF", // Magenta
        "FAB005", // Yellow
        "12B886", // Emerald
        "FF6B6B", // Salmon
        "667EEA"  // Indigo
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Premium background gradient
                LinearGradient(
                    colors: [Color.teal.opacity(0.12), Color.purple.opacity(0.08)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 28) {
                        // Live Avatar Preview
                        VStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color(hex: avatarColorHex).opacity(0.85), Color(hex: avatarColorHex)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 100, height: 100)
                                    .shadow(color: Color(hex: avatarColorHex).opacity(0.3), radius: 10, x: 0, y: 6)
                                
                                Text(getInitials(displayName))
                                    .font(.system(size: 32, weight: .bold, design: .rounded))
                                    .foregroundStyle(.white)
                            }
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 3)
                                    .frame(width: 104, height: 104)
                            )
                            
                            Text("Avatar Preview")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(.secondary)
                        }
                        .padding(.top, 16)
                        
                        // Color Selector Section
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Theme Color")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundStyle(.primary)
                                .padding(.horizontal, 4)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 14) {
                                    ForEach(avatarColors, id: \.self) { hex in
                                        Button(action: {
                                            withAnimation(.spring(response: 0.25, dampingFraction: 0.75)) {
                                                avatarColorHex = hex
                                            }
                                        }) {
                                            ZStack {
                                                Circle()
                                                    .fill(Color(hex: hex))
                                                    .frame(width: 38, height: 38)
                                                
                                                if avatarColorHex == hex {
                                                    Circle()
                                                        .stroke(Color.primary, lineWidth: 2)
                                                        .frame(width: 46, height: 46)
                                                }
                                            }
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                        .frame(width: 48, height: 48)
                                    }
                                }
                                .padding(.horizontal, 4)
                            }
                        }
                        
                        // Input Fields
                        VStack(spacing: 18) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Display Name")
                                    .font(.system(size: 13, weight: .bold, design: .rounded))
                                    .foregroundStyle(.secondary)
                                    .padding(.horizontal, 4)
                                
                                CustomTextField(
                                    placeholder: "E.g. Emma Zen",
                                    text: $displayName,
                                    icon: "person"
                                )
                            }
                            
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Username")
                                    .font(.system(size: 13, weight: .bold, design: .rounded))
                                    .foregroundStyle(.secondary)
                                    .padding(.horizontal, 4)
                                
                                CustomTextField(
                                    placeholder: "E.g. emma_zen",
                                    text: $username,
                                    icon: "at"
                                )
                                .textInputAutocapitalization(.never)
                            }
                            
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Bio")
                                    .font(.system(size: 13, weight: .bold, design: .rounded))
                                    .foregroundStyle(.secondary)
                                    .padding(.horizontal, 4)
                                
                                // Text area for Bio with Custom Style matching TextFields
                                TextEditor(text: $bio)
                                    .frame(height: 90)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 8)
                                    .background(Color(.systemBackground).opacity(0.94))
                                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .stroke(Color.secondary.opacity(0.18), lineWidth: 1)
                                    )
                                    .font(.system(size: 15))
                            }
                        }
                    }
                    .padding(24)
                    .padding(.bottom, 60)
                }
                .scrollDismissesKeyboard(.interactively)
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.secondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveChanges()
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(isFormValid() ? .teal : .secondary)
                    .disabled(!isFormValid())
                }
            }
            .onAppear {
                initializeFields()
            }
        }
    }
    
    private func initializeFields() {
        if let currentProfile = viewModel.profile {
            self.displayName = currentProfile.displayName
            self.username = currentProfile.username
            self.bio = currentProfile.bio
            self.avatarColorHex = currentProfile.avatarColorHex
        }
    }
    
    private func isFormValid() -> Bool {
        return !displayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
               !username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private func saveChanges() {
        guard isFormValid() else { return }
        
        let cleanedDisplayName = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let cleanedBio = bio.trimmingCharacters(in: .whitespacesAndNewlines)
        
        viewModel.editProfile(
            displayName: cleanedDisplayName,
            username: cleanedUsername,
            bio: cleanedBio,
            avatarColorHex: avatarColorHex
        )
        
        dismiss()
    }
    
    private func getInitials(_ name: String) -> String {
        let parts = name.split(separator: " ")
        if parts.count >= 2, let first = parts[0].first, let second = parts[1].first {
            return "\(first)\(second)".uppercased()
        } else if let first = name.first {
            return String(first).uppercased()
        }
        return "?"
    }
}

#Preview {
    EditProfileView(viewModel: ProfileViewModel())
}
