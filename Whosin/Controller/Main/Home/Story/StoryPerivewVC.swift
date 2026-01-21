import UIKit
import AVFoundation
import AVKit
import CoreMedia
import Hero
import GSPlayer
import Alamofire

class StoryPerivewVC: ChildViewController {
    
    @IBOutlet private weak var _offerDateAndDay: UILabel!
    @IBOutlet weak var _shareButtonView: UIVisualEffectView!
    @IBOutlet private weak var _ticketImage: UIImageView!
    @IBOutlet private weak var _ticketTitle: UILabel!
    @IBOutlet private weak var _ticketLocation: UILabel!
    @IBOutlet private weak var _ticketPrice: CustomLabel!
    @IBOutlet private weak var _ticketDescription: UILabel!
    @IBOutlet private weak var _offersTime: UILabel!
    @IBOutlet private weak var _offerSubTitle: UILabel!
    @IBOutlet private weak var _offerTitle: UILabel!
    @IBOutlet private weak var _offerCoverImag: UIImageView!
    @IBOutlet private weak var _offerDetailView: UIView!
    @IBOutlet private weak var _addressLabel: UILabel!
    @IBOutlet private weak var _muteButton: UIButton!
    @IBOutlet private weak var _muteView: UIView!
    @IBOutlet private weak var imagePreview: UIImageView!
    @IBOutlet private weak var userProfileImage: UIImageView!
    @IBOutlet private weak var lblUserName: UILabel!
    @IBOutlet private weak var _playerView: VideoPlayerView!
    @IBOutlet weak var _gradientView: GradientView!
    @IBOutlet weak var _ticketContainerView: UIView!
    @IBOutlet weak var _button: UIButton!
    var heroId: String = String(describing: StoryPerivewVC.self)
    private var _venueId: String = kEmptyString
    private var _offerId: String = kEmptyString
    private var _ticketID: String = kEmptyString
    private var currentStoryId: String = kEmptyString
    var pageIndex : Int = 0
    var items: [VenueDetailModel] = []
    var item: [StoryModel] = []
    var SPB: SegmentedProgressBar!
    var isTapForVenueOrOffer = false

    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUi()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIView.animate(withDuration: 0.8) {
            self.view.transform = .identity
        }
        self.playVideoOrLoadImage(index: 0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        DispatchQueue.main.async {
            self.SPB.currentAnimationIndex = 0
            self.SPB.cancel()
            self.SPB.isPaused = true
            self._playerView?.pause(reason: .hidden)
            self._playerView.isMuted = true
            self._playerView.stateDidChanged = nil
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        DispatchQueue.main.async {
            self._playerView.pause(reason: .hidden)
            self._playerView.isMuted = true
            self._playerView.stateDidChanged = nil
        }
    }
    
    override func setupUi() {
        hideNavigationBar()
        _muteButton.setImage(UIImage(named: "icon_volumehigh"), for: .normal)
        userProfileImage.layer.cornerRadius = self.userProfileImage.frame.size.height / 2;
        if pageIndex < 0 {
            return
        }
        if items.count > pageIndex {
            userProfileImage.loadWebImage(items[pageIndex].logo, name: items[pageIndex].name)
            lblUserName.text = items[pageIndex].name
            _addressLabel.text = items[pageIndex].address
            item = items[pageIndex].storie.toArray(ofType: StoryModel.self)
        }
        
        SPB = SegmentedProgressBar(numberOfSegments: item.count, duration: 5)
        if #available(iOS 11.0, *) {
            SPB.frame = CGRect(x: 18, y: UIApplication.shared.statusBarFrame.height + 5, width: view.frame.width - 35, height: 3)
        } else {
            SPB.frame = CGRect(x: 18, y: 15, width: view.frame.width - 35, height: 3)
        }
        SPB.delegate = self
        SPB.topColor = UIColor.white
        SPB.bottomColor = UIColor.white.withAlphaComponent(0.25)
        SPB.padding = 2
        SPB.isPaused = true
        SPB.currentAnimationIndex = 0
        view.addSubview(SPB)
        view.bringSubviewToFront(SPB)
        
        let tapGestureVideo = UITapGestureRecognizer(target: self, action: #selector(handleVideoViewTap(_:)))
        tapGestureVideo.numberOfTapsRequired = 1
        tapGestureVideo.numberOfTouchesRequired = 1
        _playerView.addGestureRecognizer(tapGestureVideo)
        
        let tapGestureImage = UITapGestureRecognizer(target: self, action: #selector(handleImageViewTap(_:)))
        tapGestureImage.numberOfTapsRequired = 1
        tapGestureImage.numberOfTouchesRequired = 1
        imagePreview.addGestureRecognizer(tapGestureImage)
        
        let longPressRecognizerVideo = UILongPressGestureRecognizer(target: self, action: #selector(_handleLongPressTapEvent(_:)))
        _playerView.addGestureRecognizer(longPressRecognizerVideo)
        
        let longPressRecognizerImage = UILongPressGestureRecognizer(target: self, action: #selector(_handleLongPressTapEvent(_:)))
        imagePreview.addGestureRecognizer(longPressRecognizerImage)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(_handleSwipeGestureEvent))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(_handleSwipeGestureEvent))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(_handlePanGestureEvent(_ :)))
        panGesture.require(toFail: swipeRight)
        panGesture.require(toFail: swipeLeft)
        panGesture.delegate = self
        self.view.addGestureRecognizer(panGesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(enterBackGround), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(enterForGround), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    private func setPlayerListner() {
        _playerView.stateDidChanged = { state in
            
            switch state {
            case .error(_):
                print("Sotry Vidoe status", state)
                self.SPB.skip()
                break
            case .none, .loading:
                self.pauseProgress(true)
                break
            case .paused(_, _):
                self.pauseProgress(true)
                break
            case .playing:
                self.pauseProgress(false)
                break
            @unknown default:
                print("unknown")
            }
        }
    }
    
    private func pauseProgress(_ isForPuase: Bool) {
        DISPATCH_ASYNC_MAIN_AFTER(0.01) {
            if isForPuase {
                if self.SPB.isAnimationStarted && !self.SPB.isPaused {
                    self.SPB.isPaused = true
                }
            } else {
                if self.SPB.isAnimationStarted && self.SPB.isPaused {
                    self.SPB.isPaused = false
                } else if !self.SPB.isAnimationStarted {
                    self.SPB.startAnimation()
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    @objc private func tapOnSkipRight(_ sender: UITapGestureRecognizer) {
        if(pageIndex > 0) {
            contentVC.goPreviousPage(backTo: pageIndex - 1)
        }
    }
    
    @objc private func tapOnSkipLeft(_ sender: UITapGestureRecognizer) {
        if(items.count > pageIndex) {
            contentVC.goNextPage(fowardTo: pageIndex + 1)
        }
    }
    
    @objc private func tapOnnext(_ sender: UITapGestureRecognizer) {
        SPB.skip()
    }
    
    @objc private func handleVideoViewTap(_ gesture: UITapGestureRecognizer) {
        guard !contentVC.isTapInProgress else {
            return
        }
        contentVC.isTapInProgress = true
        let location = gesture.location(in: _playerView)
        let isLeftTap = location.x < _playerView.bounds.width / 2
        if isLeftTap {
            if SPB.currentAnimationIndex == 0  && pageIndex > 0 {
                contentVC.goPreviousPage(backTo: pageIndex - 1)
            }else {
                SPB.rewind()
            }
        } else {
            SPB.skip()
        }
        DISPATCH_ASYNC_MAIN_AFTER(0.5, closure: {
            contentVC.isTapInProgress = false
        })
    }
    
    @objc private func handleImageViewTap(_ gesture: UITapGestureRecognizer) {
        guard !contentVC.isTapInProgress else {
            return
        }
        contentVC.isTapInProgress = true
        let location = gesture.location(in: imagePreview)
        let isLeftTap = location.x < imagePreview.bounds.width / 2
        if isLeftTap {
            if SPB.currentAnimationIndex == 0  && pageIndex > 0 {
                contentVC.goPreviousPage(backTo: pageIndex - 1)
            }else {
                SPB.rewind()
            }
        } else {
            SPB.skip()
        }
        DISPATCH_ASYNC_MAIN_AFTER(0.5, closure: {
            contentVC.isTapInProgress = false
        })
    }
    
    @objc private func _handleLongPressTapEvent(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            UIView.animate(withDuration: 0.05, delay: 0, options: .curveEaseIn, animations: { [weak self] in
                guard self != nil else { return }
            }, completion: { [weak self] _ in
                self?._playerView?.pause(reason: .userInteraction)
                self?.SPB.isPaused = true
            })        }
        else if gestureRecognizer.state == .ended {
            UIView.animate(withDuration: 0.05, delay: 0, options: .curveEaseInOut, animations: { [weak self] in
                guard self != nil else { return }
            }, completion: { [weak self] _ in
                self?._playerView?.resume()
                self?.SPB.isPaused = false
                
            })
        }
    }
    
    @objc private func _handleSwipeGestureEvent(_ sender: UISwipeGestureRecognizer) {
        guard !contentVC.isTapInProgress else {
            return
        }
        contentVC.isTapInProgress = true
        switch sender.direction {
        case .right:
            if(pageIndex > 0) {
                contentVC.goPreviousPage(backTo: pageIndex - 1)
            }
        case .left:
            if(items.count > pageIndex) {
                contentVC.goNextPage(fowardTo: pageIndex + 1)
            }
        default:
            break
        }
        DISPATCH_ASYNC_MAIN_AFTER(0.5, closure: {
            contentVC.isTapInProgress = false
        })
    }
    
    @objc private func _handlePanGestureEvent(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        switch sender.state {
        case .began:
            dismiss(animated: true, completion: nil)
            self._playerView.pause(reason: .hidden)
            self._playerView.isMuted = true
        case .changed:
            Hero.shared.update(translation.y / view.bounds.height)
        default:
            let velocity = sender.velocity(in: view)
            if ((translation.y + velocity.y) / view.bounds.height) > 0.5 {
                Hero.shared.finish()
                self._playerView.pause(reason: .hidden)
            } else {
                Hero.shared.cancel()
            }
        }
    }
    
    @objc private func enterBackGround() {
        DISPATCH_ASYNC_MAIN {
            self._playerView?.pause(reason: .userInteraction)
        }
    }
    
    @objc private func enterForGround() {
        if self.isVisible {
            DISPATCH_ASYNC_MAIN {
                self._playerView?.resume()
                self.SPB.animate()
            }
        }
    }
    
    private func checkDays(_ daysString: String?) -> String {
        let days = daysString?.components(separatedBy: ",")
        
        if days?.count == 7 {
            return "all days"
        } else {
            return daysString ?? ""
        }
    }
    
    
    private func playVideoOrLoadImage(index: NSInteger) {
        if index == (item.count - 1) { Utils.saveViewedStory(id: items[pageIndex].id) }
        var story: StoryModel = StoryModel()
        if !Utils.isStoryViewed(venueId: item[index].venueId, storyId: item[index].id) {
            story = item[index]
        } else {
            if let nextIndex = Utils.getNextUnviewedStoryIndex(venueId: item[index].venueId, stories: item), nextIndex <= item.count {
                story = item[nextIndex]
            } else {
                story = item[index]
            }
        }
        Utils.saveViewedStoryByVenue(venueId: story.venueId, storyId: story.id)

//        let story = item[index]
        currentStoryId = story.id
        self._offerDetailView.isHidden = true
        self._ticketContainerView.isHidden = true
        self._shareButtonView.isHidden = false
        self._gradientView.isHidden = true
        if story.contentType == "offer" {
            if !story.offerId.isEmpty {
                story.offerModel = APPSETTING.offers?.first(where: {$0.id == story.offerId})
                if story.offerModel != nil {
                    UIView.animate(withDuration: 0.05) {
                        self._venueId = story.offerModel?.venueId ?? ""
                        self.view.hero.id = self._venueId+"_open_detail_from_story_view"
                        self.view.hero.modifiers = HeroAnimationModifier.stories
                        self._offerDetailView.isHidden = false
                        self._offerTitle.text = story.offerModel?.title
                        self._offerSubTitle.text = story.offerModel?.descriptions
                        self._offerCoverImag.loadWebImage(story.offerModel?.image ?? "")
                        self._offersTime.text = story.offerModel?.timeSloat
                        self._offerDateAndDay.text = "\(Utils.dateToString(story.offerModel?.startDate, format: kFormatDateLocal)) - \(Utils.dateToString(story.offerModel?.endDate, format: kFormatDateLocal)), \(story.offerModel?.days ?? "")"
                    }
                }
            }
        } else if story.contentType == "ticket" {
            if !story.ticketId.isEmpty {
                story.ticketModel = APPSETTING.ticketList?.first(where: {$0._id == story.ticketId})
                if story.ticketModel != nil {
                    UIView.animate(withDuration: 0.05) {
                        self._ticketID = story.ticketId
                        self._venueId = story.venueId
                        self.view.hero.id = self._venueId+"_open_detail_from_story_view"
                        self.view.hero.modifiers = HeroAnimationModifier.stories
                        self._ticketContainerView.isHidden = false
                        self._shareButtonView.isHidden = true
                        self._ticketTitle.text = story.ticketModel?.title
                        self._ticketDescription.text = Utils.convertHTMLToPlainText(from: story.ticketModel?.descriptions ?? "")
                        self._ticketImage.loadWebImage(story.ticketModel?.images.filter({ !Utils.isVideo($0) }).first ?? "")
                        self._ticketLocation.text = story.ticketModel?.city
                        self._ticketPrice.attributedText = "\("starting_from".localized()) \(Utils.getCurrentCurrencySymbol()) \(story.ticketModel?.startingAmount ?? 0)".withCurrencyFont()
                    }
                }
            }
        } else {
            if !story.buttonText.isEmpty {
                self._gradientView.isHidden = false
                self._button.setTitle(story.buttonText)
            }
        }
        
        
        UIView.animate(withDuration: 0.05) {
            self.imagePreview.isHidden = !story.isImage
        }
        self._venueId = story.venueId
        self._offerId = story.offerId
        self._playerView.isHidden = story.isImage
        self._muteButton.isHidden = story.isImage
        self._muteView.isHidden = story.isImage
        let asset = Double(item[index].duration) ?? 10
        self.SPB.duration = story.isImage ? 10 : asset / 1000.0
        self.SPB.isPaused = true
        if story.isImage {
            self._playerView.stateDidChanged = nil
            if self._playerView.state == .playing {
                self._playerView.pause(reason: .hidden)
            }
            self.imagePreview.loadWebImage(story.mediaUrl) {
                if self.SPB.isAnimationStarted && self.SPB.isPaused {
                    self.SPB.isPaused = false
                } else if !self.SPB.isAnimationStarted {
                    DISPATCH_ASYNC_MAIN_AFTER(0.1) { self.SPB.startAnimation() }
                }
            }
        } else {
            self.setPlayerListner()
            guard var url = URL(string: story.mediaUrl) else { return }
            if let localUrl = Utils.getDownloadedFileURL(fileName: url.lastPathComponent) {
                url = localUrl
            }
            self._playerView.isAutoReplay = false
            self._playerView.contentMode = .scaleAspectFit
            self._playerView.play(for: url)
        }
    }
    
    // --------------------------------------
    // MARK: Events
    // --------------------------------------
    @IBAction func _handleTicketOpenEvent(_ sender: UIButton) {
        print(_ticketID)
        dismiss(animated: true) {
            NotificationCenter.default.post(name: kopenVenueDetailNotification, object:nil,userInfo: ["ticketId": self._ticketID])
        }
    }
    
    @IBAction private func _handleOffersNextClick(_ sender: UIButton) {
        guard !isTapForVenueOrOffer else {
            return
        }
        isTapForVenueOrOffer = true
        dismiss(animated: true) {
            NotificationCenter.default.post(name: kopenVenueDetailNotification, object:nil,userInfo: ["venueId": self._venueId,"offerId": self._offerId])
            
        }
    }
    
    @IBAction private func close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        self._playerView.pause(reason: .hidden)
        NotificationCenter.default.post(name: kReloadStoryyNotification, object: nil)
    }
    
    @IBAction private func _handleVolumeEvent(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        _playerView.isMuted = sender.isSelected
        UIView.transition(with: sender, duration: 0.5, options: .transitionFlipFromLeft) {
            sender.setImage(UIImage(named: sender.isSelected ? "icon_mute" : "icon_volumehigh"), for: .normal)
        }
    }
    
    @IBAction func _openVenue(_ sender: UIButton) {
        if items[pageIndex].type == "ticket" {
            if let pv = self.presentingViewController as? CustomTicketDetailVC, pv.ticketID == self._ticketID {
                dismiss(animated: true)
                return
            }
            dismiss(animated: true) {
                NotificationCenter.default.post(name: kopenVenueDetailNotification, object:nil,userInfo: ["ticketId": self._ticketID])
            }
        } else {
            guard !isTapForVenueOrOffer else {
                return
            }
            isTapForVenueOrOffer = true
            if let pv = self.presentingViewController as? VenueDetailsVC, pv.venueId == self._venueId {
                dismiss(animated: true)
                return
            }
            dismiss(animated: true) {
                NotificationCenter.default.post(name: kopenVenueDetailNotification, object:nil,userInfo: ["venueId": self._venueId])
            }
        }
    }
    
    @IBAction func _handleStroyShareEvent(_ sender: UIButton) {
        let presentedViewController = INIT_CONTROLLER_XIB(ShareBottomSheet.self)
        presentedViewController.veneuDetail = items[pageIndex]
        presentedViewController.currentStoryId = currentStoryId
        presentedViewController.modalPresentationStyle = .overFullScreen
        self.present(presentedViewController, animated: true)
    }
}

// --------------------------------------
// MARK: SegmentedProgressBarDelegate
// --------------------------------------

extension StoryPerivewVC: SegmentedProgressBarDelegate {
    func segmentedProgressBarContentType(index: Int) -> String {
        return "image"
    }
    
    
    func segmentedProgressBarChangedIndex(index: Int) {
        playVideoOrLoadImage(index: index)
    }
    
    func segmentedProgressBarFinished() {
        if pageIndex == (self.items.count - 1) {
            self.dismiss(animated: true, completion: nil)
            NotificationCenter.default.post(name: kReloadStoryyNotification, object: nil)
        }
        else {
            contentVC.goNextPage(fowardTo: pageIndex + 1)
        }
    }
    
}

extension StoryPerivewVC: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer is UISwipeGestureRecognizer || gestureRecognizer is UIPanGestureRecognizer {
            return true
        }
        return false
    }
    
}

