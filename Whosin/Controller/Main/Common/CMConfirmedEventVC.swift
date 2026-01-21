import UIKit
import Lightbox
import MapKit
import PDFKit
import StripeCore
import Lottie

class CMConfirmedEventVC: PanBaseViewController {
    
    @IBOutlet weak var _plusOneViewHeightconstraint: NSLayoutConstraint!
    @IBOutlet weak var _collectionheaightConstraint: NSLayoutConstraint!
    @IBOutlet weak var _successview: LottieAnimationView!
    @IBOutlet private weak var _coverImage: UIImageView!
    @IBOutlet private weak var _eventLocation: CustomLabel!
    @IBOutlet private weak var _cardView: UIView!
    @IBOutlet private weak var _qrCodeImageView: UIImageView!
    @IBOutlet private weak var CMView: UIView!
    @IBOutlet private weak var _userImage: UIImageView!
    @IBOutlet private weak var _userName: CustomLabel!
    @IBOutlet private weak var _eventView: UIView!
    @IBOutlet private weak var _eventLogo: UIImageView!
    @IBOutlet private weak var _eventName: CustomLabel!
    @IBOutlet private weak var _eventDetail: CustomLabel!
    @IBOutlet private weak var _catagrytypeTag: UIView!
    @IBOutlet private weak var _categoryText: UILabel!
    @IBOutlet private weak var _eventDate: CustomLabel!
    @IBOutlet private weak var _eventTime: CustomLabel!
    @IBOutlet private weak var _descLbl: CustomLabel!
    @IBOutlet private weak var _collecitonView: CustomCollectionView!
    @IBOutlet private weak var _plusOneView: UIView!
    private let kCellIdentifierShareWith = String(describing: PlusOneUserCollectionCell.self)
    public var eventModel: PromoterEventsModel?
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _setupCollectionView()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(profileImageTapped))
        _userImage.isUserInteractionEnabled = true
        _userImage.addGestureRecognizer(tapGesture)
        let eventLogoTap = UITapGestureRecognizer(target: self, action: #selector(eventLogoImageTapped))
        _eventLogo.isUserInteractionEnabled = true
        _eventLogo.addGestureRecognizer(eventLogoTap)
        let eventCoverTap = UITapGestureRecognizer(target: self, action: #selector(eventCoverImageTapped))
        _coverImage.isUserInteractionEnabled = true
        _coverImage.addGestureRecognizer(eventCoverTap)
        let locationTap = UITapGestureRecognizer(target: self, action: #selector(openMap))
        _eventLocation.isUserInteractionEnabled = true
        _eventLocation.addGestureRecognizer(locationTap)
        
    }
    
    private func _setupCollectionView() {
        let spacing = 0
        _collecitonView.setup(cellPrototypes: _prototype,
                              hasHeaderSection: false,
                              enableRefresh: false,
                              columns: 1,
                              rows: 1,
                              edgeInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0),
                              scrollDirection: .vertical,
                              emptyDataText: nil,
                              emptyDataIconImage: nil,
                              emptyDataDescription: "",
                              delegate: self)
        _collecitonView.showsVerticalScrollIndicator = false
        _collecitonView.showsHorizontalScrollIndicator = false
        setup()
        _loadData()
    }
    
    func setup() {
        _userName.text = APPSESSION.userDetail?.fullName
        _userImage.loadWebImage(APPSESSION.userDetail?.image ?? kEmptyString, name: APPSESSION.userDetail?.fullName ?? kEmptyString)
        _eventName.text = eventModel?.venueType == "venue" ? eventModel?.venue?.name : eventModel?.customVenue?.name
        _eventDetail.text = eventModel?.venueType == "venue" ? eventModel?.venue?.address : eventModel?.customVenue?.address
        _eventLogo.loadWebImage(eventModel?.venueType == "venue" ? eventModel?.venue?.slogo ?? kEmptyString : eventModel?.customVenue?.image ?? kEmptyString, name: (eventModel?.venueType == "venue" ? eventModel?.venue?.name ?? kEmptyString : eventModel?.customVenue?.name) ?? kEmptyString)
        _eventTime.text = "\(eventModel?.startTime ?? kEmptyString) - \(eventModel?.endTime ?? kEmptyString)"
        let eventdt = Utils.stringToDate(eventModel?.date, format: kFormatDate)
        _eventDate.text  = Utils.dateToString(eventdt, format: "EEEE dd - MMM")
        _categoryText.text = eventModel?.category
        _catagrytypeTag.isHidden = Utils.stringIsNullOrEmpty(eventModel?.category) || eventModel?.category.lowercased() == "none"
        _eventLocation.text = eventModel?.venueType == "venue" ? eventModel?.venue?.address : eventModel?.customVenue?.address
        _descLbl.text = eventModel?.descriptions
        _coverImage.loadWebImage(eventModel?.venueType == "venue" ? eventModel?.image.isEmpty == true ? eventModel?.venue?.cover ?? kEmptyString : eventModel?.image ?? kEmptyString : eventModel?.customVenue?.image ?? kEmptyString)
        if let qrImage = Utils.generateQRCode(from: eventModel?.id ?? kEmptyString, with: CGSize(width: 200, height: 200)) {
            _qrCodeImageView.image = qrImage
        }
        _successview
        _successview.loopMode = .loop
        _successview.play()
        
    }
    
    private func _loadData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
//        _plusOneView.isHidden = eventModel?.plusOneMembers.isEmpty == true
        eventModel?.plusOneMembers.forEach({ model in
            guard model.inviteStatus == "in" else { return}
            cellData.append([
                kCellIdentifierKey: kCellIdentifierShareWith,
                kCellTagKey: kCellIdentifierShareWith,
                kCellDifferenceContentKey: model.id,
                kCellObjectDataKey: model,
                kCellClassKey: PlusOneUserCollectionCell.self,
                kCellHeightKey: PlusOneUserCollectionCell.height
            ])
        })
        _plusOneView.isHidden = cellData.isEmpty
        _collectionheaightConstraint.constant = CGFloat(cellData.count * 52)
        _plusOneViewHeightconstraint.constant = CGFloat(cellData.count * 52) + 30
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _collecitonView.loadData(cellSectionData)
        
    }
    
    private var _prototype: [[String: Any]]? {
        return [[kCellIdentifierKey: String(describing: PlusOneUserCollectionCell.self), kCellNibNameKey: String(describing: PlusOneUserCollectionCell.self), kCellClassKey: PlusOneUserCollectionCell.self, kCellHeightKey: PlusOneUserCollectionCell.height]]
    }
        
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    @objc func profileImageTapped(sender: UITapGestureRecognizer) {
        var images: [LightboxImage] = []
        if sender.state == .ended, let image = _userImage.image {
            images.append(LightboxImage(image: image))
        } else if sender.state == .ended {
            images.append(LightboxImage(imageURL: URL(string: APPSESSION.userDetail?.image ?? kEmptyString)!))
        }
        let controller = LightboxController(images: images)
        controller.dynamicBackground = true
        present(controller, animated: true, completion: nil)
    }
    
    @objc func eventLogoImageTapped(sender: UITapGestureRecognizer) {
        var images: [LightboxImage] = []
        if sender.state == .ended, let image = _eventLogo.image {
            images.append(LightboxImage(image: image))
        } else if sender.state == .ended {
            images.append(LightboxImage(imageURL: URL(string: eventModel?.venueType == "venue" ? eventModel?.venue?.slogo ?? kEmptyString : eventModel?.customVenue?.image ?? kEmptyString)!))
        }
        let controller = LightboxController(images: images)
        controller.dynamicBackground = true
        present(controller, animated: true, completion: nil)
    }
    
    @objc func eventCoverImageTapped(sender: UITapGestureRecognizer) {
        var images: [LightboxImage] = []
        if sender.state == .ended, let image = _coverImage.image {
            images.append(LightboxImage(image: image))
        } else if sender.state == .ended {
            images.append(LightboxImage(imageURL: URL(string: eventModel?.image ?? kEmptyString)!))
        }
        let controller = LightboxController(images: images)
        controller.dynamicBackground = true
        present(controller, animated: true, completion: nil)
    }
    
    @objc func openMap() {
        guard let latitude = eventModel?.venueType == "venue" ? eventModel?.venue?.lat : eventModel?.customVenue?.lat, let longitude = eventModel?.venueType == "venue" ? eventModel?.venue?.lng : eventModel?.customVenue?.lng else { return }
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = eventModel?.customVenue?.address
        
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
                popoverController.sourceView = self.view
                popoverController.sourceRect = CGRect(x: self.view.bounds.minX, y: self.view.bounds.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
            }
            
            present(alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func _handleBackEvent(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
        
}

extension CMConfirmedEventVC: UIDocumentInteractionControllerDelegate {
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
}

extension CMConfirmedEventVC:  CustomCollectionViewDelegate {
    
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? PlusOneUserCollectionCell, let object = cellDict?[kCellObjectDataKey] as? UserDetailModel {
            cell.setup(object)
        }
    }
    
    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        return CGSize(width: _plusOneView.frame.width, height: PlusOneUserCollectionCell.height)
    }
    
    func didSelectCell(_ cell: UICollectionViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let model = cellDict?[kCellObjectDataKey] as? UserDetailModel else { return }
//        if Utils.stringIsNullOrEmpty(model.image) && Utils.stringIsNullOrEmpty(model.fullName) {
//            feedbackGenerator?.impactOccurred()
//            let vc = INIT_CONTROLLER_XIB(PlusOneInivteBottomSheet.self)
//            vc.modalPresentationStyle = .overFullScreen
//            parentViewController?.present(vc, animated: true)
//        }
    }
    
}
