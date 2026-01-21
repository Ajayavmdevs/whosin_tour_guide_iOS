import AVKit

enum AudioPlayerSounds {
    case start
    case end
    case error
}

/**
 This class design and implemented to create audio player to play audio file
 */
class AudioPlayer: NSObject {
    
    /// Audio player
    private var player: AVAudioPlayer?
    /// Audio did finished playing callback
    var didFinishPlaying: ((Bool) -> Void)?

    /// Initialize audio player
    override init() {
        player = AVAudioPlayer()
    }

    /// Play audio file
    /// - Parameter soundType: Sound type
    public func playAudioFile(soundType: AudioPlayerSounds) {
        didFinishPlaying = nil
        
        let bundle = Bundle.main
        
        guard let url = bundle.url(forResource: getPathByType(soundType: soundType), withExtension: "wav") else {
            debugPrint("error getting Sound URL")
            return
        }

        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .mixWithOthers])
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(.speaker)
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
            
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.wav.rawValue)
            player?.delegate = self
            player?.prepareToPlay()
            player?.play()
        } catch {
            debugPrint("could not play audio file!")
        }

    }

    /// Get audio file path
    /// - Parameter soundType: Sout
    /// - Returns: Sound file path
    private func getPathByType(soundType: AudioPlayerSounds) -> String {
        switch soundType {
        case .start:
            return "record_start"
        case .end:
            return "record_finished"
        case .error:
            return "record_error"
        }
    }

}

extension AudioPlayer: AVAudioPlayerDelegate {
    
    /// Tells the delegate when the audio finishes playing.
    /// - Parameters:
    ///   - player: The audio player that finishes playing.
    ///   - flag: A boolean value that indicates whether the audio finishes playing successfully.
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        didFinishPlaying?(flag)
        didFinishPlaying = nil
    }
}
