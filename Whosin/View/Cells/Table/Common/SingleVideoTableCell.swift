import UIKit
import AVFoundation
import AVKit
import CoreMedia
import SnapKit
import GSPlayer

class SingleVideoTableCell: UITableViewCell {
    
    @IBOutlet weak var _videoHeight: NSLayoutConstraint!
    @IBOutlet weak var _imageHeight: NSLayoutConstraint!
    @IBOutlet weak var _imageView: UIView!
    @IBOutlet weak var _thumbnailImage: UIImageView!
    @IBOutlet weak var _bannerImage: UIImageView!
    @IBOutlet weak var _titleText: CustomLabel!
    @IBOutlet weak var _subTitleText: CustomLabel!
    @IBOutlet private weak var _titleLabel: UILabel!
    @IBOutlet weak var _subTitleLable: CustomLabel!
    @IBOutlet weak var _startingFromValue: CustomLabel!
    @IBOutlet private weak var _muteButton: UIButton!
    @IBOutlet private weak var _contentView: UIView!
    @IBOutlet private weak var _viewButton: UIButton!
    @IBOutlet private weak var _playerView: VideoPlayerView!
    @IBOutlet weak var _viewBtn: UIButton!
    private var isVisibleCell: Bool = false
    @IBOutlet weak var _replyView: UIView!
    
