import UIKit
import ExpandableLabel
import MessageUI
import MapKit
import MediaBrowser
import CoreMedia


class YachtClubDetailsTableCell: UITableViewCell {
    

//    @IBOutlet private weak var _followButton: UIButton!
    @IBOutlet private weak var _bgView: GradientView!
    @IBOutlet private weak var _venueDesc: UILabel!
    @IBOutlet private weak var _venueTitle: UILabel!
    @IBOutlet private weak var _logoImageView: UIImageView!
    @IBOutlet private weak var _galaryContainerView: UIView!
    @IBOutlet private weak var _galaryImageCount: UILabel!
    @IBOutlet private weak var _galaryCountView: UIView!
    @IBOutlet private var _imageViews: [UIImageView]!
    @IBOutlet private weak var _coverImage: UIImageView!
    @IBOutlet private weak var _distanceLabel: UILabel!
    @IBOutlet private weak var _backButton: UIButton!
    @IBOutlet private weak var _safeHeight: NSLayoutConstraint!
    @IBOutlet private weak var _timeStack: UIView!
    @IBOutlet private weak var _menuButton: UIButton!
    @IBOutlet private weak var _openCloseLabel: UILabel!
    @IBOutlet private weak var _timeLabel: UILabel!

    private var _yachtClubModel: YachtClubModel?
    private var _dealsModel: [DealsModel] = []
    private var imageArray: [String] = []
    private var _galaryArrayList = [Media]()

    
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
    
//    private func _requestFollowUnfollow() {
//        guard let _venue = _yachtClubModel else { return }
//        WhosinServices.updateFollows(id: _venue.id) { [weak self] container, error in
//            guard let self = self else { return }
//            _venue.isFollowing = !_venue.isFollowing
//            if let message = container?.message { self.parentViewController?.showToast(message) }
//            self._followButton.setTitle(_venue.isFollowing ? "Following" : "Follow")
//        }
//    }
    
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
        _distanceLabel.text = String(format: "%.2f", 0.0 ) + "km_away".localized()
        
