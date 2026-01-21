import Foundation
import UIKit
import SnapKit


class CustomMenuButton: UIView {
    
    @IBOutlet weak var _menuButton: UIButton!
    
    private var offerModel: OffersModel?
    private var venueModel: VenueDetailModel?
    private var yachtOffer: YachtOfferDetailModel?
    private var yachModel: YachtDetailModel?
    private var offerType: OffersType?
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _setupUi()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        _setupUi()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------

    private func _setupUi() {
        if var view = Bundle.main.loadNibNamed("CustomMenuButton", owner: self, options: nil)?.first as? UIView {
            addSubview(view)
            view.snp.makeConstraints { make in
                make.leading.trailing.top.bottom.equalToSuperview()
            }
        }
    }
    
    public func setupData(model: OffersModel,venue: VenueDetailModel?, offerType: OffersType = .venue) {
        offerModel = model
        venueModel = venue
        self.offerType = offerType
    }
    
    public func setupYachData(model: YachtDetailModel,offer: YachtOfferDetailModel?, offerType: OffersType = .yacht) {
        yachtOffer = offer
        yachModel = model
        self.offerType = offerType
    }

    @objc func alertControllerBackgroundTapped() {
        self.parentViewController?.dismiss(animated: true, completion: nil)
    }
    
    private func _addToBucketList() {
        let presentedViewController = INIT_CONTROLLER_XIB(BucketListBottomSheet.self)
        presentedViewController.offerId = offerModel?.id ?? ""
        parentViewController?.presentAsPanModal(controller: presentedViewController)
    }
    
    private func _venueBottomSheet() {
        guard let _venue = offerModel?.venue else { return }

        let alert = UIAlertController(title: _venue.name, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "add_to_bucketlist".localized(), style: .default, handler: {action in
            self._addToBucketList()
        }))
        
        alert.addAction(UIAlertAction(title: "share".localized(), style: .default, handler: {action in
            let vc = INIT_CONTROLLER_XIB(ShareBottomSheet.self)
            vc.offerModel = self.offerModel
            vc.veneuDetail = self.venueModel
            vc.isOffer = true
            vc.modalPresentationStyle = .overFullScreen
            self.parentViewController?.present(vc, animated: true)

//            Utils.generateDynamicLinks(controller: self.parentViewController, venueDetailModel: self.offerModel?.venue)
        }))

        alert.addAction(UIAlertAction(title: "recommend".localized(), style: .default, handler: { action in
            self._requestAddRecommendation()
        }))

