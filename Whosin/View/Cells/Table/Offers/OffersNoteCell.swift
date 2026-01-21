import UIKit
import ExpandableLabel

class OffersNoteCell: UITableViewCell {
    
    @IBOutlet private weak var _desclaimerView: UIView!
    @IBOutlet private weak var _description: ExpandableLabel!
    @IBOutlet private weak var _desclaimerTitle: UILabel!
    @IBOutlet private weak var _btnsStack: UIStackView!
    @IBOutlet private weak var _inviteBtnsStack: UIStackView!
    @IBOutlet private weak var _buyNowView: GradientView!
    @IBOutlet private weak var _addBucketView: GradientView!
    @IBOutlet private weak var _inviteView: UIView!
    @IBOutlet private weak var _claimView: UIView!
    @IBOutlet weak var _buyNowButton: UIButton!
    private var offerModel: OffersModel?
    private var venue: VenueDetailModel?
    public var timingModel: [TimingModel]?
    private var _callback: BooleanResult?

    class var height: CGFloat { UITableView.automaticDimension }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        disableSelectEffect()
        _setUplabel()
        _addBucketView.isHidden = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    private func _setUplabel() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(labelTapped))
        _description.isUserInteractionEnabled = true
        _description.addGestureRecognizer(tapGesture)
        _description.delegate = self
        _description.shouldCollapse = true
        _description.numberOfLines = 2
        _description.ellipsis = NSAttributedString(string: "...")
        _description.collapsedAttributedLink = NSAttributedString(string: "see_more".localized(), attributes: [NSAttributedString.Key.foregroundColor: ColorBrand.brandPink])
        _description.setLessLinkWith(lessLink: "less".localized(), attributes: [NSAttributedString.Key.foregroundColor: ColorBrand.brandPink], position: .left)
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

    public func setupData(_ data: OffersModel, venueModel: VenueDetailModel, callback: BooleanResult?) {
        _callback = callback
        offerModel = data
        venue = venueModel
        _buyNowView.isHidden = false
        if Utils.stringIsNullOrEmpty(data.disclaimerDescription) && Utils.stringIsNullOrEmpty(data.disclaimerTitle) {
            _desclaimerView.isHidden = true
        } else {
            _desclaimerView.isHidden = false
            _description.text = data.disclaimerDescription
            _desclaimerTitle.text = data.disclaimerTitle
        }

        if data.isHideBuyButton || data.packages.isEmpty || data.isPackagewithzeroPrice {
            _buyNowView.isHidden = true
        }

        _btnsStack.isHidden = data._isExpired
        _inviteBtnsStack.isHidden = data._isExpired
        _claimView.isHidden = !data.isShowClaim
    }
    
    public func setupVoucherData(_ model: DealsModel, venueModel: VenueDetailModel) {
        _btnsStack.isHidden = true
        venue = venueModel
    }
    
    
    @IBAction private func _handleAddBucketEvent(_ sender: UIButton) {
        let presentedViewController = INIT_CONTROLLER_XIB(BucketListBottomSheet.self)
        presentedViewController.offerId = offerModel?.id ?? kEmptyString
        parentViewController?.presentAsPanModal(controller: presentedViewController)
    }

    @IBAction func _handleInviteEvent(_ sender: UIButton) {
    }

    @IBAction private func _handleClaimNowEvent(_ sender: UIButton) {
        let controller = INIT_CONTROLLER_XIB(ClaimBrunchVC.self)
        controller.venueModel = offerModel?.venue
        controller.specialOffer = offerModel?.specialOffer
        let navController = NavigationController(rootViewController: controller)
        navController.modalPresentationStyle = .overFullScreen
        self.parentViewController?.present(navController, animated: true)
    }

    @IBAction private func _handleBuyNowEvent(_ sender: UIButton) {
        _callback?(true, nil)
    }
    
    @objc private func labelTapped() {
        _description.collapsed.toggle()
        (self.superview as? CustomTableView)?.update()
    }
}

extension OffersNoteCell:  ExpandableLabelDelegate {
    
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
