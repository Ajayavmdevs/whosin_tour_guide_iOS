import UIKit
import StripeCore
import ExpandableLabel

class OfferSearchCollectionCell: UICollectionViewCell {

    @IBOutlet weak var _fromDateTitle: UILabel!
    @IBOutlet weak var _tillDateStackView: UIStackView!
    @IBOutlet weak var _claimNowView: UIView!
    @IBOutlet private weak var inviteView: UIView!
    @IBOutlet weak var _venueInfoView: CustomVenueInfoView!
    @IBOutlet private weak var _offerImage: UIImageView!
    @IBOutlet private weak var _offerTime: UILabel!
    @IBOutlet private weak var _offerDays: UILabel!
    @IBOutlet private weak var _offerTitle: UILabel!
    @IBOutlet private weak var _offerDescription: ExpandableLabel!
    @IBOutlet private weak var _startDate: UILabel!
    @IBOutlet private weak var _endDate: UILabel!
    private var _offerModel: OffersModel?
    private var _venueId: String = kEmptyString
    private var _logoHeroId: String = kEmptyString

    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat {
        334
    }
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setExpandableLbl()
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    private func setExpandableLbl() {
        _offerDescription.isUserInteractionEnabled = false
        _offerDescription.delegate = self
        _offerDescription.shouldCollapse = true
        _offerDescription.numberOfLines = 2
        _offerDescription.ellipsis = NSAttributedString(string: ".....")
        _offerDescription.collapsedAttributedLink = NSAttributedString(string: "more".localized(), attributes: [NSAttributedString.Key.foregroundColor: ColorBrand.brandPink])
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
        _offerDays.text = data.days
        _offerImage.loadWebImage(data.image)
        _offerTitle.text = data.title
        _offerDescription.text = data.descriptions
        _offerTime.text = data.timeSloat 
        if let startDate =  data.startDate?.display, !startDate.isEmpty {
            _tillDateStackView.isHidden = false
            _fromDateTitle.isHidden = false
            _startDate.text = data.startDate?.display ?? kEmptyString
            _endDate.text = data.endDate?.display ?? kEmptyString
        } else {
            _tillDateStackView.isHidden = true
            _fromDateTitle.isHidden = true
            _startDate.text = "ongoing".localized()
            _offerTime.text = data.getEventTime(venueModel: data.venue)
        }
        inviteView.isHidden = true//data._isExpired
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
            self.parentBaseController?.showSuccessMessage(_venue.isFollowing ? "thank_you".localized() : "oh_snap".localized(), subtitle: _venue.isFollowing ? LANGMANAGER.localizedString(forKey: "following_toast", arguments: ["value": _venue.name]) : LANGMANAGER.localizedString(forKey:"unfollow_toast", arguments: ["value": _venue.name]))

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
    
    private func _openBucketSheet() {
        let presentedViewController = INIT_CONTROLLER_XIB(BucketListBottomSheet.self)
        presentedViewController.offerId = _offerModel?.id ?? ""
        parentViewController?.presentAsPanModal(controller: presentedViewController)
    }
        
    private func _openActionSheet() {
        let alert = UIAlertController(title: kAppName, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "add_to_bucketlist".localized(), style: .default, handler: {action in
            self._openBucketSheet()
        }))
        guard let _venue = _offerModel?.venue else { return }
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

        alert.addAction(UIAlertAction(title: "share".localized(), style: .default, handler: {action in
            let vc = INIT_CONTROLLER_XIB(ShareBottomSheet.self)
            vc.offerModel = self._offerModel
            vc.veneuDetail = self._offerModel?.venue
            vc.isOffer = true
            vc.modalPresentationStyle = .overFullScreen
            self.parentViewController?.present(vc, animated: true)

        }))
        alert.addAction(UIAlertAction(title: "cancel".localized(), style: .cancel, handler: { _ in }))
        parentViewController?.present(alert, animated: true)
        
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    @IBAction private func _handleClaimNowEvent(_ sender: UIButton) {
        let controller = INIT_CONTROLLER_XIB(ClaimBrunchVC.self)
        controller.venueModel = _offerModel?.venue
        controller.specialOffer = _offerModel?.specialOffer
        let navController = NavigationController(rootViewController: controller)
        navController.modalPresentationStyle = .overFullScreen
        self.parentViewController?.present(navController, animated: true)
    }
    
    @IBAction private func _handleOpenActionsheetEvent(_ sender: UIButton) {
        _openActionSheet()
    }
    
    @IBAction private func _handleInviteEvent(_ sender: UIButton) {
        let controler = INIT_CONTROLLER_XIB(InviteBottomSheet.self)
        controler._selectedOffer = _offerModel
        controler.venueModel = _offerModel?.venue
        let navController = NavigationController(rootViewController: controler)
        navController.modalPresentationStyle = .custom
        parentBaseController?.present(navController, animated: true)
    }
}

extension OfferSearchCollectionCell:  ExpandableLabelDelegate {

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
