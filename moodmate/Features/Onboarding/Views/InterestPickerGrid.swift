//
//  InterestPickerGrid.swift
//  moodmate
//
//  The interest catalog rendered as grouped, wrapping chips. Shared by the
//  onboarding screen and the edit-profile sheet so both stay in step.
//

import SwiftUI

struct InterestPickerGrid: View {
    let selectedIds: Set<String>
    var onToggle: (Interest) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            ForEach(InterestGroup.allCases) { group in
                VStack(alignment: .leading, spacing: 12) {
                    Text(group.title.uppercased())
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.theme.secondaryText)

                    FlowLayout(spacing: 8, lineSpacing: 10) {
                        ForEach(InterestCatalog.interests(in: group)) { interest in
                            InterestChip(
                                interest: interest,
                                isSelected: selectedIds.contains(interest.id),
                                onTap: { onToggle(interest) }
                            )
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ScrollView {
        InterestPickerGrid(selectedIds: ["yoga", "reading", "coffee"], onToggle: { _ in })
            .padding(20)
    }
    .background(Color.theme.primaryBackground)
}
