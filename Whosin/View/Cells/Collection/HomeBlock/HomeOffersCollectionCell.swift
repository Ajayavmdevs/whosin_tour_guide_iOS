import UIKit
import StripeCore
import ExpandableLabel

class HomeOffersCollectionCell: UICollectionViewCell {

    @IBOutlet weak var _discountTagView: UIView!
    @IBOutlet weak var _claimNowView: UIView!
    @IBOutlet weak var _buyNowView: UIView!
    @IBOutlet private weak var _inviteBtnView: UIView!
    @IBOutlet weak var _days: UILabel!
    @IBOutlet weak var _mainContainerView: UIView!
    @IBOutlet weak var _coverImage: UIImageView!
    @IBOutlet weak var _offerImage: UIImageView!
    @IBOutlet weak var _offerTime: UILabel!
    @IBOutlet weak var _offerDate: UILabel!
    @IBOutlet weak var _offerEndDate: UILabel!
    @IBOutlet weak var _discountTag: UILabel!
    private var _id: String = kEmptyString
    @IBOutlet weak var _offerTitle: UILabel!
    @IBOutlet weak var _venueInfoView: CustomVenueInfoView!
    @IBOutlet weak var _offerDescription: ExpandableLabel!
    @IBOutlet private weak var _timeStackView: UIStackView!
    @IBOutlet weak var _tillDateStack: UIStackView!
    private var _offerModel: OffersModel?
    

    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat {
        335
    }
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func awakeFromNib() {
        super.awakeFromNib()
        DISPATCH_ASYNC_MAIN_AFTER(0.02) {
            self._mainContainerView.cornerRadius = 10
        }
        _setupUi()
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func setExpandableLbl() {
        _offerDescription.isUserInteractionEnabled = false
        _offerDescription.delegate = self
        _offerDescription.shouldCollapse = true
        _offerDescription.numberOfLines = 2
        _offerDescription.ellipsis = NSAttributedString(string: "...")
        _offerDescription.collapsedAttributedLink = NSAttributedString(string: "see_more".localized(), attributes: [NSAttributedString.Key.foregroundColor: ColorBrand.brandPink])
    }
    
    private func _setupUi() {
        setExpandableLbl()
        let timeTap = UITapGestureRecognizer(target: self, action: #selector(timeEvent))
        _timeStackView.addGestureRecognizer(timeTap)

        NotificationCenter.default.addObserver(self, selector: #selector(openSuccessClaim(_:)), name: .openClaimSuccessCard, object: nil)
    }

    @objc func openSuccessClaim(_ notification: Notification) {
        if let userInfo = notification.userInfo as? [String: Any],
           let data = userInfo["data"] as? ClaimHistoryModel,
           let isFromBrunch = userInfo["isFromBrunch"] as? Bool, let specialOffer = userInfo["specialOffer"] as? SpecialOffersModel, let venue = userInfo["venue"] as? VenueDetailModel {
            let vc = INIT_CONTROLLER_XIB(ClaimSuccessfullVC.self)
            vc.modalPresentationStyle = .overFullScreen
            vc.isFromBrunch = isFromBrunch
            vc.model = data
            vc.venueModel = venue
            vc.specialOffer = specialOffer
            self.parentViewController?.present(vc, animated: true)
        }
    }

    public func setupData(_ data: OffersModel) {
        _offerModel = data
        _venueInfoView.setupData(venue: data.venue ?? VenueDetailModel(), isAllowClick: true)
        _id = data.venue?.id ?? kEmptyString
        _offerTitle.text = data.title
        setExpandableLbl()
        _offerDescription.text = data.descriptions
        _offerImage.loadWebImage(data.image)
        _coverImage.loadWebImage(data.image)
        _offerDate.text = data.startDate?.displayWithoutDay
        _offerEndDate.text = data.endDate?.displayWithoutDay
        _days.text = data.days
        _discountTagView.backgroundColor = Utils.stringIsNullOrEmpty(data.discountTag) ? .clear : ColorBrand.discountTagBgColors
        _discountTag.text = data.discountTag
        if let startDate = data.startDate?.display, !startDate.isEmpty, let endDate = data.endDate?.display, !endDate.isEmpty {
            _offerTime.text = data.timeSloat
            _offerDate.text = data.startDate?.displayWithoutDay
            _offerEndDate.text = data.endDate?.displayWithoutDay
            _tillDateStack.isHidden = false
        } else if !Utils.stringIsNullOrEmpty(data.startTime), !Utils.stringIsNullOrEmpty(data.endTime){
            _offerTime.text = "\(data.startTime) - \(data.endTime)"
            _offerDate.text = "ongoing".localized()
            _tillDateStack.isHidden = true
        } else {
            _tillDateStack.isHidden = true
            _offerDate.text = "ongoing".localized()
            _offerTime.text = data.getEventTime(venueModel: data.venue)
        }
        _buyNowView.isHidden = false
        if data.isHideBuyButton || data.packages.isEmpty || data.isPackagewithzeroPrice || data._isExpired {
            _buyNowView.isHidden = true
        }
        _inviteBtnView.isHidden = true//data._isExpired
        _claimNowView.isHidden = !data.isShowClaim
    }
    
    // --------------------------------------
    // MARK: Service
    // --------------------------------------
    
    private func _requestFollowUnfollow() {
        guard let _venue = _offerModel?.venue else { return }
        WhosinServices.venueFollows(id: _venue.id) { [weak self] container, error in
            guard let self = self else { return }
            _venue.isFollowing = !_venue.isFollowing
            self.parentBaseController?.showSuccessMessage(_venue.isFollowing ? "thank_you".localized() : "oh_snap".localized(), subtitle: _venue.isFollowing ? LANGMANAGER.localizedString(forKey: "follow_venue", arguments: ["value": _venue.name]) : LANGMANAGER.localizedString(forKey: "unfollow_venue", arguments: ["value": _venue.name]))
        }
    }
    
    private func _requestAddRecommendation() {
        guard let _venue = _offerModel?.venue else { return }
        WhosinServices.addRecommendation(id: _venue.id, type: "venue") { [weak self] container, error in
            guard let self = self else { return }
            guard let data = container else { return }
            _venue.isRecommendation = !_venue.isRecommendation
            let msg = _venue.isRecommendation ? LANGMANAGER.localizedString(forKey: "recommending_toast", arguments: ["value": _venue.name]) : LANGMANAGER.localizedString(forKey: "recommending_remove_toast", arguments: ["value": _venue.name])
            self.parentBaseController?.showSuccessMessage(_venue.isRecommendation ? "thank_you".localized() : "oh_snap".localized(), subtitle: msg)
        }
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func _openTimeDialogue() {
        let customview = TimeDailogView()
        customview._timeDetail = _offerModel?.evnetTimeSlotForNoDate(venueModel: _offerModel?.venue) ?? []
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
    
    private func _openBucketSheet() {
        let presentedViewController = INIT_CONTROLLER_XIB(BucketListBottomSheet.self)
        presentedViewController.offerId = _offerModel?.id ?? ""
        parentViewController?.presentAsPanModal(controller: presentedViewController)
    }
    
    private func _openActionSheet() {
        guard let _venue = _offerModel?.venue else { return }

        let alert = UIAlertController(title: _venue.name, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "add_to_bucketlist".localized(), style: .default, handler: {action in
            self._openBucketSheet()
        }))
        
        alert.addAction(UIAlertAction(title: "share_venue".localized(), style: .default, handler: {action in
            let vc = INIT_CONTROLLER_XIB(ShareBottomSheet.self)
            vc.veneuDetail = _venue
            vc.modalPresentationStyle = .overFullScreen
            self.parentViewController?.present(vc, animated: true)
        }))
        
        alert.addAction(UIAlertAction(title: "share_offer".localized(), style: .default, handler: {action in
            let vc = INIT_CONTROLLER_XIB(ShareBottomSheet.self)
            vc.offerModel = self._offerModel
            vc.veneuDetail = _venue
            vc.isOffer = true
            vc.modalPresentationStyle = .overFullScreen
            self.parentViewController?.present(vc, animated: true)
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
        
        alert.addAction(UIAlertAction(title: "recommend".localized(), style: .default, handler: { action in
            self._requestAddRecommendation()
        }))
        
//        alert.addAction(UIAlertAction(title: "Share", style: .default, handler: {action in
//            Utils.generateDynamicLinks(controller: self.parentViewController, venueDetailModel: _venue)
//        }))
        alert.addAction(UIAlertAction(title: "cancel".localized(), style: .cancel, handler: { _ in }))
        parentViewController?.present(alert, animated: true)
        
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------

    @objc func timeEvent() {
        parentBaseController?.feedbackGenerator?.impactOccurred()
        _openTimeDialogue()
    }
    
    @IBAction func _handleInviteEvent(_ sender: UIButton) {
        let controler = INIT_CONTROLLER_XIB(InviteBottomSheet.self)
        controler._selectedOffer = _offerModel
        controler.venueModel = _offerModel?.venue
        let navController = NavigationController(rootViewController: controler)
        navController.modalPresentationStyle = .custom
        parentBaseController?.present(navController, animated: true)
    }
    
    @IBAction private func _handleClaimNowEvent(_ sender: UIButton) {
        let controller = INIT_CONTROLLER_XIB(ClaimBrunchVC.self)
        controller.venueModel = _offerModel?.venue
        controller.specialOffer = _offerModel?.specialOffer
        let navController = NavigationController(rootViewController: controller)
        navController.modalPresentationStyle = .overFullScreen
        self.parentViewController?.present(navController, animated: true)
    }
    
    @IBAction func _handleMenuOptionsEvent(_ sender: UIButton) {
        _openActionSheet()
    }
    
    @IBAction func _handleBuyNowEvent(_ sender: Any) {
        guard let model = _offerModel else { return }
        let vc = INIT_CONTROLLER_XIB(BuyPackgeVC.self)
        vc.isFromActivity = false
        vc.type = "offers"
        vc.timingModel = model.venue?.timing.toArrayDetached(ofType: TimingModel.self)
        vc.offerModel = model
        vc.venue = model.venue
        vc.setCallback {
            let controller = INIT_CONTROLLER_XIB(MyCartVC.self)
            controller.modalPresentationStyle = .overFullScreen
            self.parentViewController?.navigationController?.pushViewController(controller, animated: true)
        }
        self.parentViewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension HomeOffersCollectionCell:  ExpandableLabelDelegate {

    func willExpandLabel(_ label: ExpandableLabel) {
    }

    func didExpandLabel(_ label: ExpandableLabel) {
        _offerDescription.superview?.setNeedsLayout()
        _offerDescription.superview?.layoutIfNeeded()
    }

    func willCollapseLabel(_ label: ExpandableLabel) {
    }

    func didCollapseLabel(_ label: ExpandableLabel) {
        _offerDescription.superview?.setNeedsLayout()
        _offerDescription.superview?.layoutIfNeeded()
    }
}
