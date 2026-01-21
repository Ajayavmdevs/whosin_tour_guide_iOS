import UIKit
import CountdownLabel
import ExpandableLabel

class EventInfoTableCell: UITableViewCell {

    @IBOutlet weak var _customPackageView: CustomPackageView!
    @IBOutlet weak var _packageView: UIView!
    @IBOutlet private weak var _decription: ExpandableLabel!
    @IBOutlet private weak var _declaimerTitle: UILabel!
    @IBOutlet private weak var _declaimerView: UIView!
    @IBOutlet weak var _venueInfoView: CustomVenueInfoView!
    @IBOutlet weak var _buyNowView: GradientView!
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
            self.makeToast(data.message)
            DISPATCH_ASYNC_MAIN_AFTER(0.7) {
                self.parentViewController?.dismiss(animated: true, completion: nil)
                NotificationCenter.default.post(name: kReloadBucketList, object: nil, userInfo: nil)
            }
        }
    }
    
    private func setExpandableLbl() {
        _offersDescLabel.isUserInteractionEnabled = false
        _offersDescLabel.delegate = self
        _offersDescLabel.shouldCollapse = true
        _offersDescLabel.numberOfLines = 2
        _offersDescLabel.ellipsis = NSAttributedString(string: "....")
        _offersDescLabel.collapsedAttributedLink = NSAttributedString(string: "more".localized(), attributes: [NSAttributedString.Key.foregroundColor: ColorBrand.brandPink])
    }

    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func _setupUi() {
        disableSelectEffect()
        setExpandableLbl()
    }


    private func _setUplabel() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(labelTapped))
        _decription.isUserInteractionEnabled = true
        _decription.addGestureRecognizer(tapGesture)
        _decription.delegate = self
        _decription.shouldCollapse = true
        _decription.numberOfLines = 2
        _decription.ellipsis = NSAttributedString(string: "...")
        _decription.collapsedAttributedLink = NSAttributedString(string: "see_more".localized(), attributes: [NSAttributedString.Key.foregroundColor: ColorBrand.brandPink])
        _decription.setLessLinkWith(lessLink: "less".localized(), attributes: [NSAttributedString.Key.foregroundColor: ColorBrand.brandPink], position: .left)
    }
    
    @objc private func labelTapped() {
        _decription.collapsed.toggle()
        (self.superview as? CustomTableView)?.update()
    }

    private func _loadVenueData() {
        guard let eventModel = eventModel else { return }
        _buyNowView.isHidden = eventModel.packages.isEmpty
        _packageView.isHidden = eventModel.packages.isEmpty
        _customPackageView.setupData(model: eventModel.packages.toArrayDetached(ofType: PackageModel.self ))
        if let venue = eventModel.venueDetail {
            _venueInfoView.setupData(venue: venue, isAllowClick: true)
        }
        if Utils.stringIsNullOrEmpty(eventModel.disclaimerDescription) && Utils.stringIsNullOrEmpty(eventModel.disclaimerTitle) {
            _declaimerView.isHidden = true
        } else {
            _declaimerView.isHidden = false
            _declaimerTitle.text = eventModel.disclaimerTitle
            _decription.text = eventModel.disclaimerDescription
        }
        _buyNowView.isHidden = false
        _offersDescLabel.text = eventModel.descriptions
        _offersTimeLAbel.text = eventModel.eventTimeSlot
        _offersDayLabel.text = eventModel._eventDate
        _offersTitleLabel.text = eventModel.title
        _offersCoverImage.loadWebImage(eventModel.image )
        _buyNowButton.setTitle(eventModel._isEventExpired ? "expired".localized() : "buy_now".localized())
        _buyNowButton.setTitleColor(eventModel._isEventExpired ? ColorBrand.brandPink : ColorBrand.white, for: .normal)
        _buyNowView.backgroundColor = eventModel._isEventExpired ? .clear : ColorBrand.brandBtnBgColor
        _buyNowButton.isEnabled = eventModel._isEventExpired ? false : true
        
        if eventModel.isHideBuyButton || eventModel.packages.isEmpty || eventModel.isPackagewithzeroPrice {
            _buyNowView.isHidden = true
        }
        if !Utils.stringIsNullOrEmpty(eventModel.eventTime) {
            _starttime = Date(timeInterval: "\(Date())".toDate(format: kStanderdDate).timeIntervalSince(Date()), since: Date())
            _endtime = Date(timeInterval: (eventModel.eventTime.toDate(format: kStanderdDate).timeIntervalSince(Date())), since: Date())
            if !Utils.stringIsNullOrEmpty(eventModel.eventTime) {
                _starttime = Date(timeInterval: "\(Date())".toDate(format: kStanderdDate).timeIntervalSince(Date()), since: Date())
                _endtime = Date(timeInterval: (eventModel.eventTime.toDate(format: kStanderdDate).timeIntervalSince(Date())), since: Date())
                _countDownLabel.animationType = .Evaporate
                _countDownLabel.timeFormat = "dd:HH:mm:ss"
                _countDownLabel.setCountDownDate(fromDate: _starttime! as NSDate, targetDate: _endtime! as NSDate)
                _countDownLabel.start()
                _countdownEffectView.isHidden = eventModel._isEventExpired ? true : false
            } else {
                _countdownEffectView.isHidden = true
            }
            
            _offersStack.isHidden = false
        }
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------

    public func setupData(_ data: EventModel, isFromBucket: Bool = false, isFromEvent: Bool = false) {
        eventModel = data
        _loadVenueData()
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    @IBAction func _handleOpenVenueDetail(_ sender: UIButton) {
        let controller = INIT_CONTROLLER_XIB(VenueDetailsVC.self)
        controller.modalPresentationStyle = .overFullScreen
        controller.venueId = eventModel?.venue ?? kEmptyString
        controller.venueDetailModel = Utils.getModelFromId(model: APPSETTING.venueModel, id: eventModel?.venue ?? kEmptyString)
        parentViewController?.navigationController?.pushViewController(controller, animated: true)
    }
    
    
    @IBAction func _handlebuyNowEvent(_ sender: UIButton) {
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

extension EventInfoTableCell: ShowMembershipInfoDelegate {
    func ShowMembershipDetail() {
        let vc = INIT_CONTROLLER_XIB(MembershipDetailVC.self)
        vc.modalPresentationStyle = .overFullScreen
        vc.hidesBottomBarWhenPushed = true
        parentViewController?.present(vc, animated: true)
    }
}

extension EventInfoTableCell:  ExpandableLabelDelegate {
    
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
