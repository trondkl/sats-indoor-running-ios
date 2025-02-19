import SwiftUI

struct ContentView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @State private var sessionCode: String = ""
    @State private var showInvalidCodeAlert = false

    var body: some View {
        NavigationView {
            if let session = workoutManager.session {
                SessionView(session: session)
                    .navigationBarHidden(true)
            } else {
                VStack(spacing: 24) {
                    Image("sats_logo") // You'll need to add this to your asset catalog
                        .resizable()
                        .scaledToFit()
                        .frame(height: 60)

                    Text("SATS Indoor Running")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Øktkode")
                            .font(.headline)

                        TextField("Skriv inn 6-sifret kode", text: $sessionCode)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.numberPad)
                            .font(.title2)
                            .multilineTextAlignment(.center)
                            .onChange(of: sessionCode) { newValue in
                                // Limit to 6 digits
                                if newValue.count > 6 {
                                    sessionCode = String(newValue.prefix(6))
                                }
                                // Remove non-numeric characters
                                sessionCode = newValue.filter { $0.isNumber }
                            }
                    }
                    .padding(.horizontal)

                    Button(action: {
                        if sessionCode.count == 6 {
                            workoutManager.joinSession(code: sessionCode)
                        } else {
                            showInvalidCodeAlert = true
                        }
                    }) {
                        Text("Start økt")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .alert(isPresented: $showInvalidCodeAlert) {
                        Alert(
                            title: Text("Ugyldig kode"),
                            message: Text("Vennligst skriv inn en 6-sifret kode"),
                            dismissButton: .default(Text("OK"))
                        )
                    }
                }
                .padding()
                .navigationBarHidden(true)
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(WorkoutManager())
}