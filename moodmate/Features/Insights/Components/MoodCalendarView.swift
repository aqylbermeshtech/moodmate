//
//  MoodCalendarView.swift
//  moodmate
//
//  Created by Nurtore on 26.07.2026.
//

import SwiftUI

struct MoodCalendarView: View {
    let currentMonth: Date
    let entries: [String: MoodRecord]
    let onNavigateMonth: (Int) -> Void
    let onSelectDate: (Date) -> Void
    
    private let daysOfWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    private let calendar = Calendar.current
    
    private var monthYearTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentMonth)
    }
    
    private var datesInMonth: [Date?] {
        guard let range = calendar.range(of: .day, in: .month, for: currentMonth) else { return [] }
        
        var comp = calendar.dateComponents([.year, .month], from: currentMonth)
        comp.day = 1
        guard let firstDayOfMonth = calendar.date(from: comp) else { return [] }
        
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth) // 1 (Sun) to 7 (Sat)
        let leadingPadding = firstWeekday - 1
        
        var result: [Date?] = Array(repeating: nil, count: leadingPadding)
        
        for day in range {
            comp.day = day
            if let date = calendar.date(from: comp) {
                result.append(date)
            }
        }
        
        return result
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            headerView
            weekdayHeaderView
            calendarGridView
        }
        .padding(18)
        .background(cardBackground)
        .shadow(color: Color.theme.shadow, radius: 10, x: 0, y: 5)
        .padding(.horizontal, 20)
    }
    
    // MARK: - Subviews
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Monthly Mood Calendar")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.theme.primaryText)
                
                Text(monthYearTitle)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(.teal)
            }
            
            Spacer()
            
            HStack(spacing: 8) {
                Button {
                    onNavigateMonth(-1)
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color.theme.primaryText)
                        .padding(8)
                        .background(Color.theme.groupedBackground)
                        .clipShape(Circle())
                }
                
                Button {
                    onNavigateMonth(1)
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color.theme.primaryText)
                        .padding(8)
                        .background(Color.theme.groupedBackground)
                        .clipShape(Circle())
                }
            }
        }
    }
    
    private var weekdayHeaderView: some View {
        HStack(spacing: 0) {
            ForEach(daysOfWeek, id: \.self) { day in
                Text(day)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.theme.secondaryText)
                    .frame(maxWidth: .infinity)
            }
        }
    }
    
    private var calendarGridView: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 7), spacing: 8) {
            ForEach(0..<datesInMonth.count, id: \.self) { index in
                if let date = datesInMonth[index] {
                    let dateKey = formatDateKey(date)
                    let record = entries[dateKey]
                    dayCellView(for: date, record: record)
                } else {
                    Color.clear
                        .frame(height: 46)
                }
            }
        }
    }
    
    private func dayCellView(for date: Date, record: MoodRecord?) -> some View {
        Button {
            onSelectDate(date)
        } label: {
            VStack(spacing: 2) {
                Text("\(calendar.component(.day, from: date))")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(record != nil ? Color.theme.primaryText : Color.theme.tertiaryText)
                
                if let record = record {
                    Text(record.moodEmoji)
                        .font(.system(size: 14))
                } else {
                    Circle()
                        .fill(Color.theme.divider)
                        .frame(width: 4, height: 4)
                        .padding(.vertical, 4)
                }
            }
            .frame(height: 46)
            .frame(maxWidth: .infinity)
            .background(cellBackground(for: record))
        }
        .buttonStyle(.plain)
    }
    
    private func cellBackground(for record: MoodRecord?) -> some View {
        let fillColor = record.map { Color.adaptiveMoodColor(hex: $0.colorHex).opacity(0.18) } ?? Color.theme.groupedBackground
        let strokeColor = record.map { Color.adaptiveMoodColor(hex: $0.colorHex).opacity(0.4) } ?? Color.clear
        
        return RoundedRectangle(cornerRadius: 12, style: .continuous)
            .fill(fillColor)
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(strokeColor, lineWidth: 1)
            )
    }
    
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 24, style: .continuous)
            .fill(Color.theme.cardBackground)
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(Color.theme.border, lineWidth: 1)
            )
    }
    
    private func formatDateKey(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
