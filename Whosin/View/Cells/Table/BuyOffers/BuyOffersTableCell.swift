import UIKit

class BuyOffersTableCell: UITableViewCell {

    @IBOutlet private weak var _bgView: UIView!
    @IBOutlet private weak var _offersCoverImage: UIImageView!
    @IBOutlet private weak var _offersTimeLAbel: UILabel!
    @IBOutlet private weak var _offersDayLabel: UILabel!
    @IBOutlet private weak var _imageHight: NSLayoutConstraint!
    @IBOutlet private weak var _startDate: UILabel!
    @IBOutlet private weak var _endDate: UILabel!
    @IBOutlet private weak var _fromTitleLbl: UILabel!
    @IBOutlet private weak var _tillTitleLbl: UILabel!
    @IBOutlet weak var _timeSlotButton: UIButton!
    @IBOutlet private weak var _timeStackView: UIStackView!
    private var isFromCatefory: Bool = false
    private var offersModel: OffersModel?
    private var eventModel: EventModel?
    public var timingModel: [TimingModel]?

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
    // MARK: Private
    // --------------------------------------
    
    private func _setupUi() {
        disableSelectEffect()
    }

    private func _loadVenueData() {
        _offersCoverImage.loadWebImage(offersModel?.image ?? "")
        _offersDayLabel.text = offersModel?.days
        if let startDate = offersModel?.startDate, let endDate = offersModel?.endDate {
            _endDate.isHidden = false
            _tillTitleLbl.isHidden = false
            _fromTitleLbl.isHidden = false
            _timeSlotButton.isHidden = true
            _startDate.text = startDate.display
            _endDate.text =  endDate.display
            _offersTimeLAbel.text = offersModel?.timeSloat ?? kEmptyString
        } else {
            _endDate.isHidden = true
            _tillTitleLbl.isHidden = true
            _fromTitleLbl.isHidden = true
            _timeSlotButton.isHidden = false
            let timeTap = UITapGestureRecognizer(target: self, action: #selector(timeEvent))
            _timeStackView.addGestureRecognizer(timeTap)

            _startDate.text = "ongoing".localized()
            _offersTimeLAbel.text = offersModel?.getEventTime(timingModel: timingModel)
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

    private func _loadEventData() {
        _offersCoverImage.loadWebImage(eventModel?.image ?? "")
        _offersTimeLAbel.text = eventModel?.eventTimeSlot
        _offersDayLabel.text = Utils.getDay(from: eventModel?.eventTime ?? "")
        _startDate.text = eventModel?._eventDate
        _endDate.text = eventModel?._reservationTime
    }

    private func checkDays(_ daysString: String?) -> String {
        let days = daysString?.components(separatedBy: ",")
        
        if days?.count == 7 {
            return "all days"
        } else {
            return daysString ?? ""
        }
    }

    // --------------------------------------
    // MARK: Public
    // --------------------------------------

    public func setupData(_ data: OffersModel) {
        offersModel = data
        isFromCatefory = false
        _loadVenueData()
    }
    
    public func setupEventData(_ data: EventModel) {
        eventModel = data
        _loadEventData()
    }
        
}

extension BuyOffersTableCell: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return CustomBottomSheet(presentedViewController: presented, presenting: presenting)
    }
}
