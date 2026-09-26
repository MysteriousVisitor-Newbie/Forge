import Foundation
import SwiftData
import SwiftUI

@Model
final class Project {
    var name: String
    var colorHex: String
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \TaskItem.project)
    var tasks: [TaskItem] = []

    init(name: String, colorHex: String = "F97316") {
        self.name = name
        self.colorHex = colorHex
        self.createdAt = .now
    }

    var color: Color {
        Color(hex: colorHex)
    }

    var activeCount: Int {
        tasks.filter { !$0.isCompleted }.count
    }

    var completedCount: Int {
        tasks.filter(\.isCompleted).count
    }
}

extension Color {
    init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&int)
        let r, g, b: UInt64
        switch cleaned.count {
        case 6:
            (r, g, b) = ((int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (249, 115, 22)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: 1
        )
    }
}
