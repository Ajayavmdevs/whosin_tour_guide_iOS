import UIKit
import AVFoundation
import AVKit
import CoreMedia
import SnapKit
import GSPlayer

class VideoComponentTableCell: UITableViewCell {
    
    @IBOutlet weak var _venueInfoView: CustomVenueInfoView!
    @IBOutlet private weak var _topShadow: GradientView!
    @IBOutlet private weak var _titleLabel: UILabel!
    @IBOutlet private weak var _muteButton: UIButton!
    @IBOutlet private weak var _progressView: UIView!
    @IBOutlet private weak var _contentView: UIView!
    @IBOutlet private weak var _viewButton: UIButton!
    @IBOutlet private weak var _playerView: VideoPlayerView!
    @IBOutlet weak var _thumbnailImageView: UIImageView!
    @IBOutlet weak var _replyView: UIView!

    private var videoList: [VideosModel] = []
    private var progressBar: SegmentedProgressBar!
    private var isVisibleCell: Bool = false
    private var _currentVenueId : String = kEmptyString
    private var _heroId: String = kEmptyString
    private var _venueId: String = kEmptyString
    private var _ticketID: String = kEmptyString
    private var _venueDetailModel: VenueDetailModel?
    private var _ticketModel: TicketModel?
    private var timeObserver: Any?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        disableSelectEffect()
        self._viewButton.cornerRadius = self._viewButton.layer.frame.size.height / 2
        setupVideoPlayer()
        setupUi()
    }
    