        alert.addAction(UIAlertAction(title: "cancel".localized(), style: .destructive, handler: { _ in }))
        parentViewController?.present(alert, animated: true, completion:{
            alert.view.superview?.subviews[0].isUserInteractionEnabled = true
            alert.view.superview?.subviews[0].addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertControllerBackgroundTapped)))
        })
    }
    
    private func _categoryBottomSheet() {
        guard let _venue = offerModel?.venue else { return }
        
        let alert = UIAlertController(title: _venue.name, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "add_to_bucketlist".localized(), style: .default, handler: {action in
            self._addToBucketList()
        }))
        
        alert.addAction(UIAlertAction(title: "share_venue".localized(), style: .default, handler: {action in
            let vc = INIT_CONTROLLER_XIB(ShareBottomSheet.self)
            vc.veneuDetail = self.venueModel
            vc.modalPresentationStyle = .overFullScreen
            self.parentViewController?.present(vc, animated: true)
//            Utils.generateDynamicLinks(controller: self.parentViewController, venueDetailModel: self.offerModel?.venue)
        }))
        
        alert.addAction(UIAlertAction(title: "share_offer".localized(), style: .default, handler: {action in
            let vc = INIT_CONTROLLER_XIB(ShareBottomSheet.self)
            vc.offerModel = self.offerModel
            vc.veneuDetail = self.venueModel
            vc.isOffer = true
            vc.modalPresentationStyle = .overFullScreen
            self.parentViewController?.present(vc, animated: true)

//            Utils.generateDynamicLinks(controller: self.parentViewController, venueDetailModel: self.offerModel?.venue)
        }))

        
        alert.addAction(UIAlertAction(title: "recommend".localized(), style: .default, handler: { action in
            self._requestAddRecommendation()
        }))
        
        if _venue.isFollowing {
            alert.addAction(UIAlertAction(title: "unfollow".localized(), style: .default, handler: {action in
                self._requestFollowUnfollow()
            }))
        } else {
            alert.addAction(UIAlertAction(title: "follow".localized(), style: .default, handler: {action in
                self._requestFollowUnfollow()
            }))
        }
        
        alert.addAction(UIAlertAction(title: "cancel".localized(), style: .destructive, handler: { _ in }))
        parentViewController?.present(alert, animated: true, completion:{
            alert.view.superview?.subviews[0].isUserInteractionEnabled = true
            alert.view.superview?.subviews[0].addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertControllerBackgroundTapped)))
        })
    }

    private func _requestFollowUnfollow() {
        guard let _venue = offerModel?.venue else { return }
        WhosinServices.venueFollows(id: _venue.id) { [weak self] container, error in
            guard let self = self else { return }
            _venue.isFollowing = !_venue.isFollowing
            self.parentBaseController?.showSuccessMessage(_venue.isFollowing ? "thank_you".localized() : "oh_snap".localized() , subtitle: _venue.isFollowing ? LANGMANAGER.localizedString(forKey: "follow_venue", arguments: ["value": _venue.name]) : LANGMANAGER.localizedString(forKey: "unfollow_venue", arguments: ["value": _venue.name]))
        }
    }
    
    private func _requestAddRecommendation() {
        guard let _offerModel = offerModel else { return }
        parentBaseController?.showHUD()
        WhosinServices.addRecommendation(id: _offerModel.id, type: "offer") { [weak self] container, error in
            guard let self = self else { return }
            self.parentBaseController?.hideHUD(error: error)
            guard container != nil else { return }
            _offerModel.isRecommendation = !_offerModel.isRecommendation
            let msg = _offerModel.isRecommendation ? LANGMANAGER.localizedString(forKey: "recommending_toast", arguments: ["value": _offerModel.title]) : LANGMANAGER.localizedString(forKey: "recommending_remove_toast", arguments: ["value": _offerModel.title])
            self.parentBaseController?.showSuccessMessage(_offerModel.isRecommendation ? "thank_you".localized() :"oh_snap".localized(), subtitle: msg)
        }
    }
    
    private func _yachBottomSheet() {
        guard let _yacht = yachtOffer else { return }

        let alert = UIAlertController(title: _yacht.title, message: nil, preferredStyle: .actionSheet)
//        alert.addAction(UIAlertAction(title: "Add to Bucketlist", style: .default, handler: {action in
//            self._addToBucketList()
//        }))
        
//        alert.addAction(UIAlertAction(title: "Share", style: .default, handler: {action in
//            let vc = INIT_CONTROLLER_XIB(ShareBottomSheet.self)
//            vc.yachOfferModel = self.yachtOffer
//            vc.yachModel = yachModel
//            vc.isYachtOffer = true
//            vc.modalPresentationStyle = .overFullScreen
//            self.parentViewController?.present(vc, animated: true)
//
////            Utils.generateDynamicLinks(controller: self.parentViewController, venueDetailModel: self.offerModel?.venue)
//        }))

//        alert.addAction(UIAlertAction(title: "Recommend", style: .default, handler: { action in
//            self._requestAddRecommendation()
//        }))

        alert.addAction(UIAlertAction(title: "cancel".localized(), style: .destructive, handler: { _ in }))
        parentViewController?.present(alert, animated: true, completion:{
            alert.view.superview?.subviews[0].isUserInteractionEnabled = true
            alert.view.superview?.subviews[0].addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertControllerBackgroundTapped)))
        })
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    @IBAction func _handleMenuEvent(_ sender: UIButton) {
            switch offerType {
            case .venue, .feed:
                _venueBottomSheet()
            case .category, .search, .explore:
                _categoryBottomSheet()
            case .yacht:
                print("Somthing wrong!")
//                _yachBottomSheet()
            case .none:
                print("Somthing wrong!")
            }
    }
    
}

enum OffersType {
    case venue
    case category
    case search
    case explore
    case feed
    case yacht
}
