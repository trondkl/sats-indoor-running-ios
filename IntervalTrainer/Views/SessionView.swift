import SwiftUI

struct SessionView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    let session: WorkoutSession

    private var currentInterval: Interval? {
        guard session.intervals.indices.contains(session.currentInterval) else { return nil }
        return session.intervals[session.currentInterval]
    }

    private var nextInterval: Interval? {
        guard let current = currentInterval,
              session.intervals.indices.contains(session.currentInterval + 1) else { return nil }
        return session.intervals[session.currentInterval + 1]
    }

    private var progress: Double {
        guard let interval = currentInterval else { return 0 }
        let elapsed = workoutManager.elapsedTime
        var timeSum: TimeInterval = 0

        // Find start time of current interval
        for (index, int) in session.intervals.enumerated() {
            if index == session.currentInterval {
                let timeInInterval = elapsed - timeSum
                return min(timeInInterval / Double(int.duration), 1.0)
            }
            timeSum += Double(int.duration)
        }
        return 0
    }

    var body: some View {
        VStack(spacing: 20) {
            // Header
            Text(session.name)
                .font(.title)
                .fontWeight(.bold)

            if workoutManager.isCompleted {
                completedView
            } else {
                activeSessionView
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }

    private var activeSessionView: some View {
        VStack(spacing: 24) {
            // Progress circle
            ZStack {
                Circle()
                    .stroke(lineWidth: 20)
                    .opacity(0.3)
                    .foregroundColor(currentInterval?.type.color ?? .gray)

                Circle()
                    .trim(from: 0.0, to: progress)
                    .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round))
                    .foregroundColor(currentInterval?.type.color ?? .gray)
                    .rotationEffect(Angle(degrees: 270.0))
                    .animation(.linear(duration: 1.0), value: progress)

                VStack(spacing: 8) {
                    if let interval = currentInterval {
                        Text(interval.displayName)
                            .font(.title2)
                            .fontWeight(.semibold)

                        Text(formatTime(Int(workoutManager.elapsedTime)))
                            .font(.system(size: 64, weight: .bold, design: .monospaced))
                            .foregroundColor(interval.type.color)
                    }

                    if workoutManager.countdownSeconds <= 5 && workoutManager.countdownSeconds > 0 {
                        Text("\(workoutManager.countdownSeconds)")
                            .font(.title)
                            .foregroundColor(.red)
                            .transition(.scale)
                    }
                }
            }
            .frame(height: 300)

            // Next interval preview
            if let next = nextInterval {
                VStack(spacing: 8) {
                    Text("Neste:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Text(next.displayName)
                        .font(.title3)
                        .foregroundColor(next.type.color)

                    Text(formatTime(next.duration))
                        .font(.headline)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }

            // Control buttons
            HStack(spacing: 20) {
                Button(action: { workoutManager.togglePause() }) {
                    Image(systemName: workoutManager.isPaused ? "play.circle.fill" : "pause.circle.fill")
                        .font(.system(size: 44))
                        .foregroundColor(.primary)
                }

                Button(action: { workoutManager.endSession() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 44))
                        .foregroundColor(.red)
                }
            }
        }
    }

    private var completedView: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 100))
                .foregroundColor(.green)

            Text("Økten er fullført!")
                .font(.title)
                .fontWeight(.bold)

            Text("Total tid: \(formatTime(Int(workoutManager.elapsedTime)))")
                .font(.title2)
        }
    }

    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
}

// Helper extension for safe array access
extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

// Preview provider
struct SessionView_Previews: PreviewProvider {
    static var previews: some View {
        let mockSession = WorkoutSession(
            code: "TEST123",
            name: "Test Økt",
            intervals: [
                Interval(type: .warmup, duration: 300, name: nil),
                Interval(type: .intensive, duration: 60, name: "Sprint"),
                Interval(type: .break_, duration: 30, name: nil),
                Interval(type: .cooldown, duration: 300, name: nil)
            ],
            currentInterval: 0,
            isActive: true,
            startTime: Date().timeIntervalSince1970 * 1000
        )

        SessionView(session: mockSession)
            .environmentObject(WorkoutManager())
    }
}