//    override func layoutSubviews() {}
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat {
        600
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------

    private func setupVideoPlayer() {
        _playerView?.isAutoReplay = false
        if _playerView != nil {
            _playerView.stateDidChanged = nil
        }
        _playerView?.stateDidChanged = { [weak self] state in
            guard let self = self else { return }
            switch state {
            case .playing:
                self._thumbnailImageView.isHidden = true
                self.pauseProgress(false)

            case .none, .loading:
                self._thumbnailImageView.isHidden = false
                self.pauseProgress(true)

            case .paused(_, _):
                // show thumbnail only if user paused manually (not mid-progress)
                self._thumbnailImageView.isHidden = false
                self.pauseProgress(true)

            case .error(_):
                self._thumbnailImageView.isHidden = false
                self.progressBar?.skip()

            @unknown default:
                break
            }
        }

        
    }
    
    private func pauseProgress(_ isForPuase: Bool) {
        if isForPuase {
            if self.progressBar.isAnimationStarted && !self.progressBar.isPaused {
                self.progressBar?.isPaused = true
            }
        } else {
            if self.progressBar.isAnimationStarted && self.progressBar.isPaused {
                self.progressBar?.isPaused = false
            } else if !self.progressBar.isAnimationStarted {
                self.progressBar?.startAnimation()
            }
        }
    }
    
    private func setupProgressBar(){
        _progressView.layoutIfNeeded()
        if progressBar != nil {
            progressBar.removeFromSuperview()
            progressBar = nil
        }
        
        progressBar = SegmentedProgressBar(numberOfSegments: videoList.count, duration: 5)
        progressBar.frame = _progressView.bounds
        _progressView.addSubview(progressBar)
        
        _contentView.bringSubviewToFront(_progressView)
        progressBar.delegate = self
        progressBar.topColor = UIColor.white
        progressBar.bottomColor = UIColor.white.withAlphaComponent(0.25)
        progressBar.padding = 2
        progressBar.isPaused = true
    
    }
    
    private func setupVenueDetail(_ model: VideosModel){
        var url = URL(string: model.videoUrl)!
        if let localUrl = Utils.getDownloadedFileURL(fileName: url.lastPathComponent) {
            _thumbnailImageView.isHidden = true
        }
        if let venueModel = model.venueModel, !Utils.stringIsNullOrEmpty(model.venueId) {
            _venueInfoView.isHidden = false
            _viewButton.isHidden = false
            _venueInfoView.setupData(venue: venueModel, isAllowClick: false)
            _venueDetailModel = venueModel
            _venueId = venueModel.id
            _heroId = venueModel.id + model.id
            _currentVenueId = venueModel.id
            _contentView.hero.id = venueModel.id+"_open_detail_video_component"
            _contentView.hero.modifiers = HeroAnimationModifier.stories
            _thumbnailImageView.loadWebImage(model.thumb)
        } else if let ticket = model.ticketModel, !Utils.stringIsNullOrEmpty(model.ticketId) {
            _venueInfoView.isHidden = false
            _viewButton.isHidden = false
            _venueInfoView.setupTicketData(ticket)
            _ticketModel = ticket
            _ticketID = ticket._id
            _heroId = ticket._id + model.id
            _currentVenueId = ticket._id
//            _contentView.hero.id = ticket._id+"_open_detail_video_component"
//            _contentView.hero.modifiers = HeroAnimationModifier.stories
            _thumbnailImageView.loadWebImage(model.thumb)
        } else {
            _venueInfoView.isHidden = true
            _viewButton.isHidden = true
            _venueInfoView.setupEmptyData()
            _venueDetailModel = nil
            _venueId = kEmptyString
            return
        }
    }
    
    private func setupUi(){
        self._contentView.cornerRadius = 15
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleVideoViewTap(_:)))
        _playerView?.addGestureRecognizer(tapGesture)

        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(handleVideoViewTap(_:)))
        _topShadow.addGestureRecognizer(tapGesture2)
        
        let longPressRecognizerVideo = UILongPressGestureRecognizer(target: self, action: #selector(_handleLongPressTapEvent(_:)))
        _playerView?.addGestureRecognizer(longPressRecognizerVideo)

    }
    
    private func playVideo(_ index: NSInteger) {
        _replyView.isHidden = true
        DispatchQueue.main.async { [weak self] in
            guard let self = self, self.videoList.indices.contains(index) else {
                self?._playerView?.pause(reason: .userInteraction)
                self?._thumbnailImageView.isHidden = false
                return
            }
            
            let _videoMode = self.videoList[index]
            self.setupVenueDetail(_videoMode)
            
            var url = URL(string: _videoMode.videoUrl)!
            if let localUrl = Utils.getDownloadedFileURL(fileName: url.lastPathComponent) {
                url = localUrl
            }
            
            let duration = Double(_videoMode.duration)
            self.progressBar?.duration = duration / 1000.0
            
            // show thumbnail until playback actually starts
            _thumbnailImageView.isHidden = false
            _playerView?.play(for: url)
            _playerView?.isMuted = _muteButton.isSelected
            
            timeObserver = _playerView?.addPeriodicTimeObserver(
                forInterval: CMTime(value: 1, timescale: 20),
                queue: .main
            ) { [weak self] time in
                guard let self = self else { return }
                if self._playerView?.state == .playing {
                    self._thumbnailImageView.isHidden = true
                    self.progressBar?.updateProgress(progress: Float(self._playerView?.playProgress ?? 0.0))
                }
            }
        }
    }
    
    private func muteUnMute(_ isMute: Bool = true) {
        _muteButton.isSelected = isMute
        isMuteVideo = isMute
        _playerView?.isMuted = isMute
        UIView.transition(with: _muteButton, duration: 0.5, options: .transitionFlipFromLeft) {
            self._muteButton.setImage(UIImage(named: isMute ? "icon_mute" : "icon_volumehigh"), for: .normal)
        }
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setupData(_ data: HomeBlockModel) {
        videoList = data.videoList 
        _titleLabel.text = data.title
//        if let firstVideo = videoList.first {
//            setupVenueDetail(firstVideo)
//            _thumbnailImageView.isHidden = false
//            _thumbnailImageView.loadWebImage(firstVideo.thumb)
//            setupProgressBar()
//            progressBar?.isPaused = true
//        }
    }
    
    public func pauseVideo() {
        isVisibleCell = false
        if _playerView?.state == .playing {
            _playerView?.pause(reason: .hidden)
            self.progressBar?.isPaused = true
        }
    }
    
//    public func resumeVideo() {
//        if isVisibleCell { return }
//        isVisibleCell = true
//        if _playerView?.state == .playing || _playerView?.state == .loading {
//            return
//        }
//        if _playerView?.state == VideoPlayerView.State.none {
//            self.setupProgressBar()
//            self.playVideo(0)
//            self.muteUnMute(isMuteVideo)
//        } else {
//            _playerView?.resume()
//            self.progressBar?.isPaused = false
//        }
//    }
    
    public func resumeVideo() {
        guard !isVisibleCell else { return }
        isVisibleCell = true
        
        // If player is already playing or loading, do nothing
        guard let playerState = _playerView?.state else { return }
        if playerState == .playing || playerState == .loading {
            return
        }

        // Execute heavy or UI-affecting code on main queue (but async)
        DispatchQueue.main.async {
            if playerState == .none {
                self.setupProgressBar()
                self.playVideo(0)
                self.muteUnMute(isMuteVideo)
            } else {
                self._playerView?.resume()
                self.progressBar?.isPaused = false
            }
        }
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    @objc private func tapOn(_ sender: UITapGestureRecognizer) {
        progressBar?.skip()
    }
    
    @objc private func handleVideoViewTap(_ gesture: UITapGestureRecognizer) {
        guard let playerView = _playerView, let progressBar = progressBar else { return }
        let location = gesture.location(in: playerView)
        let isLeftTap = location.x < playerView.bounds.width / 2

        if isLeftTap {
            progressBar.rewind()
        } else {
            progressBar.skip()
        }
    }
    
    @objc private func _handleLongPressTapEvent(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            UIView.animate(withDuration: 0.02, delay: 0, options: .curveEaseIn, animations: { [weak self] in
                guard self != nil else { return }
            }, completion: { [weak self] _ in
                self?._playerView?.pause(reason: .userInteraction)
                self?.progressBar?.isPaused = true
            })        }
        else if gestureRecognizer.state == .ended {
            UIView.animate(withDuration: 0.02, delay: 0, options: .curveEaseInOut, animations: { [weak self] in
                guard self != nil else { return }
            }, completion: { [weak self] _ in
                self?._playerView?.resume()
                self?.progressBar?.isPaused = false
                
            })
        }
    }
    
    @IBAction private func _handleReplyVideoEvent(_ sender: UIButton) {
        DISPATCH_ASYNC_MAIN_AFTER(0.02) {
            self._playerView?.replay()
            self._replyView.isHidden = true
        }
    }
    
    
    @IBAction private func _handelViewEvent(_ sender: UIButton) {
        _playerView?.pause(reason: .hidden)
        self.progressBar?.isPaused = true
        parentBaseController?.feedbackGenerator?.impactOccurred()
        if !Utils.stringIsNullOrEmpty(_ticketID) {
            let vc = INIT_CONTROLLER_XIB(CustomTicketDetailVC.self)
            vc.ticketID = self._ticketID
            vc.hidesBottomBarWhenPushed = false
            parentViewController?.navigationController?.pushViewController(vc, animated: true)
        } else {
        }
    }
    
    @IBAction private func _handleMuteUnmuteEvent(_ sender: UIButton) {
        muteUnMute(!sender.isSelected)
    }
    
}

// --------------------------------------
// MARK: SegmentedProgressBarDelegate
// --------------------------------------

extension VideoComponentTableCell: SegmentedProgressBarDelegate {
    func segmentedProgressBarContentType(index: Int) -> String {
        return "video"
    }
    
    func segmentedProgressBarChangedIndex(index: Int) {
        playVideo(index)
    }
    
    func segmentedProgressBarFinished() {
        _playerView?.pause(reason: .userInteraction)
        _playerView?.seek(to: .zero)

        // If there’s another video, skip to it
        if let currentIndex = progressBar?.currentAnimationIndex,
           currentIndex < (videoList.count - 1) {
            progressBar?.skip()
        } else {
            // Last video finished → show thumbnail + reply option
            _thumbnailImageView.isHidden = false
            _replyView.isHidden = false
        }
    }
}

