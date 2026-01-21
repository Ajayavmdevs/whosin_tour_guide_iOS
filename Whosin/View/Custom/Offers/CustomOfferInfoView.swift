import Foundation
import UIKit
import SnapKit


class CustomOfferInfoView: UIView {
    
    @IBOutlet private weak var _blurryImageView: UIImageView!
    @IBOutlet private weak var _tillTitle: UILabel!
    @IBOutlet private weak var _fromTitle: UILabel!
    @IBOutlet private weak var _tillDate: UILabel!
    @IBOutlet private weak var _fromDate: UILabel!
    @IBOutlet private weak var _daysLabel: UILabel!
    @IBOutlet private weak var _timeSlotButton: UIButton!
    @IBOutlet private weak var _coverImage: UIImageView!
    @IBOutlet private weak var _timeSlotLabel: UILabel!
    @IBOutlet private weak var _timeStackView: UIView!
    
    private var _offersModel: OffersModel?
    private var _venue: VenueDetailModel?
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------

    
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
        if let view = Bundle.main.loadNibNamed("CustomOfferInfoView", owner: self, options: nil)?.first as? UIView {
            addSubview(view)
            view.snp.makeConstraints { make in
                make.leading.trailing.top.bottom.equalToSuperview()
            }
        }

    }
    
    public func setupData(model: OffersModel, venue: VenueDetailModel?) {
        _offersModel = model
        _venue = venue
        _blurryImageView.loadWebImage(model.image)
        _coverImage.loadWebImage(model.image)
        _daysLabel.text = model.days
        let timeTap = UITapGestureRecognizer(target: self, action: #selector(_handleTimeEvent(_:)))
        _timeStackView.addGestureRecognizer(timeTap)
        _timeSlotButton.isHidden = false
        if let startDate =  model.startDate?.display, !startDate.isEmpty {
            _tillDate.isHidden = false
            _tillTitle.isHidden = false
            _fromTitle.isHidden = false
            _fromDate.text = startDate
            _tillDate.text = model.endDate?.display
            _timeSlotLabel.text = model.timeSloat
        } else if !Utils.stringIsNullOrEmpty(model.startTime), !Utils.stringIsNullOrEmpty(model.endTime) {
            _tillDate.isHidden = true
            _tillTitle.isHidden = true
            _fromTitle.isHidden = false
            _timeSlotButton.isHidden = false
            _fromDate.text = "Ongoing"
            _tillDate.text = model.endDate?.display
            _timeSlotLabel.text = "\(model.startTime) - \(model.endTime)"

        } else {
            _tillDate.isHidden = true
            _tillTitle.isHidden = true
            _fromTitle.isHidden = false
            _timeSlotButton.isHidden = false
            _fromDate.text = "ongoing".localized()
            _timeSlotLabel.text = model.getEventTime(venueModel: _venue)
        }
    }


  
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    private func _openTimeDialogue() {
        let customview = TimeDailogView()
        customview._timeDetail = _offersModel?.evnetTimeSlotForNoDate(venueModel: _venue) ?? []
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

    @IBAction private func _handleTimeEvent(_ sender: UIButton) {
        parentBaseController?.feedbackGenerator?.impactOccurred()
        _openTimeDialogue()
    }
}

