import UIKit
import ExpandableLabel

protocol ReloadBucketList {
    func reload()
}
class BucketOffersTableCell: UITableViewCell {
    
    @IBOutlet private weak var _customPackgeView: CustomPackageView!
    @IBOutlet private weak var _customTitleView: CustomOfferTitleView!
    @IBOutlet private weak var _customOfferView: CustomOfferInfoView!
    @IBOutlet private weak var _customVenueView: CustomVenueInfoView!
    public var bucketItemModel: OffersModel?
    public var bucketId: String = kEmptyString
    public var bucketModel: BucketDetailModel?
    private var _venueId: String = kEmptyString
    private var _logoHeroId: String = kEmptyString
    public var delegate: ReloadBucketList?

    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    static var height: CGFloat { UITableView.automaticDimension }
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func awakeFromNib() {
        super.awakeFromNib()
        _setupUi()
    }

    override func prepareForReuse() {
        if bucketItemModel != nil {
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // --------------------------------------
    // MARK: Service
    // --------------------------------------
    
    private func _requestRemoveItem() {
        var params: [String: Any] = [:]
        params["id"] = bucketId
        params["action"] = "delete"
        params["offerId"] = bucketItemModel?.id ?? ""
        WhosinServices.addRemoveBucketList(params: params) { [weak self] container, error in
            guard let self = self else { return }
            guard let data = container else { return }
            self.parentViewController?.view.makeToast(data.message)
            self.delegate?.reload()
        }
    }
    
    private func _requestAddRecommendation() {
        guard let _venue = bucketItemModel?.venue else { return }
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
    
    private func _setupUi() {
        disableSelectEffect()
    }
    
    private func _moveToanotherBucket() {
        let presentedViewController = INIT_CONTROLLER_XIB(BucketListBottomSheet.self)
        presentedViewController.offerId = bucketItemModel?.id ?? kEmptyString
        presentedViewController._bucketId = bucketId
        presentedViewController.isFromMoveToAnother = true
        parentViewController?.presentAsPanModal(controller: presentedViewController)
    }
    
    private func _openActionSheet() {
        let alert = UIAlertController(title: bucketItemModel?.venue?.name ?? kEmptyString, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "remove".localized(), style: .destructive, handler: {action in
            DISPATCH_ASYNC_MAIN {
                self.parentBaseController?.showCustomAlert(title: kAppName, message: "remove_offer_from_bucket".localized(), yesButtonTitle: "yes".localized(), noButtonTitle: "cancel".localized(), okHandler: { UIAlertAction in
                    self._requestRemoveItem()
                }, noHandler:  { UIAlertAction in
                })
            }
        }))
        alert.addAction(UIAlertAction(title: "move_to_another_bucket".localized(), style: .default, handler: {action in
            DISPATCH_ASYNC_MAIN { self._moveToanotherBucket() }
        }))
        
        alert.addAction(UIAlertAction(title: "recommend".localized(), style: .default, handler: { action in
            self._requestAddRecommendation()
        }))
        
        alert.addAction(UIAlertAction(title: "share".localized(), style: .default, handler: {action in
            let vc = INIT_CONTROLLER_XIB(ShareBottomSheet.self)
            vc.offerModel = self.bucketItemModel
            vc.veneuDetail = self.bucketItemModel?.venue
            vc.isOffer = true
            vc.modalPresentationStyle = .overFullScreen
            self.parentViewController?.present(vc, animated: true)

//            Utils.generateDynamicLinks(controller: self.parentViewController, venueDetailModel: self.offerModel?.venue)
        }))

//        alert.addAction(UIAlertAction(title: "Share", style: .default, handler: {action in
//            Utils.generateDynamicLinks(controller: self.parentViewController, venueDetailModel: self.bucketItemModel?.venue)
//        }))
        
        alert.addAction(UIAlertAction(title: "cancel".localized(), style: .cancel, handler: { _ in }))
        parentViewController?.present(alert, animated: true)
        
    }
    
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setupData(_ model: OffersModel) {
        bucketItemModel = model
        _customVenueView.setupData(venue: model.venue ?? VenueDetailModel(), isAllowClick: true)
        _customOfferView.setupData(model: model, venue: model.venue)
        _customTitleView.setupData(model: model)
        _customPackgeView.setupData(model: model.packages.toArrayDetached(ofType: PackageModel.self))
        _customPackgeView.isHidden = model.packages.isEmpty
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    @IBAction private func _handleRemoveItemEvent(_ sender: UIButton) {
        _openActionSheet()
    }
    
    @IBAction private func _letsGoEvenHandle(_ sender: UIButton) {
        let controler = INIT_CONTROLLER_XIB(InviteBottomSheet.self)
        controler.venueModel = bucketItemModel?.venue
        controler._selectedOffer = bucketItemModel
        if let bucketModel = bucketModel {
            controler.selectedContacts = bucketModel.sharedWith.filter { $0.id != APPSESSION.userDetail?.id }
            controler.userIds = bucketModel.sharedWith
                .filter { $0.id != APPSESSION.userDetail?.id }
                .map { $0.id }
        }
        let navController = NavigationController(rootViewController: controler)
        navController.modalPresentationStyle = .custom
        parentBaseController?.present(navController, animated: true)
    }
    
}


extension BucketOffersTableCell: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return CustomBottomSheet(presentedViewController: presented, presenting: presenting)
    }
}

extension BucketOffersTableCell: ShowMembershipInfoDelegate {
    func ShowMembershipDetail() {
        let vc = INIT_CONTROLLER_XIB(MembershipDetailVC.self)
        vc.modalPresentationStyle = .overFullScreen
        vc.hidesBottomBarWhenPushed = true
        parentViewController?.present(vc, animated: true)
    }
}
