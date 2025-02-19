import Foundation

struct WorkoutSession: Codable {
    let code: String
    let name: String
    let intervals: [Interval]
    var currentInterval: Int
    var isActive: Bool
    var startTime: TimeInterval?
    
    var totalDuration: Int {
        intervals.reduce(0) { $0 + $1.duration }
    }
    
    var isCompleted: Bool {
        currentInterval >= intervals.count
    }
    
    enum CodingKeys: String, CodingKey {
        case code, name, intervals, currentInterval, isActive, startTime
    }
}

// JSON encoding/decoding for WebSocket communication
extension WorkoutSession {
    static func decode(from data: Data) throws -> WorkoutSession {
        let decoder = JSONDecoder()
        return try decoder.decode(WorkoutSession.self, from: data)
    }
    
    func encode() throws -> Data {
        let encoder = JSONEncoder()
        return try encoder.encode(self)
    }
}
