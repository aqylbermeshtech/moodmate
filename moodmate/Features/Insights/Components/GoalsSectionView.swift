//
//  GoalsSectionView.swift
//  moodmate
//
//  Created by Nurtore on 26.07.2026.
//

import SwiftUI

struct GoalsSectionView: View {
    let goals: [Goal]
    let onToggleGoal: (Goal) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Tracked Goals")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                    
                    Spacer()
                    
                    Text("\(goals.filter(\.isCompleted).count) / \(goals.count) Completed")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.theme.accent)
                }
                
                Text("Set targets and watch your progress grow")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)
            }

            VStack(spacing: 12) {
                ForEach(goals) { goal in
                    GoalRowCard(goal: goal, onToggle: { onToggleGoal(goal) })
                }
            }
        }
        .padding(18)
        .background {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.theme.surface)
                .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(Color.theme.border, lineWidth: 0.5))
        }
        .shadow(color: .black.opacity(0.04), radius: 10, x: 0, y: 5)
        .padding(.horizontal, 20)
    }
}

private struct GoalRowCard: View {
    let goal: Goal
    let onToggle: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                Button(action: onToggle) {
                    ZStack {
                        Circle()
                            .fill(goal.isCompleted ? Color(hex: goal.colorHex) : Color.primary.opacity(0.06))
                            .frame(width: 38, height: 38)
                        
                        Image(systemName: goal.isCompleted ? "checkmark" : goal.iconName)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(goal.isCompleted ? .white : Color(hex: goal.colorHex))
                    }
                }
                .buttonStyle(.plain)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(goal.title)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                        .strikethrough(goal.isCompleted, color: .secondary)
                    
                    Text(goal.targetDescription)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Text("\(goal.currentValue)/\(goal.targetValue) \(goal.unit)")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(goal.isCompleted ? Color(hex: goal.colorHex) : .secondary)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.primary.opacity(0.06))
                        .frame(height: 6)
                    
                    Capsule()
                        .fill(Color(hex: goal.colorHex))
                        .frame(width: geo.size.width * CGFloat(goal.progressFraction), height: 6)
                }
            }
            .frame(height: 6)
        }
        .padding(12)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.primary.opacity(0.03))
        }
    }
}
