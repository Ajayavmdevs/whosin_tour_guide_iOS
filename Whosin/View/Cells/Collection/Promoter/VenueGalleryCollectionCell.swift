import UIKit
import GSPlayer
import AVFoundation

class VenueGalleryCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var _imageView: UIImageView!
    @IBOutlet weak var _closeBtn: UIButton!
    @IBOutlet weak var _playIcon: UIImageView!
    @IBOutlet weak var _playerView: VideoPlayerView!
    @IBOutlet weak var _volumeView: UIView!
    @IBOutlet weak var _fullScreenView: UIView!
    @IBOutlet weak var _muteButton: UIButton!
    @IBOutlet weak var _fullscreenBtn: UIButton!
    var isVisibleCell: Bool = false
    private var _videoUrl: String = kEmptyString
    
    class var height: CGFloat {
        80
    }
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func prepareForReuse() {
        super.prepareForReuse()
        pauseVideo()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        _playerView.isMuted = isMuteVideo
        _fullScreenView.isHidden = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handlePlayPauseGesture))
        _playerView.addGestureRecognizer(tapGesture)
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
        _fullScreenView.isHidden = true
        _playIcon.isHidden = true
        if imageUrl.isEmpty {
            _imageView.image = UIImage(named: imageName)
        } else {
            _imageView.loadWebImage(imageUrl)
        }
    }
    
    public func setupVideo(videoUrl: String) {
        _fullScreenView.isHidden = false
        _videoUrl = videoUrl
        playVideo()
        DISPATCH_ASYNC_MAIN_AFTER(0.1) {
            if !self.isVisibleCell {
                self.pauseVideo()
            }
        }
        _playerView.contentMode = .scaleAspectFill
        _playerView.cornerRadius = 10
        _imageView.isHidden = true
        _playerView.isHidden = false
        _volumeView.isHidden = false
        _fullScreenView.isHidden = false
        _muteButton.isSelected = isMuteVideo
        _muteButton.setImage(UIImage(named: isMuteVideo ? "icon_mute" : "icon_volumehigh"), for: .normal)
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
        self._playerView.isAutoReplay = true
        self._playerView.play(for: url)
        self._playerView.isMuted = isMuteVideo
        self._playIcon.image = UIImage(systemName: "icon_playBlure")
        self._playIcon.isHidden = false
        self._fullScreenView.isHidden = false
        DISPATCH_ASYNC_MAIN_AFTER(1.0) {
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
            DISPATCH_ASYNC_MAIN_AFTER(0.02) {
                self.playVideo()
            }
        } else {
            _playerView?.resume()
        }
    }
    
    // --------------------------------------
    // MARK: Events
    // --------------------------------------

    @IBAction func _handleVolumeEvent(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        _playerView.isMuted = sender.isSelected
        isMuteVideo = sender.isSelected
        UIView.transition(with: sender, duration: 0.5, options: .transitionFlipFromLeft) {
            sender.setImage(UIImage(named: sender.isSelected ? "icon_mute" : "icon_volumehigh"), for: .normal)
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
    
    @IBAction func _handleFullScreenEvent(_ sender: UIButton) {
        pauseVideo()
        let vc = INIT_CONTROLLER_XIB(LandscapeVideoVC.self)
        vc._videoUrl = self._videoUrl
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        parentViewController?.navigationController?.present(vc, animated: true)
    }
    
}
