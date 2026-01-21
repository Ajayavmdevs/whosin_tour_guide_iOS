import UIKit
import ExpandableLabel
import MessageUI
import MapKit
import MediaBrowser
import CoreMedia


class VenueDetailsTableCell: UITableViewCell {
    
    @IBOutlet private weak var _followButton: CustomActivityButton!
    @IBOutlet private weak var _bgView: GradientView!
    @IBOutlet private weak var _venueDesc: UILabel!
    @IBOutlet private weak var _venueTitle: UILabel!
    @IBOutlet private weak var _logoImageView: UIImageView!
    @IBOutlet private weak var _galaryContainerView: UIView!
    @IBOutlet private weak var _galaryImageCount: UILabel!
    @IBOutlet private weak var _galaryCountView: UIView!
    @IBOutlet private var _imageViews: [UIImageView]!
    @IBOutlet private weak var _coverImage: UIImageView!
    @IBOutlet private weak var _openCloseLabel: UILabel!
    @IBOutlet private weak var _timeLabel: UILabel!
    @IBOutlet private weak var _featuresLabel: UILabel!
    @IBOutlet private weak var _cuisineLabel: UILabel!
    @IBOutlet private weak var _musicLabel: UILabel!
    @IBOutlet private weak var _themeLabel: UILabel!
    @IBOutlet private weak var _distanceLabel: UILabel!
    @IBOutlet private weak var _dressCodeLabel: UILabel!
    @IBOutlet private weak var _timeStack: UIStackView!
    @IBOutlet private weak var _featuresStack: UIStackView!
    @IBOutlet private weak var _cusineStack: UIStackView!
    @IBOutlet private weak var _musicStack: UIStackView!
    @IBOutlet private weak var _dressCodeStack: UIStackView!
    @IBOutlet private weak var _themeStack: UIStackView!
    @IBOutlet private weak var _menuButton: UIButton!
    @IBOutlet private weak var _backButton: UIButton!
    @IBOutlet private weak var _safeHeight: NSLayoutConstraint!
    @IBOutlet private weak var _recommededIcon: UIImageView!
    @IBOutlet weak var _recommendText: UILabel!
    @IBOutlet weak var _frequencyStack: UIStackView!
    @IBOutlet weak var _frequency: CustomLabel!
    private var venueDetailModel: VenueDetailModel?
    private var imageArray: [String] = []
    private var _galaryArrayList = [Media]()
    private var _offers: [OffersModel] = []
    var completion: (() -> Void)?
    public var followStateCallBack: ((_ follow: Bool) -> Void)?

    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    static var height: CGFloat { UITableView.automaticDimension }
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUi()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // --------------------------------------
    // MARK: Service
    // --------------------------------------
    
    private func _requestFollowUnfollow() {
        _followButton.setTitle(kEmptyString)
        _followButton.showActivity()
        guard let _venue = venueDetailModel else { return }
        WhosinServices.venueFollows(id: _venue.id) { [weak self] container, error in
            guard let self = self else { return }
            self._followButton.hideActivity()
            _venue.isFollowing = !_venue.isFollowing
            self._followButton.setTitle(_venue.isFollowing ? "following".localized() : "follow".localized())
            self.followStateCallBack?(_venue.isFollowing)
            NotificationCenter.default.post(name: .changeVenueFollowState, object: nil)
            self.parentBaseController?.showSuccessMessage(_venue.isFollowing ? "thank_you".localized() : "oh_snap".localized(), subtitle: _venue.isFollowing ? LANGMANAGER.localizedString(forKey: "follow_venue", arguments: ["value": _venue.name]) : LANGMANAGER.localizedString(forKey: "unfollow_venue", arguments: ["value": _venue.name]))
        }
    }
    
    private func _requestAddRecommendation() {
        parentBaseController?.showHUD()
        guard let _venue = venueDetailModel else { return }
        WhosinServices.addRecommendation(id: _venue.id, type: "venue") { [weak self] container, error in
            guard let self = self else { return }
            self.parentBaseController?.hideHUD()
            guard let data = container else { return }
            _venue.isRecommendation = !_venue.isRecommendation
            self._recommededIcon.tintColor =  _venue.isRecommendation ? ColorBrand.brandBtnBgColor : ColorBrand.white
            self._recommendText.text = _venue.isRecommendation ? "recommended".localized() : "recommend".localized()
            let msg = _venue.isRecommendation ? LANGMANAGER.localizedString(forKey: "recommending_toast", arguments: ["value": _venue.name]) : LANGMANAGER.localizedString(forKey: "recommending_remove_toast", arguments: ["value": _venue.name])
            self.parentBaseController?.showSuccessMessage(_venue.isRecommendation ? "thank_you".localized() : "oh_snap".localized(), subtitle: msg)
        }
    }
    
