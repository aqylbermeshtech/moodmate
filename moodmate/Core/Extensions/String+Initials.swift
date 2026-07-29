import Foundation

func getInitials(_ name: String = "", fallback: String = "?") -> String {
    let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
    let parts = trimmedName.split(separator: " ", omittingEmptySubsequences: true)

    if parts.count >= 2,
       let first = parts[0].first,
       let second = parts[1].first {
        return "\(first)\(second)".uppercased()
    } else if let first = trimmedName.first {
        return String(first).uppercased()
    }

    return fallback
}
