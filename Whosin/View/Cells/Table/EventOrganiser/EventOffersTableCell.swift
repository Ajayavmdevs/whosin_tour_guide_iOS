import UIKit
import CountdownLabel
import ExpandableLabel

class EventOffersTableCell: UITableViewCell {

    @IBOutlet private weak var _customPackageView: CustomPackageView!
    @IBOutlet private weak var _buyNowView: GradientView!
    @IBOutlet private weak var _bucketButtonView: GradientView!
    @IBOutlet private weak var _menuButton: UIButton!
    @IBOutlet weak var _customVenueInfo: CustomVenueInfoView!
    @IBOutlet private weak var _countdownEffectView: UIVisualEffectView!
    @IBOutlet private weak var _countDownLabel: CountdownLabel!
    @IBOutlet private weak var _offersTitleLabel: UILabel!
    @IBOutlet private weak var _offersCoverImage: UIImageView!
    @IBOutlet private weak var _offersTimeLAbel: UILabel!
    @IBOutlet private weak var _offersDayLabel: UILabel!
    @IBOutlet private weak var _offersDescLabel: ExpandableLabel!
    @IBOutlet private weak var _offersStack: UIStackView!
    @IBOutlet weak var _buyNowButton: UIButton!
    private var eventModel: EventModel?
    private var categoryModel: OffersModel?
    public var delegate: ReloadBucketList?
    private var _starttime : Date?
    private var _endtime : Date?
    public var bucketId: String = kEmptyString

    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------

