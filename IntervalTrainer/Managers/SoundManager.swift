import AVFoundation

class SoundManager {
    static let shared = SoundManager()
    private var audioPlayers: [String: AVAudioPlayer] = [:]
    
    private init() {
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }
    
    func playSound(for intervalType: IntervalType) {
        var soundName: String
        
        switch intervalType {
        case .warmup:
            soundName = "warmup_start"
        case .intensive:
            soundName = "interval_start"
        case .break_:
            soundName = "break_start"
        case .cooldown:
            soundName = "cooldown_start"
        }
        
        guard let url = Bundle.main.url(forResource: soundName, withExtension: "wav") else {
            print("Could not find sound file: \(soundName)")
            return
        }
        
        do {
            if audioPlayers[soundName] == nil {
                audioPlayers[soundName] = try AVAudioPlayer(contentsOf: url)
            }
            
            audioPlayers[soundName]?.play()
        } catch {
            print("Failed to play sound \(soundName): \(error)")
        }
    }
    
    func playCountdown() {
        guard let url = Bundle.main.url(forResource: "countdown", withExtension: "wav") else { return }
        
        do {
            if audioPlayers["countdown"] == nil {
                audioPlayers["countdown"] = try AVAudioPlayer(contentsOf: url)
            }
            
            audioPlayers["countdown"]?.play()
        } catch {
            print("Failed to play countdown sound: \(error)")
        }
    }
}
