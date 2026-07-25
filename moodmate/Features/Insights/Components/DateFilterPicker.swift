//
//  DateFilterPicker.swift
//  moodmate
//
//  Created by Nurtore on 26.07.2026.
//

import SwiftUI

struct DateFilterPicker: View {
    @Binding var selectedFilter: DateFilter
    @Namespace private var filterAnimation
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(DateFilter.allCases) { filter in
                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                            selectedFilter = filter
                        }
                    } label: {
                        Text(filter.displayName)
                            .font(.system(size: 13, weight: selectedFilter == filter ? .bold : .medium, design: .rounded))
                            .foregroundStyle(selectedFilter == filter ? Color.white : Color.primary.opacity(0.7))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background {
                                if selectedFilter == filter {
                                    Capsule()
                                        .fill(
                                            LinearGradient(
                                                colors: [Color.teal, Color.teal.opacity(0.85)],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .matchedGeometryEffect(id: "DATE_FILTER_CAPSULE", in: filterAnimation)
                                        .shadow(color: Color.teal.opacity(0.3), radius: 6, x: 0, y: 3)
                                } else {
                                    Capsule()
                                        .fill(Color.primary.opacity(0.06))
                                }
                            }
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Select filter: \(filter.displayName)")
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 4)
        }
    }
}

#Preview {
    ZStack {
        Color.black.opacity(0.05).ignoresSafeArea()
        DateFilterPicker(selectedFilter: .constant(.month))
    }
}