    private var _heroId: String = kEmptyString
    private var _ticketId: String = kEmptyString
    private var meadiUrl: String = kEmptyString
    private var timeObserver: Any?
    public var _videoModel: ExploreBannerModel?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        disableSelectEffect()
        _muteButton.isSelected = isMuteVideo
        DISPATCH_ASYNC_MAIN_AFTER(0.01) {
            self._viewButton.cornerRadius = self._viewButton.layer.frame.size.height / 2
        }
        setupVideoPlayer()
        setupUi()
    }
    
    override func layoutSubviews() {}
    
    deinit {
        pauseVideo()
    }
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------

    
    class var height: CGFloat {
        UITableView.automaticDimension
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------

    private func setupVideoPlayer() {
        _playerView?.isAutoReplay = false
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
                self._replyView.isHidden = progress < endValue
                if progress >= endValue {
                    self.generateVideoThumbnailAsync()
                }
                break
            case .playing:
                break
            @unknown default:
                print("unknown")
            }
        }
        
    }
    
    private func setupUi(){
        DISPATCH_ASYNC_MAIN_AFTER(0.2) {
            self._contentView.cornerRadius = 10
        }
        
        let longPressRecognizerVideo = UILongPressGestureRecognizer(target: self, action: #selector(_handleLongPressTapEvent(_:)))
        _playerView?.addGestureRecognizer(longPressRecognizerVideo)

    }
    
    private func playVideo() {
        _replyView.isHidden = true
        self._thumbnailImage.isHidden = true
        guard var url = URL(string: meadiUrl) else {
            return
        }
        if let localUrl = Utils.getDownloadedFileURL(fileName: url.lastPathComponent) {
            url = localUrl
        }
        print("vidoe url================================",url)
        self._playerView?.play(for: url)
        self._playerView?.isMuted = _muteButton.isSelected
        timeObserver = _playerView?.addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: 20), queue: .main) { time in
            if self._playerView?.state == .playing {
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
        _titleText.text = data.title
        _subTitleText.text = data.descriptions
        _titleText.isHidden = !data.showTitle
        _subTitleText.isHidden = !data.showTitle
        guard let model = data.exploreVideoComponent.first(where: { $0.id == data.exploreCustomComponents.last }) else { return }
        _videoModel = model
        _titleLabel.text = model.title
        _subTitleLable.text = model.subTitle
        _viewBtn.setTitle(model.buttonText, for: .normal)
        _viewBtn.backgroundColor = UIColor(hexString: model.buttonColor)
        _startingFromValue.text = model.descriptions
        meadiUrl = model.media
        let height = Utils.parseRatio(data.size?.ratio ?? "16:9")
        _imageHeight.constant = kScreenWidth / height
        _videoHeight.constant = kScreenWidth / height
        if model.mediaType == "image" {
            _contentView.isHidden = true
            _imageView.isHidden = false
            _bannerImage.loadWebImage(model.media)
        } else if model.mediaType == "video" {
            _contentView.isHidden = false
            _imageView.isHidden = true
            _replyView.isHidden = true
            playVideo()
        }
    }
    
    public func pauseVideo() {
        isVisibleCell = false
        if _playerView?.state == .playing {
            _playerView?.pause(reason: .hidden)
        }
    }
    
    public func resumeVideo() {
        if isVisibleCell { return }
        _replyView.isHidden = true
        self._thumbnailImage.isHidden = true
        isVisibleCell = true
        if _playerView?.state == .playing || _playerView?.state == .loading {
            return
        }
        if _playerView?.state == VideoPlayerView.State.none {
            DISPATCH_ASYNC_MAIN_AFTER(0.02) {
                self.playVideo()
                self.muteUnMute(isMuteVideo)
            }
        } else {
            _playerView?.resume()
        }
    }
    
    private func generateVideoThumbnailAsync() {
        guard let url = URL(string: meadiUrl) else {
            print("Invalid URL: \(meadiUrl)")
            return
        }

        let asset = AVAsset(url: url)
        
        asset.loadValuesAsynchronously(forKeys: ["duration", "tracks"]) {
            var error: NSError? = nil

            // Ensure asset is ready
            let durationStatus = asset.statusOfValue(forKey: "duration", error: &error)
            let tracksStatus = asset.statusOfValue(forKey: "tracks", error: &error)

            guard durationStatus == .loaded, tracksStatus == .loaded else {
                return
            }

            // Calculate a safe mid-point time for thumbnail (e.g. 10% in)
            let duration = asset.duration
            let thumbnailTime = CMTimeMultiplyByFloat64(duration, multiplier: 0.1)

            let imageGenerator = AVAssetImageGenerator(asset: asset)
            imageGenerator.appliesPreferredTrackTransform = true
            imageGenerator.requestedTimeToleranceBefore = .zero
            imageGenerator.requestedTimeToleranceAfter = .zero

            do {
                let cgImage = try imageGenerator.copyCGImage(at: thumbnailTime, actualTime: nil)
                let uiImage = UIImage(cgImage: cgImage)

                DispatchQueue.main.async {
                    self._thumbnailImage.isHidden = self._replyView.isHidden
                    self._thumbnailImage.image = uiImage
                }
            } catch {
                print("Failed to generate thumbnail: \(error.localizedDescription)")
            }
        }
    }


    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    @objc private func _handleLongPressTapEvent(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            UIView.animate(withDuration: 0.02, delay: 0, options: .curveEaseIn, animations: { [weak self] in
                guard self != nil else { return }
            }, completion: { [weak self] _ in
                self?._playerView?.pause(reason: .userInteraction)
            })
        }
        else if gestureRecognizer.state == .ended {
            UIView.animate(withDuration: 0.02, delay: 0, options: .curveEaseInOut, animations: { [weak self] in
                guard self != nil else { return }
            }, completion: { [weak self] _ in
                self?._playerView?.resume()
            })
        }
    }
    
    @IBAction private func _handleReplyVideoEvent(_ sender: UIButton) {
        self._replyView.isHidden = true
        DISPATCH_ASYNC_MAIN_AFTER(0.02) {
            self._playerView?.replay()
            self._replyView.isHidden = true
        }
    }
    
    
    @IBAction private func _handelViewEvent(_ sender: UIButton) {
        _playerView?.pause(reason: .hidden)
        parentBaseController?.feedbackGenerator?.impactOccurred()
        guard let object = _videoModel else { return }
        if (object.type == "ticket") {
            let vc = INIT_CONTROLLER_XIB(CustomTicketDetailVC.self)
            vc.ticketID = object.typeId
            vc.hidesBottomBarWhenPushed = true
            parentViewController?.navigationController?.pushViewController(vc, animated: true)
        } else if (object.type == "category") {
            let controller = INIT_CONTROLLER_XIB(ExploreDetailVC.self)
            controller.selectedFilter = object.typeId
            controller.titleText = APPSETTING.exploreCategories?.first(where: { $0.id == object.typeId })?.title ?? object.title
            controller.hidesBottomBarWhenPushed = false
            parentViewController?.navigationController?.pushViewController(controller, animated: true)
        } else if (object.type == "city") {
            let controller = INIT_CONTROLLER_XIB(ExploreDetailVC.self)
            controller.isFromCities = true
            controller.selectedFilter = object.typeId
            controller.titleText = APPSETTING.cityList?.first(where: { $0.id == object.typeId })?.name ?? object.title
            controller.hidesBottomBarWhenPushed = false
            parentViewController?.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    @IBAction private func _handleMuteUnmuteEvent(_ sender: UIButton) {
        muteUnMute(!sender.isSelected)
    }
    
}

