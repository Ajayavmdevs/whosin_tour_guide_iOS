import UIKit
import ExpandableLabel
import MessageUI
import MapKit
import MediaBrowser
import CoreMedia


class ComponyDetailsTableCell: UITableViewCell {
    

    @IBOutlet weak var _collectionView: CustomCollectionView!
    @IBOutlet private weak var _followButton: UIButton!
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
    private var _yachtClubModel: YachtClubModel?
    private var _dealsModel: [DealsModel] = []
    private var imageArray: [String] = []
    private var _galaryArrayList = [Media]()
    private let kCellIdentifier = String(describing: ComponyInfoCollectionCell.self)

    
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
        _collectionView.setup(cellPrototypes: _prototype,
                              hasHeaderSection: false,
                              enableRefresh: false,
                              columns: 1,
                              rows: 1,
                              edgeInsets: UIEdgeInsets(top: 0.0, left: 14, bottom: 0.0, right: 14),
                              scrollDirection: .horizontal,
                              emptyDataText: nil,
                              emptyDataIconImage: nil,
                              delegate: self)
        _collectionView.showsVerticalScrollIndicator = false
        _collectionView.showsHorizontalScrollIndicator = false

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
    
    private var _prototype: [[String: Any]]? {
        return [[kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: kCellIdentifier, kCellClassKey: ComponyInfoCollectionCell.self, kCellHeightKey: ComponyInfoCollectionCell.height]]
    }

    
    private func _loadData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        
        _dealsModel.forEach { dealsModel in
            cellData.append([
                kCellIdentifierKey: kCellIdentifier,
                kCellTagKey: dealsModel.id,
                kCellObjectDataKey: dealsModel,
                kCellClassKey: ComponyInfoCollectionCell.self,
                kCellHeightKey: ComponyInfoCollectionCell.height
            ])
        }
        
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _collectionView.loadData(cellSectionData)

        _distanceLabel.text = String(format: "%.2f", 0.0 ) + "km away"
//        _followUnfollowToggle()
        _galaryImageSetup()
        _timingLogic()
//        _validationsEmptyData()
    }
    