        if Utils.stringIsNullOrEmpty(_yachtClubModel?.bookingUrl) || _yachtClubModel?.bookingUrl == "undefined" {
            _menuButton.isHidden = true
        } else {
            _menuButton.isHidden = true
        }
        _timingLogic(_yachtClubModel?.isOpen)
        _galaryImageSetup()
    }
    
    private func _timingLogic(_ isOpen: Bool?) {
        if let isOpen = isOpen {
            _openCloseLabel.text = isOpen ? "open".localized() : "close".localized()
            _openCloseLabel.textColor = isOpen ? .green : .red
        }
        let timeLabel =  _yachtClubModel?.timing.toArrayDetached(ofType: TimingModel.self)
        let weekdayComponent = Calendar.current.component(.weekday, from: Date())
        if let shortDayName = Calendar.current.shortWeekdaySymbols[weekdayComponent - 1] as String? {
            let currentTime = timeLabel?.filter { $0.day.capitalized == shortDayName }
            _timeLabel.text = "\(currentTime?.first?.openingTime ?? "00:00") - \(currentTime?.first?.closingTime ?? "00:00")"
        }

    }
    
    private func _galaryImageSetup() {
        imageArray.removeAll()
        _yachtClubModel?.galleries.forEach { image in
            imageArray.append(image)
        }
        if !Utils.stringIsNullOrEmpty(_yachtClubModel?.cover) { imageArray.insert(_yachtClubModel?.cover ?? "", at: 0) }
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
        
        _coverImage.loadWebImage(_yachtClubModel?.cover ?? "") {
            do {
                self._bgView.startColor = try self._coverImage.image?.averageColor() ?? ColorBrand.brandPink
            } catch {
                
            }
        }
    }
    
    private func _openTimeDialogue() {
        let customview = TimeDailogView()
        customview._timeDetail = _yachtClubModel?.timing.toArrayDetached(ofType: TimingModel.self) ?? []
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

    private func _openMail() {
        guard MFMailComposeViewController.canSendMail() else {
            parentBaseController?.alert(message: "mail_services_are_not_available_on_your_device".localized())
            return
        }
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        if let email = self._yachtClubModel?.email {
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
            vc.viewTitle = _yachtClubModel?.name ?? kEmptyString
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
            let shareMessage = "\(self._yachtClubModel?.name ?? kEmptyString) \n\n\(self._yachtClubModel?.about ?? kEmptyString) \n\n\("https://whosin.me/link/\(_yachtClubModel?.id ?? "")")"
            let items = [shareMessage]
            let activityController = UIActivityViewController(activityItems: items, applicationActivities: nil)
            activityController.setValue(kAppName, forKey: "subject")
            activityController.popoverPresentationController?.sourceView = controller.view
            activityController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToTwitter]
            controller.present(activityController, animated: true, completion: nil)
    }
    
    private func _openInfoBottomSheet() {
        if Utils.stringIsNullOrEmpty(_yachtClubModel?.email) && Utils.stringIsNullOrEmpty(_yachtClubModel?.phone) { return }
        let alert = UIAlertController(title: kAppName, message: nil, preferredStyle: .actionSheet)
        if !Utils.stringIsNullOrEmpty(_yachtClubModel?.phone) {
            alert.addAction(UIAlertAction(title: _yachtClubModel?.phone, style: .default, handler: {action in
                let phoneNumber = self._yachtClubModel?.phone
                let escapedString = phoneNumber?.addingPercentEncoding(withAllowedCharacters: .afURLQueryAllowed)
                if let url = URL(string: "tel://\(escapedString ?? "")") {
                    APP.systemApplication.open(url, options: [:])
                }
            }))
        }
        if !Utils.stringIsNullOrEmpty(_yachtClubModel?.email) {
            alert.addAction(UIAlertAction(title: _yachtClubModel?.email, style: .default, handler: {action in
                DISPATCH_ASYNC_MAIN { self._openMail() }
            }))
        }
        alert.addAction(UIAlertAction(title: "cancel".localized(), style: .destructive, handler: { _ in }))
        parentViewController?.present(alert, animated: true)
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setupData(_ data: YachtClubModel) {
        _yachtClubModel = data
        _loadData()
    }
    
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    @IBAction private func backButtonAction() {
        parentBaseController?.feedbackGenerator?.impactOccurred()
    }
    
    @IBAction private func _handleShareEvent(_ sender: UIButton) {
        parentBaseController?.feedbackGenerator?.impactOccurred()
        let navController = INIT_CONTROLLER_XIB(ShareBottomSheet.self)
        navController.isYachClub = true
        navController.yachClubDetail = self._yachtClubModel
        navController.modalPresentationStyle = .overFullScreen
        parentBaseController?.present(navController, animated: true)
//        _generateDynamicLinks()
    }
    
    @IBAction private func _handleInfoEvent(_ sender: UIButton) {
        parentBaseController?.feedbackGenerator?.impactOccurred()
        _openInfoBottomSheet()
    }
    
    @IBAction private func _handleTimeEvent(_ sender: UIButton) {
        parentBaseController?.feedbackGenerator?.impactOccurred()
        _openTimeDialogue()
    }

    @IBAction private func _handleMenuEvent(_ sender: UIButton) {
        parentBaseController?.feedbackGenerator?.impactOccurred()
        _openURL(urlString: _yachtClubModel?.bookingUrl ?? "")
    }

    
    @IBAction private func _handleLocationEvent(_ sender: UIButton) {
        parentBaseController?.feedbackGenerator?.impactOccurred()
        guard let longitude = _yachtClubModel?.location?.coordinates[0],let latitude = _yachtClubModel?.location?.coordinates[1] else { return}
        openMapsAppWith(latitude: latitude, longitude: longitude, locationName: _yachtClubModel?.name ?? "")
    }
        
    @IBAction private func _handleOpenGalary(_ sender: UIButton) {
        parentBaseController?.feedbackGenerator?.impactOccurred()
        let browser = MediaBrowser(delegate: self)
        browser.startOnGrid = true
        browser.enableGrid = true
        parentViewController?.present(browser, animated: true)
    }
    
    @IBAction private func _hanndleFollowEvent(_ sender: UIButton) {
        parentBaseController?.feedbackGenerator?.impactOccurred()
    }
    
    @IBAction private func _handleContactAgentEvent(_ sender: UIButton) {
    }
}

extension YachtClubDetailsTableCell:  ExpandableLabelDelegate {
    
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

extension YachtClubDetailsTableCell: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}


extension YachtClubDetailsTableCell: MediaBrowserDelegate {
    
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
