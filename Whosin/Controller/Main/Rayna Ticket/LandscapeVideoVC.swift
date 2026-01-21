
import UIKit
import GSPlayer

class LandscapeVideoVC: ChildViewController {

    @IBOutlet weak var _playerView: VideoPlayerView!
    @IBOutlet weak var _playIcon: UIImageView!
    @IBOutlet weak var _volumeView: UIView!
    @IBOutlet weak var _muteButton: UIButton!
    public var _videoUrl: String = kEmptyString

    override func viewDidLoad() {
        super.viewDidLoad()
        _playerView.isMuted = isMuteVideo
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handlePlayPauseGesture))
        _playerView.addGestureRecognizer(tapGesture)
        UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
        UIViewController.attemptRotationToDeviceOrientation()

        NotificationCenter.default.addObserver(self, selector: #selector(enterBackGround), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(enterForGround), name: UIApplication.didBecomeActiveNotification, object: nil)
        playVideo()
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    @objc private func enterBackGround() {
        pauseVideo()
    }
    
    @objc private func enterForGround() {
        resumeVideo()
    }
    
    private func playVideo() {
        guard var url = URL(string: _videoUrl) else {
            return
        }
        if let localUrl = Utils.getDownloadedFileURL(fileName: url.lastPathComponent) {
            url = localUrl
        }
        self._playerView.isAutoReplay = true
        self._playerView.play(for: url)
        self._playerView.isMuted = isMuteVideo
        self._volumeView.isHidden = false
        self._playIcon.image = UIImage(systemName: "icon_playBlure")
        self._playIcon.isHidden = false
        self._muteButton.isSelected = isMuteVideo
        self._muteButton.setImage(UIImage(named: isMuteVideo ? "icon_mute" : "icon_volumehigh"), for: .normal)
        DISPATCH_ASYNC_MAIN_AFTER(1.0) {
            self._playIcon.isHidden = true
        }
    }

    public func pauseVideo() {
        self._playerView.pause(reason: .hidden)
    }
    
    public func resumeVideo() {
        _playIcon.isHidden = true
        if _playerView?.state == .playing || _playerView?.state == .loading {
            return
        }
        if _playerView?.state == VideoPlayerView.State.none {
            DISPATCH_ASYNC_MAIN_AFTER(0.02) {
                self.playVideo()
            }
        } else {
            _playerView?.resume()
        }
    }

    @objc private func handlePlayPauseGesture() {
        if _playerView.state == .playing {
            _playIcon.image = UIImage(named: "icon_pauseBlure")
            self._playIcon.isHidden = false
            pauseVideo()
        } else {
            self._playIcon.image = UIImage(named: "icon_playBlure")
            resumeVideo()
            _playIcon.isHidden = false
            DISPATCH_ASYNC_MAIN_AFTER(1.0) {
                self._playIcon.isHidden = true
            }
        }
    }
    
    @IBAction func _handleVolumeEvent(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        _playerView.isMuted = sender.isSelected
        isMuteVideo = sender.isSelected
        UIView.transition(with: sender, duration: 0.5, options: .transitionFlipFromLeft) {
            sender.setImage(UIImage(named: sender.isSelected ? "icon_mute" : "icon_volumehigh"), for: .normal)
        }
    }

    @IBAction func _handleBackArrow(_ sender: UIButton) {
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        UIViewController.attemptRotationToDeviceOrientation()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.dismiss(animated: true, completion: nil)
        }
    }
}
