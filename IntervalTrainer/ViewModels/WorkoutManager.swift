import Foundation
import AVFoundation

class WorkoutManager: ObservableObject {
    @Published var session: WorkoutSession?
    @Published var elapsedTime: TimeInterval = 0
    @Published var isPaused: Bool = false
    @Published var isCompleted: Bool = false
    @Published var countdownSeconds: Int = 5

    private var timer: Timer?
    private var startTime: Date?
    private let soundManager = SoundManager.shared
    private let websocket: WebSocket

    init() {
        self.websocket = WebSocket()
    }

    func joinSession(code: String) {
        websocket.joinSession(code) { [weak self] session in
            DispatchQueue.main.async {
                self?.session = session
                if session.isActive && !self?.isPaused ?? false {
                    self?.startTimer()
                }
            }
        }
    }

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self,
                  let session = self.session,
                  let startTime = session.startTime else { return }

            let elapsed = Date().timeIntervalSince1970 - TimeInterval(startTime) / 1000
            self.elapsedTime = elapsed

            // Check if we need to start countdown for next interval
            self.checkAndUpdateInterval()
        }
    }

    private func checkAndUpdateInterval() {
        guard let session = session else { return }

        // Calculate current interval and time within interval
        var timeSum: TimeInterval = 0
        var currentIntervalStartTime: TimeInterval = 0

        for (index, interval) in session.intervals.enumerated() {
            if timeSum + TimeInterval(interval.duration) > elapsedTime {
                // We're in this interval
                if index != session.currentInterval {
                    // Interval changed
                    websocket.updateSession(code: session.code, currentInterval: index)
                    soundManager.playSound(for: interval.type)

                    // If next interval exists, start countdown when 5 seconds remain
                    if let nextInterval = session.intervals[safe: index + 1] {
                        let timeLeftInInterval = (timeSum + TimeInterval(interval.duration)) - elapsedTime
                        if timeLeftInInterval <= 5 {
                            countdownSeconds = Int(timeLeftInInterval)
                            soundManager.playCountdown()
                        }
                    }
                }
                break
            }
            currentIntervalStartTime = timeSum
            timeSum += TimeInterval(interval.duration)
        }

        // Check if workout is complete
        if elapsedTime >= timeSum {
            websocket.updateSession(code: session.code, isActive: false)
            isCompleted = true
            timer?.invalidate()
            soundManager.playSound(for: .cooldown) // Play completion sound
        }
    }

    func togglePause() {
        isPaused.toggle()
        if isPaused {
            timer?.invalidate()
        } else {
            startTimer()
        }

        if let session = session {
            websocket.updateSession(code: session.code, isActive: !isPaused)
        }
    }

    func endSession() {
        timer?.invalidate()
        if let session = session {
            websocket.updateSession(code: session.code, isActive: false)
        }
        isCompleted = true
    }
}