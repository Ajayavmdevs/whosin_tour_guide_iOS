import UIKit
import PlayerKit
import AVKit
import MediaPlayer
import AVFoundation

final class AppMediaPlayer: RegularPlayer {
    
    private let defaultEmptyURl = "x.x.x"
    private var isLocalAudio: Bool = false
    
    private (set) var videoURLString: String? {
        didSet {
            MPVolumeView.setVolume(0.8)
            if isLocalAudio {
                if let videoURLString = videoURLString {
                    let videoURL = URL(fileURLWithPath: videoURLString)
                    self.set(AVURLAsset(url: videoURL))
                }
            } else {
                if let videoURLString = videoURLString, let videoURL = URL(string: videoURLString) {
                    self.set(AVURLAsset(url: videoURL))
                
                }
            }
        }
    }
    
    var isValid: Bool {
        videoURLString != defaultEmptyURl
    }
    
    func setIsLocalAudio(isLocalAudio: Bool) {
        self.isLocalAudio = isLocalAudio
    }
    
    func setUrl(_ urlStr: String?) {
        videoURLString = urlStr
    }
    
    func reset() {
        videoURLString = defaultEmptyURl
    }
    
    func getMediaURL() -> String? {
        return videoURLString
    }
}
