import Foundation

struct SunlightReading: Equatable, Sendable {
    let red: Int
    let green: Int
    let blue: Int
    let date: Date

    static let zero = SunlightReading(red: 0, green: 0, blue: 0, date: .distantPast)

    var average: Double {
        Double(red + green + blue) / 3.0
    }

    var percentage: Int {
        Int((average / 255.0 * 100.0).rounded()).clamped(to: 0...100)
    }

    var level: SunlightLevel {
        switch average {
        case ..<85: .low
        case ..<170: .medium
        default: .high
        }
    }
}

enum SunlightLevel: Int, CaseIterable, Sendable {
    case low
    case medium
    case high

    var title: String {
        switch self {
        case .low: "Low"
        case .medium: "Medium"
        case .high: "High"
        }
    }

    var symbolName: String {
        switch self {
        case .low: "cloud.sun"
        case .medium: "sun.min.fill"
        case .high: "sun.max.fill"
        }
    }
}

extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        min(max(self, limits.lowerBound), limits.upperBound)
    }
}
