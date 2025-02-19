import SwiftUI

@main
struct IntervalTrainerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(WorkoutManager())
        }
    }
}
