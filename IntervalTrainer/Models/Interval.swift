import Foundation

enum IntervalType: String, Codable {
    case warmup
    case intensive
    case break_
    case cooldown
    
    var displayName: String {
        switch self {
        case .warmup: return "Oppvarming"
        case .intensive: return "Intensiv"
        case .break_: return "Pause"
        case .cooldown: return "Nedkjøling"
        }
    }
    
    var color: Color {
        switch self {
        case .warmup: return .orange
        case .intensive: return .red
        case .break_: return .green
        case .cooldown: return .blue
        }
    }
}

struct Interval: Codable, Identifiable {
    var id: UUID = UUID()
    let type: IntervalType
    let duration: Int
    let name: String?
    
    var displayName: String {
        if type == .warmup { return "Oppvarming" }
        if type == .cooldown { return "Nedkjøling" }
        if type == .break_ { return duration >= 60 ? "Aktiv pause" : "Pause" }
        return name ?? "Intensiv"
    }
}
