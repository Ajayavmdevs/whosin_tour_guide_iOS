import UIKit
import AVFoundation
import AVKit
import CoreMedia
import SnapKit
import GSPlayer

class PromotionalBannerCollectionCell: UICollectionViewCell {

    @IBOutlet weak var _imageView: UIView!
    @IBOutlet weak var _thumbnailImage: UIImageView!
    @IBOutlet weak var _bannerImage: UIImageView!
    @IBOutlet weak var _titleText: CustomLabel!
    @IBOutlet weak var _subTitleText: CustomLabel!
    @IBOutlet private weak var _muteButton: UIButton!
    @IBOutlet private weak var _contentView: UIView!
    @IBOutlet private weak var _viewButton: UIButton!
    @IBOutlet private weak var _playerView: VideoPlayerView!
    private var isVisibleCell: Bool = false
    @IBOutlet weak var _replyView: UIView!
    
    private var _heroId: String = kEmptyString
    private var _ticketId: String = kEmptyString
    private var meadiUrl: String = kEmptyString
    private var timeObserver: Any?
    public var _videoModel: BannerModel?

    
    // --------------------------------------
    // MARK: Life cycle
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
        _muteButton.isSelected = isMuteVideo
        DISPATCH_ASYNC_MAIN_AFTER(0.01) {
            self._viewButton.cornerRadius = self._viewButton.layer.frame.size.height / 2
        }
        setupVideoPlayer()
        setupUi()
    }
    
    deinit {
        pauseVideo()
    }

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
    
    public func setupData(_ data: BannerModel, url: String) {
        _titleText.text = data.title
        _subTitleText.text = data.descriptions
        _videoModel = data
        _viewButton.setTitle(data.buttonText, for: .normal)
        _viewButton.backgroundColor = UIColor(hexString: data.buttonTint).withAlphaComponent(0.3)
        _viewButton.titleLabel?.textColor = UIColor(hexString: data.buttonTint)
        _viewButton.setTitleColor(UIColor(hexString: data.buttonTint), for: .normal)
        meadiUrl = url
        if !Utils.isVideo(url) {
            _contentView.isHidden = true
            _imageView.isHidden = false
            _bannerImage.loadWebImage(url)
        } else if Utils.isVideo(url) {
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
    
    private func _openURL(urlString: String) {
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    private func _openActivity(id: String, name: String) {
        let vc = INIT_CONTROLLER_XIB(ActivityInfoVC.self)
        vc.activityId = id
        vc.activityName = name
        parentViewController?.navigationController?.pushViewController(vc, animated: true)
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
        } else if object.type == "link" {
            _openURL(urlString: object.typeId)
        } else if object.type == "activity" {
            _openActivity(id: object.typeId, name: "")
        } else if object.type == "venue" {
            let vc = INIT_CONTROLLER_XIB(VenueDetailsVC.self)
            vc.venueId = object.typeId
            parentViewController?.navigationController?.pushViewController(vc, animated: true)
        } else if object.type == "offer" {
            let vc = INIT_CONTROLLER_XIB(OfferPackageDetailVC.self)
            vc.offerId = object.typeId
            vc.modalPresentationStyle = .overFullScreen
            vc.vanueOpenCallBack = { venueId, venueModel in
                let vc = INIT_CONTROLLER_XIB(VenueDetailsVC.self)
                vc.venueId = venueId
                vc.venueDetailModel = venueModel
                self.parentViewController?.navigationController?.pushViewController(vc, animated: true)
            }
            vc.buyNowOpenCallBack = { offer, venue, timing in
                let vc = INIT_CONTROLLER_XIB(BuyPackgeVC.self)
                vc.isFromActivity = false
                vc.type = "offers"
                vc.timingModel = timing
                vc.offerModel = offer
                vc.venue = venue
                vc.setCallback {
                    let controller = INIT_CONTROLLER_XIB(MyCartVC.self)
                    controller.modalPresentationStyle = .overFullScreen
                    self.parentViewController?.navigationController?.pushViewController(controller, animated: true)
                }
                self.parentViewController?.navigationController?.pushViewController(vc, animated: true)
            }
            self.parentViewController?.presentAsPanModal(controller: vc)
        }
    }
    
    @IBAction private func _handleMuteUnmuteEvent(_ sender: UIButton) {
        muteUnMute(!sender.isSelected)
    }
    
}
