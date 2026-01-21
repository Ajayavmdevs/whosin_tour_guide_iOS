import UIKit
import PlayerKit
import AVKit
import MediaPlayer

protocol AudioCellPlayerDelegate: PlayerDelegate {
    func resetPlayerView()
}

final class AudioCellPlayer {
    
    static let shared = AudioCellPlayer()
    private var audioPlayer: AppMediaPlayer?
    private var session = AVAudioSession.sharedInstance()
    var resetAgain = true
    weak var delegate: AudioCellPlayerDelegate? {
        willSet {
            if newValue !== delegate {
                delegate?.resetPlayerView()
            }
            audioPlayer?.delegate = newValue
        }
    }

    private (set) var audioUrl: String? {
        didSet {
            audioPlayer?.setUrl(audioUrl)
        }
    }
    
    var isValid: Bool { audioPlayer?.isValid ?? false }
    var isLocalAudio: Bool = false
    private init() {
        audioPlayer = AppMediaPlayer()
    }

    // MARK: - Public Methods
    
    func setUrl(_ urlStr: String?) {
        audioUrl = urlStr
    }
    

    func setUp(isLocalAudio: Bool) {
        self.isLocalAudio = isLocalAudio
        audioPlayer?.setIsLocalAudio(isLocalAudio: isLocalAudio)
    }
    
    func setPlayerSeekTo(time: TimeInterval) {
        audioPlayer?.seek(to: time)
    }

    func play() {
        do {
            try? session.setCategory(.playAndRecord, mode: .default, policy: .default, options: [.defaultToSpeaker, .mixWithOthers])
             try session.setActive(true)
        } catch {
            debugPrint("Session file error")
        }
        resetAgain = false
        MPVolumeView.setVolume(0.8)
        audioPlayer?.play()
    }
    
    func getMediaURL() -> String? {
        return audioPlayer?.getMediaURL()
    }

    func isPlaying() -> Bool {
        return audioPlayer?.playing ?? false
    }

    func pause() {
        resetAgain = true
        audioPlayer?.pause()
    }
    
    func resetPlayer() {
        resetAgain = true
        audioPlayer = nil
        audioPlayer = AppMediaPlayer()
    }
}
