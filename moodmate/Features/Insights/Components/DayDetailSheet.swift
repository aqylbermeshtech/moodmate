//
//  DayDetailSheet.swift
//  moodmate
//
//  Created by Nurtore on 26.07.2026.
//

import SwiftUI

struct DayDetailSheet: View {
    let record: MoodRecord
    @Environment(\.dismiss) private var dismiss
    
    private var formattedDateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: record.date)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Capsule()
                .fill(Color.secondary.opacity(0.3))
                .frame(width: 36, height: 5)
                .padding(.top, 10)

            VStack(spacing: 8) {
                Text(formattedDateString)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(.secondary)
                
                ZStack {
                    Circle()
                        .fill(Color(hex: record.colorHex).opacity(0.18))
                        .frame(width: 84, height: 84)
                    
                    Text(record.moodEmoji)
                        .font(.system(size: 52))
                }
                
                Text(record.moodName)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(hex: record.colorHex))
            }

            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Label("Mood Score", systemImage: "star.fill")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                    Spacer()
                    Text("\(record.score) / 6")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(hex: record.colorHex))
                }
                
                Divider()
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("Daily Reflection")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.secondary)
                    
                    Text(record.note ?? "No notes recorded for this date.")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(.primary)
                        .lineSpacing(4)
                }
            }
            .padding(16)
            .background {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.primary.opacity(0.04))
            }
            .padding(.horizontal, 20)
            
            Spacer()

            Button {
                dismiss()
            } label: {
                Text("Close")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background {
                        Capsule()
                            .fill(LinearGradient(colors: [.teal, .teal.opacity(0.85)], startPoint: .leading, endPoint: .trailing))
                            .shadow(color: .teal.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .presentationDetents([.height(420)])
        .presentationCornerRadius(28)
    }
}