    private func _requestSetFrequeny(days: Int) {
        parentBaseController?.showHUD()
        guard let _venue = venueDetailModel else { return }
        WhosinServices.setFrequencyForCmVisit(venueId: _venue.id, days: days) { [weak self] container, error in
            guard let self = self else { return }
            self.parentBaseController?.hideHUD()
            guard let data = container else { return }
            if data.code == 1 {
                self.parentBaseController?.showSuccessMessage("frequency_updated".localized(), subtitle: kEmptyString)
                NotificationCenter.default.post(name: kRelaodActivitInfo, object: nil)
                
            }
        }
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func setupUi() {
        disableSelectEffect()
        imageArray.removeAll()
        let img = UIImage(named: "icon_backArrow")?.withRenderingMode(.alwaysTemplate)
        _backButton.setImage(img, for: .normal)
        _backButton.tintColor = .white
        if let statusBarHeight = APP.window?.windowScene?.statusBarManager?.statusBarFrame.height {
            _safeHeight.constant = statusBarHeight
        } else {
            _safeHeight.constant = 20
        }
    }
    
    private func _loadData() {
        _followUnfollowToggle()
        _galaryImageSetup()
        _validationsEmptyData()
        guard let _venue = venueDetailModel else { return }
        _recommededIcon.tintColor =  _venue.isRecommendation ? ColorBrand.brandBtnBgColor : ColorBrand.white
        _recommendText.text = _venue.isRecommendation ? "recommended".localized() : "recommend".localized()
        _venueDesc.text = _venue.address
        _venueTitle.text = _venue.name
        _logoImageView.loadWebImage(_venue.logo)
        if APPSESSION.userDetail?.isPromoter == true {
            _frequencyStack.isHidden = !APPSETTING.myVenueList.contains { $0.id == _venue.id }
        } else {
            _frequencyStack.isHidden = true
        }
        _frequency.text = "\(_venue.frequencyOfVisitForCm)"
        _distanceLabel.text = String(format: "%.2f", _venue.distance) + " km"
        _timingLogic(_venue.isOpen)
    }
    
    private func _followUnfollowToggle() {
        guard let isFollowing = self.venueDetailModel?.isFollowing else { return }
        _followButton.setTitle( isFollowing ? "following".localized() : "follow".localized())
    }
    
    private func _galaryImageSetup() {
        imageArray.removeAll()
        venueDetailModel?.galleries.forEach { image in
            imageArray.append(image)
        }
        if !Utils.stringIsNullOrEmpty(venueDetailModel?.cover) { imageArray.insert(venueDetailModel?.cover ?? "", at: 0) }
        if !imageArray.isEmpty {
            configureImageViews(imageViews: _imageViews, galaryImages: imageArray)
            _galaryArrayList.removeAll()
            imageArray.forEach { image in
                if let media = Utils.webMediaPhoto(url: image, caption: nil) {
                    _galaryArrayList.append(media)
                }
            }
        } else {
            _galaryContainerView.isHidden = true
        }
        
        _coverImage.loadWebImage(venueDetailModel?.cover ?? "") {
            do {
                self._bgView.startColor = try self._coverImage.image?.averageColor() ?? ColorBrand.brandPink
            } catch {
                
            }
        }
    }
    
    private func _timingLogic(_ isOpen: Bool) {
        _openCloseLabel.text = isOpen ? "open".localized() : "close".localized()
        _openCloseLabel.textColor = isOpen ? .green : .red
        
        let timeLabel = venueDetailModel?.timing.toArrayDetached(ofType: TimingModel.self)
        let weekdayComponent = Calendar.current.component(.weekday, from: Date())
        if let shortDayName = Calendar.current.shortWeekdaySymbols[weekdayComponent - 1] as String? {
            let currentTime = timeLabel?.filter { $0.day.capitalized == shortDayName }
            _timeLabel.text = "\(currentTime?.first?.openingTime ?? "00:00") - \(currentTime?.first?.closingTime ?? "00:00")"
        }

    }
    
    private func _validationsEmptyData() {
        guard let venueDetailModel = venueDetailModel else { return }

        if Utils.stringIsNullOrEmpty(venueDetailModel.menuUrl) || venueDetailModel.menuUrl == "undefined" {
            _menuButton.isHidden = true
        } else {
            _menuButton.isHidden = false
        }
        
        if !venueDetailModel.feature.isEmpty {
            _featuresStack.isHidden = false
            
            if let features = Utils.getModelsFromIds(model: APPSETTING.feature, ids: venueDetailModel.feature) {
                if !features.isEmpty {
                    _featuresLabel.text = features.map{$0.title}.joined(separator: ", ")
                } else {
                    _featuresLabel.text = venueDetailModel.feature.joined(separator: ", ")
                }
            } else {
                _featuresLabel.text = venueDetailModel.feature.joined(separator: ", ")
            }
        }
        if !venueDetailModel.cuisine.isEmpty {
            _cusineStack.isHidden = false
            if let cuisines = Utils.getModelsFromIds(model: APPSETTING.cuisine, ids: venueDetailModel.cuisine) {
                if !cuisines.isEmpty {
                    _cuisineLabel.text = cuisines.map{$0.title}.joined(separator: ", ")
                } else {
                    _cuisineLabel.text = venueDetailModel.cuisine.joined(separator: ", ")
                }
            } else {
                _cuisineLabel.text = venueDetailModel.cuisine.joined(separator: ", ")
            }
        }
        if !venueDetailModel.music.isEmpty {
            _musicStack.isHidden = false
            if let musices = Utils.getModelsFromIds(model: APPSETTING.music, ids: venueDetailModel.music) {
                if !musices.isEmpty {
                    _musicLabel.text = musices.map{$0.title}.joined(separator: ", ")
                } else {
                    _musicLabel.text = venueDetailModel.music.joined(separator: ", ")
                }
            } else {
                _musicLabel.text = venueDetailModel.music.joined(separator: ", ")
            }
        }
        if !Utils.stringIsNullOrEmpty(venueDetailModel.dressCode) {
            _dressCodeStack.isHidden = false
            _dressCodeLabel.text = venueDetailModel.dressCode
        }
        if !venueDetailModel.theme.isEmpty {
            _themeStack.isHidden = false
            if let themes = Utils.getModelsFromIds(model: APPSETTING.themes, ids: venueDetailModel.theme) {
                if !themes.isEmpty {
                    _themeLabel.text = themes.map{$0.title}.joined(separator: ", ")
                } else {
                    _themeLabel.text = venueDetailModel.theme.joined(separator: ", ")
                }
            } else {
                _themeLabel.text = venueDetailModel.theme.joined(separator: ", ")
            }
        }

    }
    
    private func _openMail() {
        guard MFMailComposeViewController.canSendMail() else {
            parentBaseController?.alert(message: "mail_services_are_not_available_on_your_device".localized())
            return
        }
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        if let email = self.venueDetailModel?.email {
            composeVC.setToRecipients([email])
        }
        composeVC.setSubject(kAppName)
        composeVC.setMessageBody(kEmptyString, isHTML: false)
        parentViewController?.present(composeVC, animated: true, completion: nil)
    }

    private func openMapsAppWith(latitude: Double, longitude: Double, locationName: String) {
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = locationName
        
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        let mapItems = [mapItem]
        let alertController = UIAlertController(title: nil, message: "open_in_maps".localized(), preferredStyle: .actionSheet)
                
        if !Utils.checkIfWazeInstalled() && !Utils.checkIfGoogleMapsInstalled() {
            MKMapItem.openMaps(with: mapItems, launchOptions: launchOptions)
        } else {
            if Utils.checkIfGoogleMapsInstalled() {
                let googleMapsAction = UIAlertAction(title: "google_maps".localized(), style: .default) { _ in
                    let destinationString = "\(latitude),\(longitude)"
                    if let googleMapsURL = URL(string: "comgooglemaps://?saddr=&daddr=\(destinationString)&directionsmode=driving") {
                        UIApplication.shared.open(googleMapsURL, options: [:], completionHandler: nil)
                    }
                }
                alertController.addAction(googleMapsAction)
            }
            
            if Utils.checkIfWazeInstalled() {
                let wazeAction = UIAlertAction(title: "waze".localized(), style: .default) { _ in
                    let wazeURLString = "waze://?ll=\(latitude),\(longitude)&navigate=yes"
                    if let wazeURL = URL(string: wazeURLString) {
                        UIApplication.shared.open(wazeURL, options: [:], completionHandler: nil)
                    }
                }
                alertController.addAction(wazeAction)
            }
            
            let appleMapsAction = UIAlertAction(title: "apple_maps".localized(), style: .default) { _ in
                MKMapItem.openMaps(with: mapItems, launchOptions: launchOptions)
            }
            alertController.addAction(appleMapsAction)
            
            let cancelAction = UIAlertAction(title: "cancel".localized(), style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            
            if let popoverController = alertController.popoverPresentationController {
                popoverController.sourceView = parentViewController?.view
                popoverController.sourceRect = CGRect(x: self.bounds.minX, y: self.bounds.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
            }
            
            parentViewController?.present(alertController, animated: true, completion: nil)
        }
    }


    private func _openURL(urlString: String) {
        if let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? kEmptyString) {
            let vc = INIT_CONTROLLER_XIB(WebViewController.self)
            vc.url = url
            vc.viewTitle = venueDetailModel?.name ?? kEmptyString
            parentViewController?.navigationController?.pushViewController(vc, animated: true)
        } else {
            parentBaseController?.alert(title: kAppName, message: "Invalid url.")
        }
    }
    
    private func configureImageViews(imageViews: [UIImageView], galaryImages: [String?]) {
        let totalImageViews = imageViews.count
        for i in 0..<totalImageViews {
            if i < galaryImages.count {
                imageViews[i].isHidden = false
                imageViews[i].loadWebImage(galaryImages[i] ?? "") {
                    do {
                        imageViews[i].borderColor = try imageViews[i].image?.averageColor() ?? ColorBrand.brandImageBorder
                        imageViews[i].borderWidth = 1
                    } catch {}
                }
            } else {
                imageViews[i].isHidden = true
            }
        }
        
        if galaryImages.count > totalImageViews {
            let remainingCount = galaryImages.count - totalImageViews
            _galaryCountView.isHidden = false
            _galaryImageCount.text = "+\(remainingCount)"
        } else {
            _galaryCountView.isHidden = true
        }
    }
    
    private func  _generateDynamicLinks() {
        guard let controller = parentViewController else { return }
//        guard let venueDetailModel = venueDetailModel else {
//            return
//        }
//        let shareMessage = "\(venueDetailModel.name) \n\n\(venueDetailModel.about ) \n\n\("https://whosin.me/link/\(venueDetailModel.id)")"
//        let items = [shareMessage]
//        let activityController = UIActivityViewController(activityItems: items, applicationActivities: nil)
//        activityController.setValue(kAppName, forKey: "subject")
//        activityController.popoverPresentationController?.sourceView = controller.view
//        activityController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToTwitter]
//        controller.present(activityController, animated: true, completion: nil)
    }
    
    private func _openInfoBottomSheet() {
        if Utils.stringIsNullOrEmpty(venueDetailModel?.email) && Utils.stringIsNullOrEmpty(venueDetailModel?.phone) { return }
        
        let alert = UIAlertController(title: kAppName, message: nil, preferredStyle: .actionSheet)
        if !Utils.stringIsNullOrEmpty(venueDetailModel?.phone) {
            let array = venueDetailModel?.phone.components(separatedBy: ",")
            array?.forEach{ phone in
                alert.addAction(UIAlertAction(title: phone, style: .default, handler: {action in
                    let phoneNumber = action.title
                    let escapedString = phoneNumber?.addingPercentEncoding(withAllowedCharacters: .afURLQueryAllowed)
                    if let url = URL(string: "tel://\(escapedString ?? "")") {
                        APP.systemApplication.open(url, options: [:])
                    }
                }))
            }
        }
        if !Utils.stringIsNullOrEmpty(venueDetailModel?.email) {
            alert.addAction(UIAlertAction(title: venueDetailModel?.email, style: .default, handler: {action in
                DISPATCH_ASYNC_MAIN { self._openMail() }
            }))
        }
        alert.addAction(UIAlertAction(title: "cancel".localized(), style: .destructive, handler: { _ in }))
        parentViewController?.present(alert, animated: true)
    }
    
    private func _openTimeDialogue() {
        let customview = TimeDailogView()
        customview._timeDetail = venueDetailModel?.timing.toArrayDetached(ofType: TimingModel.self) ?? []
        let alertController = UIAlertController(title: "", message: nil, preferredStyle: UIAlertController.Style.alert)
        alertController.view.heightAnchor.constraint(equalToConstant: 300).isActive = true
        alertController.view.addSubview(customview)
        let cancelAction = UIAlertAction(title: "close".localized(), style: .cancel, handler: {(alert: UIAlertAction!) in print("cancel")})
        alertController.addAction(cancelAction)
        DISPATCH_ASYNC_MAIN {
            self.parentViewController?.present(alertController, animated: true, completion:{
                alertController.view.superview?.isUserInteractionEnabled = true
                alertController.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertControllerBackgroundTapped)))
            })
        }
        (self.superview as? CustomTableView)?.update()
    }
    
    @objc func alertControllerBackgroundTapped() {
        self.parentViewController?.dismiss(animated: true, completion: nil)
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setupData(_ data: VenueDetailModel,offersModel: [OffersModel] = [], completion: (() -> Void)?) {
        self.completion = completion
        venueDetailModel = data
        _loadData()
    }
    
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    @IBAction private func backButtonAction() {
        parentBaseController?.feedbackGenerator?.impactOccurred()
        completion?()
    }
    
    @IBAction private func _handleShareEvent(_ sender: UIButton) {
        parentBaseController?.feedbackGenerator?.impactOccurred()
        let vc = INIT_CONTROLLER_XIB(ShareBottomSheet.self)
        vc.veneuDetail = venueDetailModel
        vc.modalPresentationStyle = .overFullScreen
        parentViewController?.present(vc, animated: true)
    }
    
    @IBAction func _handleAddRecommendedEvent(_ sender: UIButton) {
        parentBaseController?.feedbackGenerator?.impactOccurred()
        _requestAddRecommendation()
    }
    
    @IBAction private func _handleInfoEvent(_ sender: UIButton) {
        parentBaseController?.feedbackGenerator?.impactOccurred()
        _openInfoBottomSheet()
    }
    
    @IBAction private func _handleLocationEvent(_ sender: UIButton) {
        parentBaseController?.feedbackGenerator?.impactOccurred()
        guard let longitude = venueDetailModel?.location?.coordinates[0],let latitude = venueDetailModel?.location?.coordinates[1] else { return}
        openMapsAppWith(latitude: latitude, longitude: longitude, locationName: venueDetailModel?.name ?? "")
    }
    
    @IBAction private func _handleMenuEvent(_ sender: UIButton) {
        parentBaseController?.feedbackGenerator?.impactOccurred()
        _openURL(urlString: venueDetailModel?.menuUrl ?? "")
    }
    
    @IBAction private func _handleTimeEvent(_ sender: UIButton) {
        parentBaseController?.feedbackGenerator?.impactOccurred()
        _openTimeDialogue()
    }
    
    @IBAction func _handleFrequencyEvent(_ sender: UIButton) {
        let vc = INIT_CONTROLLER_XIB(RequirementsBottomSheet.self)
        vc.requireTitle = "cm_user_visit_frequency".localized()
        vc.requirementText = "\(venueDetailModel?.frequencyOfVisitForCm ?? 0)"
        vc.keyboardType = .numberPad
        vc.callback = { [weak self] inputText in
            self?._requestSetFrequeny(days: Int(inputText) ?? 0)
        }
        parentViewController?.presentAsPanModal(controller: vc)

    }
    
    
    @IBAction private func _handleOpenGalary(_ sender: UIButton) {
        parentBaseController?.feedbackGenerator?.impactOccurred()
        let browser = MediaBrowser(delegate: self)
        browser.startOnGrid = true
        browser.enableGrid = true
        browser.modalPresentationStyle = .pageSheet
        parentViewController?.present(browser, animated: true)
    }
    
    @IBAction private func _hanndleFollowEvent(_ sender: UIButton) {
        parentBaseController?.feedbackGenerator?.impactOccurred()
        _requestFollowUnfollow()
    }
    
    @IBAction private func _handleInviteEvent(_ sender: UIButton) {
    }
}

extension VenueDetailsTableCell:  ExpandableLabelDelegate {
    
    func willExpandLabel(_ label: ExpandableLabel) {
    }
    
    func didExpandLabel(_ label: ExpandableLabel) {
        (self.superview as? CustomTableView)?.update()
    }
    
    func willCollapseLabel(_ label: ExpandableLabel) {
        
    }
    
    func didCollapseLabel(_ label: ExpandableLabel) {
        (self.superview as? CustomTableView)?.update()
    }
}

extension VenueDetailsTableCell: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}


extension VenueDetailsTableCell: MediaBrowserDelegate {
    
    func thumbnail(for mediaBrowser: MediaBrowser, at index: Int) -> Media {
        return _galaryArrayList[index]
    }
    
    func numberOfMedia(in mediaBrowser: MediaBrowser) -> Int {
        _galaryArrayList.count
    }
    
    func media(for mediaBrowser: MediaBrowser, at index: Int) -> Media {
        return _galaryArrayList[index]
    }
    
    func gridCellSize() -> CGSize {
        return CGSize(width: (self.frame.width - kCollectionDefaultMargin)/4 , height: (self.frame.width - kCollectionDefaultMargin)/4)
    }
}
