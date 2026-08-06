//
//  AvatarPickerSheet.swift
//  moodmate
//
//  Created by Antigravity on 31.07.2026.
//

import SwiftUI
import PhotosUI

enum ImagePickerSourceType: Identifiable {
    case library
    case camera
    
    var id: String {
        switch self {
        case .library: return "library"
        case .camera: return "camera"
        }
    }
}

struct CameraPickerView: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = UIImagePickerController.isSourceTypeAvailable(.camera) ? .camera : .photoLibrary
        picker.allowsEditing = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraPickerView
        
        init(_ parent: CameraPickerView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let editedImage = info[.editedImage] as? UIImage {
                parent.selectedImage = editedImage
            } else if let originalImage = info[.originalImage] as? UIImage {
                parent.selectedImage = originalImage
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

struct AvatarPickerOptionsView: View {
    let hasCustomAvatar: Bool
    let onSelectLibrary: () -> Void
    let onSelectCamera: () -> Void
    let onRemoveAvatar: () -> Void
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Capsule()
                .fill(Color.theme.secondaryText.opacity(0.3))
                .frame(width: 38, height: 5)
                .padding(.top, 10)
            
            Text("Profile Photo")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(Color.theme.primaryText)
            
            VStack(spacing: 12) {
                Button(action: {
                    dismiss()
                    onSelectLibrary()
                }) {
                    HStack(spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(Color.teal.opacity(0.12))
                                .frame(width: 44, height: 44)
                            Image(systemName: "photo.on.rectangle")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(.teal)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Choose from Library")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(Color.theme.primaryText)
                            Text("Select an existing photo")
                                .font(.system(size: 12))
                                .foregroundStyle(Color.theme.secondaryText)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color.theme.secondaryText)
                    }
                    .padding(14)
                    .background(Color.theme.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.theme.border, lineWidth: 1)
                    )
                }
                .buttonStyle(ScaleButtonStyle())

                Button(action: {
                    dismiss()
                    onSelectCamera()
                }) {
                    HStack(spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(Color.purple.opacity(0.12))
                                .frame(width: 44, height: 44)
                            Image(systemName: "camera.fill")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(.purple)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Take Photo")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(Color.theme.primaryText)
                            Text("Use your camera now")
                                .font(.system(size: 12))
                                .foregroundStyle(Color.theme.secondaryText)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color.theme.secondaryText)
                    }
                    .padding(14)
                    .background(Color.theme.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.theme.border, lineWidth: 1)
                    )
                }
                .buttonStyle(ScaleButtonStyle())

                if hasCustomAvatar {
                    Button(action: {
                        dismiss()
                        onRemoveAvatar()
                    }) {
                        HStack(spacing: 14) {
                            ZStack {
                                Circle()
                                    .fill(Color.red.opacity(0.12))
                                    .frame(width: 44, height: 44)
                                Image(systemName: "trash.fill")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundStyle(.red)
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Remove Current Photo")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundStyle(.red)
                                Text("Revert to color initials")
                                    .font(.system(size: 12))
                                    .foregroundStyle(Color.theme.secondaryText)
                            }
                            Spacer()
                        }
                        .padding(14)
                        .background(Color.theme.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(Color.red.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
            }
            .padding(.horizontal, 20)
            
            Button("Cancel") {
                dismiss()
            }
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(Color.theme.secondaryText)
            .padding(.top, 4)
            .padding(.bottom, 24)
        }
        .background(Color.theme.backgroundGradient.ignoresSafeArea())
    }
}