//    private func _followUnfollowToggle() {
//        guard let isFollowing = _yachtClubModel?.isFollowing else { return }
//        self._followButton.setTitle(isFollowing ? "Following" : "Follow")
//    }
    
    private func _galaryImageSetup() {
        _yachtClubModel?.galleries.forEach { image in
            imageArray.append(image)
        }
        if !Utils.stringIsNullOrEmpty(_yachtClubModel?.cover) { imageArray.insert(_yachtClubModel?.cover ?? "", at: 0) }
        if !imageArray.isEmpty {
            configureImageViews(imageViews: _imageViews, galaryImages: imageArray)
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
    
    private func _timingLogic() {
        _yachtClubModel?.timings.forEach { timingModel in
            if timingModel.day == Utils.currentDayOnly() {
                _timeLabel.text = "\(timingModel.openingTime) - \(timingModel.closingTime)"
                if Utils.currentTimeOnly() <= Utils.stringToDate(timingModel.openingTime, format: kFormatDateTimeUS)! && Utils.currentTimeOnly() >= Utils.stringToDate(timingModel.closingTime, format: kFormatDateTimeUS)! {
                    _openCloseLabel.text = "Open"
                    _openCloseLabel.textColor = .green
                } else {
                    _openCloseLabel.text = "Close"
                    _openCloseLabel.textColor = .red
                }
            }
        }
    }
    
//    private func _validationsEmptyData() {
//        guard let _yachtClubModel = _yachtClubModel else { return }
//
//        if Utils.stringIsNullOrEmpty(_yachtClubModel.menuUrl) {
//            _menuButton.isHidden = true
//        }
//
//        if !_yachtClubModel.feature.isEmpty {
//            _featuresStack.isHidden = false
//            _featuresLabel.text = venueDetailModel.feature.joined(separator: ", ")
//        }
//        if !_yachtClubModel.cuisine.isEmpty {
//            _cusineStack.isHidden = false
//            _cuisineLabel.text = venueDetailModel.cuisine.joined(separator: ", ")
//        }
//        if !_yachtClubModel.music.isEmpty {
//            _musicStack.isHidden = false
//            _musicLabel.text = venueDetailModel.music.joined(separator: ", ")
//        }
//        if !Utils.stringIsNullOrEmpty(venueDetailModel.dressCode) {
//            _dressCodeStack.isHidden = false
//            _dressCodeLabel.text = venueDetailModel.dressCode
//        }
//        if !venueDetailModel.theme.isEmpty {
//            _themeStack.isHidden = false
//            _themeLabel.text = venueDetailModel.theme.joined(separator: ", ")
//        }
//
//    }
    
    private func _openMail() {
        guard MFMailComposeViewController.canSendMail() else {
            parentBaseController?.alert(message: "Mail services are not available on your device")
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
        
        let options: [String: Any] = [MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: coordinate)]
        
        let alertController = UIAlertController(title: nil, message: "open_in_maps".localized(), preferredStyle: .actionSheet)
                
        if !Utils.checkIfWazeInstalled() && !Utils.checkIfGoogleMapsInstalled() {
            let mapItems = [mapItem]
            MKMapItem.openMaps(with: mapItems, launchOptions: options)
        } else {
            if Utils.checkIfGoogleMapsInstalled() {
                let googleMapsAction = UIAlertAction(title: "google_maps".localized(), style: .default) { _ in
                    let googleMapsURLString = "comgooglemaps://?center=\(latitude),\(longitude)&zoom=14&views=traffic"
                    if let googleMapsURL = URL(string: googleMapsURLString) {
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
                let mapItems = [mapItem]
                MKMapItem.openMaps(with: mapItems, launchOptions: options)
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
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
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
    
    private func _openTimeDialogue() {
        let customview = TimeDailogView()
        customview._timeDetail = _yachtClubModel?.timings.toArrayDetached(ofType: TimingModel.self) ?? []
        let alertController = UIAlertController(title: "", message: nil, preferredStyle: UIAlertController.Style.alert)
        alertController.view.heightAnchor.constraint(equalToConstant: 300).isActive = true
        alertController.view.addSubview(customview)
        let cancelAction = UIAlertAction(title: "Close", style: .cancel, handler: {(alert: UIAlertAction!) in print("cancel")})
        alertController.addAction(cancelAction)
        DISPATCH_ASYNC_MAIN {
            self.parentViewController?.present(alertController, animated: true, completion:{})
        }
        (self.superview as? CustomTableView)?.update()
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setupData(_ data: YachtClubModel) {
        _yachtClubModel = data
//        _dealsModel = data.deals.toArrayDetached(ofType: DealsModel.self)
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
        _generateDynamicLinks()
    }
    
    @IBAction private func _handleInfoEvent(_ sender: UIButton) {
        parentBaseController?.feedbackGenerator?.impactOccurred()
        _openInfoBottomSheet()
    }
    
    @IBAction private func _handleLocationEvent(_ sender: UIButton) {
        parentBaseController?.feedbackGenerator?.impactOccurred()
        guard let longitude = _yachtClubModel?.location?.coordinates[0],let latitude = _yachtClubModel?.location?.coordinates[1] else { return}
        openMapsAppWith(latitude: latitude, longitude: longitude, locationName: _yachtClubModel?.name ?? "")
    }
    
    @IBAction private func _handleMenuEvent(_ sender: UIButton) {
        parentBaseController?.feedbackGenerator?.impactOccurred()
        _openURL(urlString: _yachtClubModel?.bookingUrl ?? "")
    }
    
    @IBAction private func _handleTimeEvent(_ sender: UIButton) {
        parentBaseController?.feedbackGenerator?.impactOccurred()
        _openTimeDialogue()
    }
    
    @IBAction private func _handleOpenGalary(_ sender: UIButton) {
        parentBaseController?.feedbackGenerator?.impactOccurred()
        let browser = MediaBrowser(delegate: self)
        browser.startOnGrid = true
        browser.enableGrid = true
        parentViewController?.present(browser, animated: true) //.navigationController?.pushViewController(browser, animated: true)
    }
    
    @IBAction private func _hanndleFollowEvent(_ sender: UIButton) {
        parentBaseController?.feedbackGenerator?.impactOccurred()
//        _requestFollowUnfollow()
    }
}

extension ComponyDetailsTableCell:  ExpandableLabelDelegate {
    
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

extension ComponyDetailsTableCell: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}


extension ComponyDetailsTableCell: MediaBrowserDelegate {
    
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

extension ComponyDetailsTableCell: CustomCollectionViewDelegate {
        
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
            guard let cell = cell as? ComponyInfoCollectionCell ,let object = cellDict?[kCellObjectDataKey] as? DealsModel else { return }
                cell.setUpdata(object)
        if _yachtClubModel != nil {
            cell._imageiView.loadWebImage(_yachtClubModel?.cover ?? kEmptyString)
        }
    }
    

    
    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        return CGSize(width: kScreenWidth * 0.70, height: ComponyInfoCollectionCell.height)
    }

}
