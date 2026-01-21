import UIKit
import StripeCore

class OfferDetailHeader: UITableViewCell {
    
    @IBOutlet private weak var _recomendionView: UIView!
    @IBOutlet weak var cellTitle: UILabel!
    @IBOutlet private weak var _coverImage: UIImageView!
    @IBOutlet private weak var _startDate: UILabel!
    @IBOutlet private weak var _endDate: UILabel!
    @IBOutlet private weak var _days: UILabel!
    @IBOutlet private weak var _time: UILabel!
    @IBOutlet private weak var _badgeView: CustomBadgeView!
    @IBOutlet private weak var _recommededIcon: UIImageView!
    @IBOutlet private weak var _fromTitleLbl: UILabel!
    @IBOutlet private weak var _tillTitleLbl: UILabel!
    @IBOutlet weak var _timeSlotButton: UIButton!
    @IBOutlet private weak var _timeStackView: UIStackView!
    private var _venueId: String = kEmptyString
    private var offersModel: OffersModel?
    public var _venueModel: VenueDetailModel?
    public var timingModel: [TimingModel]?
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
        _timeSlotButton.isHidden = true
        DISPATCH_ASYNC_MAIN_AFTER(0.02) {
            self._badgeView.roundCorners(corners: [.topRight, .bottomLeft], radius: 10)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // --------------------------------------
    // MARK: Service
    // --------------------------------------
    
    private func _requestAddRecommendation(_ offerId: String) {
        guard let _offerModel = offersModel else { return }
        parentBaseController?.showHUD()
        WhosinServices.addRecommendation(id: _offerModel.id, type: "offer") { [weak self] container, error in
            guard let self = self else { return }
            self.parentBaseController?.hideHUD(error: error)
            guard container != nil else { return }
            _offerModel.isRecommendation = !_offerModel.isRecommendation
            self._recommededIcon.tintColor =  _offerModel.isRecommendation ? ColorBrand.brandBtnBgColor : ColorBrand.white
            let msg = _offerModel.isRecommendation ? LANGMANAGER.localizedString(forKey: "recommending_toast", arguments: ["value": _offerModel.title]) : LANGMANAGER.localizedString(forKey: "recommending_remove_toast", arguments: ["value": _offerModel.title])
            self.parentBaseController?.showSuccessMessage(_offerModel.isRecommendation ? "thank_you".localized() :"oh_snap".localized(), subtitle: msg)
        }
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------

    public func setupData(_ model: OffersModel, venueModel: VenueDetailModel) {
        _recommededIcon.tintColor =  model.isRecommendation ? ColorBrand.brandBtnBgColor : ColorBrand.white
        _recomendionView.isHidden = false
        _badgeView.isHidden = true
        offersModel = model
        _venueId = venueModel.id
        _venueModel = venueModel
        cellTitle.text = model.title
        _coverImage.loadWebImage(model.image)
        _days.text = model.days
        if let startDate = model.startDate, let endDate = model.endDate {
            _endDate.isHidden = false
            _tillTitleLbl.isHidden = false
            _fromTitleLbl.isHidden = false
            _timeSlotButton.isHidden = true
            _startDate.text = startDate.display
            _endDate.text =  endDate.display
            _time.text = model.timeSloat
        } else {
            _endDate.isHidden = true
            _tillTitleLbl.isHidden = true
            _fromTitleLbl.isHidden = true
            _timeSlotButton.isHidden = false
            let timeTap = UITapGestureRecognizer(target: self, action: #selector(timeEvent))
            _timeStackView.addGestureRecognizer(timeTap)
            _startDate.text = "ongoing".localized()
            _time.text = model.getEventTime(timingModel: timingModel)
        }
    }

    @IBAction private func _handleTimeEvent(_ sender: UIButton) {
        parentBaseController?.feedbackGenerator?.impactOccurred()
        _openTimeDialogue()
    }

    @objc func timeEvent() {
        parentBaseController?.feedbackGenerator?.impactOccurred()
        _openTimeDialogue()
    }
    
    private func _openTimeDialogue() {
        let customview = TimeDailogView()
        customview._timeDetail = offersModel?.evnetTimeSlotForNoDate(timingModel: timingModel) ?? []
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

    public func setupVoucherData(_ data: DealsModel) {
        _recomendionView.isHidden = true
        _badgeView.isHidden = false
        _badgeView.setupData(originalPrice: data.actualPrice, discountedPrice: "\(data.discountedPrice)", isNoDiscount: data._isNoDiscount)
        _venueId = data.venueId
        _venueModel = data.venueModel
        cellTitle.text = data.title
        _days.text = data.days
        _coverImage.loadWebImage(data.image)
        _startDate.text = data._startDate
        _endDate.text = data._endtDate
        _time.text = Utils.formatTimeRange(start: data.startTime, end: data.endTime)
    }
    
    // --------------------------------------
    // MARK: Events
    // --------------------------------------
    
    @IBAction private func handleOpenVenueDetail( sender: UIButton) {
        let controller = INIT_CONTROLLER_XIB(VenueDetailsVC.self)
        controller.venueId = _venueId
        controller.venueDetailModel = _venueModel
        parentViewController?.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func _handleAddRecommendationEvent(_ sender: UIButton) {
        guard let id = offersModel?.id else { return }
        _requestAddRecommendation(id)
    }
}
