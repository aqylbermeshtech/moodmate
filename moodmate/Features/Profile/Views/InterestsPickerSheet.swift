//
//  InterestsPickerSheet.swift
//  moodmate
//
//  Edit-profile's route back into the interest catalog. Edits apply straight
//  to the bound view model; they reach disk with the rest of the form on Save.
//

import SwiftUI

struct InterestsPickerSheet: View {
    let selectedIds: Set<String>
    var onToggle: (Interest) -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color.theme.primaryBackground
                    .ignoresSafeArea()

                ScrollView {
                    InterestPickerGrid(
                        selectedIds: selectedIds,
                        onToggle: { interest in
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                onToggle(interest)
                            }
                        }
                    )
                    .padding(20)
                }
                .scrollIndicators(.hidden)
            }
            .navigationTitle("Interests")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .font(.xButton)
                }
            }
        }
    }
}

#Preview {
    InterestsPickerSheet(selectedIds: ["yoga", "coffee"], onToggle: { _ in })
}
