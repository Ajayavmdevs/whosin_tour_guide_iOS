import UIKit
import ExpandableLabel
import CountdownLabel
import MapKit

class CompEventDetailHeaderCell: UITableViewCell {
    
    @IBOutlet weak var _shareview: UIVisualEffectView!
    @IBOutlet weak var _likeView: UIVisualEffectView!
    @IBOutlet weak var _likeButton: UIButton!
    @IBOutlet weak var _eventLocationLabel: CustomLabel!
    @IBOutlet weak var _discriptionHeight: NSLayoutConstraint!
//    @IBOutlet weak var _imgView: UIImageView!
    @IBOutlet weak var _dateLbl: CustomLabel!
    @IBOutlet weak var _timeLbl: CustomLabel!
    @IBOutlet weak var _descLbl: UILabel!
    @IBOutlet weak var _timeCountdown: CountdownLabel!
    @IBOutlet weak var _countDownView: UIVisualEffectView!
    @IBOutlet weak var _locationHeightconstraint: NSLayoutConstraint!
    @IBOutlet weak var _eventGalleryView: CustomEventGalleryView!
    private var eventModel: PromoterEventsModel?
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat { UITableView.automaticDimension }
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func awakeFromNib() {
        super.awakeFromNib()
        disableSelectEffect()
        let tap = UITapGestureRecognizer(target: self, action: #selector(openMap))
        _eventLocationLabel.isUserInteractionEnabled = true
        _eventLocationLabel.addGestureRecognizer(tap)
        _timeCountdown.countdownDelegate = self
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
                popoverController.sourceView = parentViewController?.view
                popoverController.sourceRect = CGRect(x: self.bounds.minX, y: self.bounds.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
            }
            
            parentViewController?.present(alertController, animated: true, completion: nil)
        }
    }
    
    public func setupData(_ model: PromoterEventsModel, isCM: Bool = false, isPlusOne: Bool = false) {
        _likeView.isHidden = !isCM
        eventModel = model
        _likeButton.isSelected = model.isWishlisted
        _eventGalleryView.setupData(model)
        _descLbl.text = model.descriptions
        _discriptionHeight.constant = _descLbl.sizeThatFits(CGSize(width: _descLbl.frame.width, height: CGFloat.greatestFiniteMagnitude)).height
        _eventLocationLabel.text = model.venueType == "venue" ? model.venue?.address : model.customVenue?.address
        _locationHeightconstraint.constant = _eventLocationLabel.sizeThatFits(CGSize(width: _eventLocationLabel.frame.width, height: CGFloat.greatestFiniteMagnitude)).height
//        _imgView.loadWebImage(model.venueType == "venue" ? model.image.isEmpty ? model.venue?.cover ?? kEmptyString : model.image : model.customVenue?.image ?? kEmptyString)
        _dateLbl.text = Utils.dateToString(Utils.stringToDate(model.date, format: kFormatDate), format: kFormatEventDate)
        _timeLbl.text = model.startTime + " - " + model.endTime
        if model.isTwoHourRemaining && model.status == "upcoming"  {
            _countDownView.isHidden = false
            _timeCountdown.font = FontBrand.SFboldFont(size: 18)
            let tmpEndDate = "\(model.date) \(model.startTime)".toDateUae(format: kFormatDateTimeLocal)
            _timeCountdown.animationType = .Evaporate
            _timeCountdown.timeFormat = "dd:HH:mm:ss"
            _timeCountdown.setCountDownDate(targetDate: tmpEndDate as NSDate)
            DISPATCH_ASYNC_MAIN_AFTER(0.015) {
                self._timeCountdown.start()
            }
        } else {
            _countDownView.isHidden = true
        }
        if isPlusOne || model.status == "completed" {
            _likeView.isHidden = true
            _shareview.isHidden = true
        }
    }
    
    @IBAction private func _handleAddWishListEvent(_ sender: UIButton) {
        guard let eventModel = eventModel else { return }
        WhosinServices.toggleWishlist(type: "event", typeId: eventModel.id) { [weak self] container, error in
            guard let self = self else { return }
            self.parentBaseController?.showError(error)
            guard let data = container else { return }
            eventModel.isWishlisted = !eventModel.isWishlisted
            self._likeButton.isSelected = eventModel.isWishlisted
            self.parentBaseController?.showSuccessMessage(data.message, subtitle: kEmptyString)
            NotificationCenter.default.post(name: .reloadMyEventsNotifier   , object: nil)
        }
    }
    
    @IBAction func _handleShareEvent(_ sender: UIButton) {
        guard let _event = eventModel else { return }
//        if APPSESSION.userDetail?.isPromoter == true {
            let navController = INIT_CONTROLLER_XIB(ShareBottomSheet.self)
            navController.promoterEvent = _event
            navController.isPromoter = APPSESSION.userDetail?.isPromoter ?? false
            navController.isComplementary = APPSESSION.userDetail?.isRingMember ?? false
            navController.modalPresentationStyle = .overFullScreen
            self.parentViewController?.present(navController, animated: true)
//        } else {
//            let alert = UIAlertController(title: _event.venueType == "venue" ? _event.venue?.name : _event.customVenue?.name, message: nil, preferredStyle: .actionSheet)
//            
//            alert.addAction(UIAlertAction(title: "Share", style: .default, handler: {action in
//                Utils.generateDynamicLinksForPromoterEvent(controller: self.parentViewController, model: _event)
//            }))
//            
//            alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: { _ in }))
//            self.parentViewController?.present(alert, animated: true, completion:{
//                alert.view.superview?.subviews[0].isUserInteractionEnabled = true
//            })
//        }

    }
    
}

extension CompEventDetailHeaderCell: CountdownLabelDelegate {
    func countdownFinished() {
        NotificationCenter.default.post(name: .reloadMyEventsNotifier   , object: nil)
    }
}