    class var height: CGFloat {
        UITableView.automaticDimension
    }

    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
        _setupUi()
    }
    
    private func setExpandableLbl() {
        _offersDescLabel.isUserInteractionEnabled = false
        _offersDescLabel.delegate = self
        _offersDescLabel.shouldCollapse = true
        _offersDescLabel.numberOfLines = 3
        _offersDescLabel.ellipsis = NSAttributedString(string: "....")
        _offersDescLabel.collapsedAttributedLink = NSAttributedString(string: " more ", attributes: [NSAttributedString.Key.foregroundColor: ColorBrand.brandPink])
    }
    
    // --------------------------------------
    // MARK: Service
    // --------------------------------------
    
    private func _requestRemoveItem() {
        var params: [String: Any] = [:]
        params["id"] = bucketId
        params["action"] = "delete"
        params["eventId"] = eventModel?.id ?? ""
        WhosinServices.addRemoveBucketList(params: params) { [weak self] container, error in
            guard let self = self else { return }
            guard let data = container else { return }
            self.parentViewController?.view.makeToast(data.message)
            self.delegate?.reload()
        }
    }
    
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func _setupUi() {
        disableSelectEffect()
        setExpandableLbl()
    }
    

    private func _loadVenueData() {
        if let package = eventModel?.packages {
            _buyNowView.isHidden = package.isEmpty
            _customPackageView.isHidden = package.isEmpty
            _customPackageView.setupData(model: package.toArrayDetached(ofType: PackageModel.self))
        } else {
            _buyNowView.isHidden = true
            _customPackageView.isHidden = true
        }
        if let venue = Utils.getModelFromId(model: APPSETTING.venueModel, id: eventModel?.venue ?? "") {
            _customVenueInfo.setupData(venue: venue, isAllowClick: true)
        } else if let model = eventModel?.venueDetail {
            _customVenueInfo.setupData(venue: model, isAllowClick: true)
        } else {
            _customVenueInfo.setupData(venue: eventModel?.orgData ?? VenueDetailModel(), isAllowClick: true)
        }
        _offersCoverImage.loadWebImage(eventModel?.image ?? "")
        _offersDescLabel.text = eventModel?.descriptions
        _offersTimeLAbel.text = eventModel?.eventTimeSlot
        _offersDayLabel.text = eventModel?._eventDate
        _offersTitleLabel.text = eventModel?.title
        _offersCoverImage.loadWebImage(eventModel?.image ?? "")
        
        if !Utils.stringIsNullOrEmpty(eventModel?.eventTime) {
            _starttime = Date(timeInterval: "\(Date())".toDate(format: kStanderdDate).timeIntervalSince(Date()), since: Date())
            _endtime = Date(timeInterval: (eventModel?.eventTime.toDate(format: kStanderdDate).timeIntervalSince(Date()))!, since: Date())
            _countDownLabel.animationType = .Evaporate
            _countDownLabel.timeFormat = "dd:HH:mm:ss"
            _countDownLabel.setCountDownDate(fromDate: _starttime! as NSDate, targetDate: _endtime! as NSDate)
            _countDownLabel.start()
            _countdownEffectView.isHidden = eventModel?._isEventExpired == true ? true : false
        } else {
            _countdownEffectView.isHidden = true
        }
        _buyNowView.isHidden = false
        if eventModel?._isEventExpired == true {
            _bucketButtonView.isHidden = true
        }
        _buyNowButton.setTitle(eventModel?._isEventExpired == true ? "expired".localized() : "buy_now".localized())
        _buyNowButton.setTitleColor(eventModel?._isEventExpired == true ? ColorBrand.brandPink : ColorBrand.white, for: .normal)
        _buyNowView.backgroundColor = eventModel?._isEventExpired == true ? .clear : ColorBrand.brandBtnBgColor
        _buyNowButton.isEnabled = eventModel?._isEventExpired == true ? false : true
        _offersStack.isHidden = false
        if eventModel?._isEventExpired == false {
            _buyNowView.isHidden = eventModel?.packages.isEmpty ?? true ? true : eventModel?.isPackagewithzeroPrice ?? true
            _buyNowView.isHidden = eventModel?.isHideBuyButton ?? true
        }

    }
    
    private func _openActionSheet() {
        let alert = UIAlertController(title: kAppName, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "remove".localized(), style: .destructive, handler: {action in
            DISPATCH_ASYNC_MAIN {
                self.parentBaseController?.showCustomAlert(title: kAppName, message: "remove_event_from_bucket".localized(), yesButtonTitle: "yes".localized(), noButtonTitle: "cancel".localized(), okHandler: { UIAlertAction in
                    self._requestRemoveItem()
                }, noHandler:  { UIAlertAction in
                })

            }
        }))
        alert.addAction(UIAlertAction(title: "move_to_another_bucket".localized(), style: .default, handler: {action in
            DISPATCH_ASYNC_MAIN { self._requestRemoveItem() }
        }))

        alert.addAction(UIAlertAction(title: "cancel".localized(), style: .cancel, handler: { _ in }))
        parentViewController?.present(alert, animated: true)

    }
    
    private func _moveToanotherBucket() {
        let presentedViewController = INIT_CONTROLLER_XIB(BucketListBottomSheet.self)
        presentedViewController.activityId = eventModel?.id ?? kEmptyString
        presentedViewController._bucketId = bucketId
        presentedViewController.isFromMoveToAnother = true
        parentViewController?.presentAsPanModal(controller: presentedViewController)
    }

    // --------------------------------------
    // MARK: Public
    // --------------------------------------

    public func setupData(_ data: EventModel, isFromBucket: Bool = false) {
        _bucketButtonView.isHidden = isFromBucket
        _menuButton.isHidden = !isFromBucket
        eventModel = data
        _loadVenueData()
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------

    @IBAction private func _handleAddBucketListEvent(_ sender: UIButton) {
        let presentedViewController = INIT_CONTROLLER_XIB(BucketListBottomSheet.self)
        presentedViewController.eventId = eventModel?.id ?? ""
        parentViewController?.presentAsPanModal(controller: presentedViewController)
    }
    
    @IBAction private func _handleMenuAction(_ sender: UIButton) {
        _openActionSheet()
    }
    
    @IBAction private func _handleBuyNowEvent(_ sender: UIButton) {
        guard let model = eventModel else { return }
        let vc = INIT_CONTROLLER_XIB(BuyPackgeVC.self)
        vc.type = "event"
        vc.eventModel = model
        vc.setCallback {
            let controller = INIT_CONTROLLER_XIB(MyCartVC.self)
            controller.modalPresentationStyle = .overFullScreen
            self.parentViewController?.navigationController?.pushViewController(controller, animated: true)
        }
        parentViewController?.navigationController?.pushViewController(vc, animated: true)
    }
}

extension EventOffersTableCell: ShowMembershipInfoDelegate {
    func ShowMembershipDetail() {
        let vc = INIT_CONTROLLER_XIB(MembershipDetailVC.self)
        vc.modalPresentationStyle = .overFullScreen
        vc.hidesBottomBarWhenPushed = true
        parentViewController?.present(vc, animated: true)
    }
}

extension EventOffersTableCell:  ExpandableLabelDelegate {

    func willExpandLabel(_ label: ExpandableLabel) {
    }

    func didExpandLabel(_ label: ExpandableLabel) {
        _offersDescLabel.superview?.setNeedsLayout()
        _offersDescLabel.superview?.layoutIfNeeded()
    }

    func willCollapseLabel(_ label: ExpandableLabel) {
    }

    func didCollapseLabel(_ label: ExpandableLabel) {
        _offersDescLabel.superview?.setNeedsLayout()
        _offersDescLabel.superview?.layoutIfNeeded()
    }
}
