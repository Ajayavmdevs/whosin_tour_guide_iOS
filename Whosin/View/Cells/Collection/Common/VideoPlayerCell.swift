import UIKit
import GSPlayer
import AVFoundation

class VideoPlayerCell: UICollectionViewCell {
    
    @IBOutlet weak var _playIcon: UIImageView!
    @IBOutlet weak var _playerView: VideoPlayerView!
    @IBOutlet weak var _fullscreenBtn: UIButton!
    var isVisibleCell: Bool = false
    private var _videoUrl: String = kEmptyString
    private var adModel: AdListModel?
    public var videoEnded: (() -> Void)?
    private var hasEnded = false
    
    class var height: CGFloat {
        80
    }
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func prepareForReuse() {
        super.prepareForReuse()
        pauseVideo()
        _playerView.stateDidChanged = nil
        isVisibleCell = false
        hasEnded = false
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        _playerView.isMuted = isMuteVideo
        _fullscreenBtn.isHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(enterBackGround), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(enterForGround), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    @objc private func enterBackGround() {
        let isVisible = Bool(self.isVisibleCell)
        pauseVideo()
        isVisibleCell = isVisible
    }
    
    @objc private func enterForGround() {
        if isVisibleCell {
            resumeVideo()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        pauseVideo()
    }
    
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setupData(_ imageName: String = "imge_defaultBanner", imageUrl:String = kEmptyString) {
        _fullscreenBtn.isHidden = true
        _playIcon.isHidden = true
    }
    
    public func setupVideo(videoUrl: AdListModel) {
        Utils.addLog(screen: "ad_load", object: videoUrl)
        adModel = videoUrl
        if _playerView != nil {
            _playerView.stateDidChanged = nil
        }
        
        _playerView?.stateDidChanged = { state in
            switch state {
            case .error(_):
                break
            case .none, .loading:
                break
            case .paused(let progress, let endValue):
                let totalDuration = self._playerView.player?.totalDuration ?? 0
                if !self.hasEnded && (Int(progress * 100) == 100) {
                    self.hasEnded = true
                    self.videoEnded?()
                }
                break
            case .playing:
                break
            @unknown default:
                print("unknown")
            }
        }
        
        _fullscreenBtn.isHidden = false
        _videoUrl = videoUrl.video
        DISPATCH_ASYNC_MAIN_AFTER(0.1) {
            if !self.isVisibleCell {
                self.pauseVideo()
            }
        }
        playVideo()
        _playerView.contentMode = .scaleAspectFit
        _playerView.cornerRadius = 10
        _playerView.isHidden = false
        _fullscreenBtn.isHidden = false
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func playVideo() {
        guard var url = URL(string: _videoUrl) else {
            return
        }
        if let localUrl = Utils.getDownloadedFileURL(fileName: url.lastPathComponent) {
            url = localUrl
        }
        self._playerView.isAutoReplay = false
        self._playerView.play(for: url)
        hasEnded = false
        self._playerView.isMuted = isMuteVideo
        self._playIcon.image = UIImage(systemName: "icon_playBlure")
        self._playIcon.isHidden = false
        self._fullscreenBtn.isHidden = false
        DISPATCH_ASYNC_MAIN_AFTER(0.5) {
            self._playIcon.isHidden = true
        }
    }
    
    public func pauseVideo() {
        isVisibleCell = false
        self._playerView.pause(reason: .hidden)
    }
    
    public func resumeVideo() {
        self.isVisibleCell = true
        _playIcon.isHidden = true
        if _playerView?.state == .playing || _playerView?.state == .loading {
            return
        }
        if _playerView?.state == VideoPlayerView.State.none {
            self.playVideo()
        } else {
            _playerView?.resume()
        }
    }
    
    
    // --------------------------------------
    // MARK: Events
    // --------------------------------------
    
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
    
    @IBAction func _handleFullScreenEvent(_ sender: UIButton) {
        pauseVideo()
        if let model = adModel {
            Utils.addLog(screen: "ad_fullScreen", object: model)
        }
        let vc = INIT_CONTROLLER_XIB(LandscapeVideoVC.self)
        vc._videoUrl = self._videoUrl
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(vc, animated: true)
        }
    }
    
}
