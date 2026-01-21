import UIKit
import CountdownLabel

class EventCollectionCell: UICollectionViewCell {

    @IBOutlet weak var _venueInfoView: CustomVenueInfoView!
    @IBOutlet private weak var _imgBgView: UIView!
    @IBOutlet private weak var _countDownView: UIVisualEffectView!
    @IBOutlet private weak var _ratingsLabel: UILabel!
    @IBOutlet private weak var _ratingView: UIView!
    @IBOutlet private weak var _titleLabel: UILabel!
    @IBOutlet private weak var _eventTitleLabel: UILabel!
    @IBOutlet private weak var _imageLogoView: UIImageView!
    @IBOutlet private weak var _detailLabel: UILabel!
    @IBOutlet private weak var _countDownLabel: CountdownLabel!
    @IBOutlet private weak var _coverImage: UIImageView!
    @IBOutlet weak var _mainContainerView: UIView!
    @IBOutlet weak var _visualEffectView: UIVisualEffectView!
    @IBOutlet weak var _mainTrailing: NSLayoutConstraint!

    private var _starttime : Date?
    private var _endtime : Date?
    private var _eventId: String = kEmptyString
    private var _venueId: String = kEmptyString
    private var _orgId: String = kEmptyString

    // --------------------------------------
    // MARK: Class1
    // --------------------------------------
    
    class var height: CGFloat { 424 }
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUi()
    }

    // --------------------------------------
    // MARK: Private
    // --------------------------------------

    private func setupUi() {
        DISPATCH_ASYNC_MAIN_AFTER(0.2) {
            self._mainContainerView.roundCorners(corners: [.bottomLeft, .bottomRight, .topLeft, .topRight], radius: 10)
            self._visualEffectView.roundCorners(corners: [.topLeft, .bottomLeft], radius: 10)
        }
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setUpdata(_ model: EventModel) {
        _eventId = model.id
        _eventTitleLabel.text = model.title
        _orgId = model.orgData?.id ?? kEmptyString
        _venueInfoView.setupData(venue: model.venueDetail ?? VenueDetailModel())
        _coverImage.loadWebImage(model.image) { [weak self] in
            if let img  = self?._coverImage.image {
                DispatchQueue.global(qos: .userInitiated).async {
                    let color = try? img.averageColor()
                    DISPATCH_ASYNC_MAIN {
                        self?._mainContainerView.borderColor = color ?? .red
                    }
                }
            }
        }
        _ratingsLabel.text = String(format: "%.1f", model.orgData?.avgRatings ?? 0.0)
        if model.orgData?.avgRatings == 0.0 {
            _ratingView.isHidden = true
        }
        _detailLabel.text = model.orgData?.address
        _imageLogoView.loadWebImage(model.orgData?.logo ?? "", name: model.orgData?.name ?? "")
        _titleLabel.text = model.orgData?.name
        if !Utils.stringIsNullOrEmpty(model.eventTime) {
            _starttime = Date(timeInterval: "\(Date())".toDate(format: kStanderdDate).timeIntervalSince(Date()), since: Date())
            _endtime = Date(timeInterval: model.eventTime.toDate(format: kStanderdDate).timeIntervalSince(Date()), since: Date())
            _countDownLabel.animationType = .Evaporate
            _countDownLabel.timeFormat = "dd:HH:mm:ss"
            _countDownLabel.setCountDownDate(fromDate: _starttime! as NSDate, targetDate: _endtime! as NSDate)
            _countDownLabel.start()
            _countDownView.isHidden = model._isEventExpired ? true : false
        } else {
            _countDownView.isHidden = true
        }
        _venueId = model.venueDetail?.id ?? kEmptyString
        let randomStr = Utils.randomString(length: 20, id: _venueId + model.id)
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------

    @IBAction func _handleOpenEventOrganizerDetailsEvent(_ sender: UIButton) {
        let vc = INIT_CONTROLLER_XIB(EventOrganisierVC.self)
        vc.orgId = _orgId
        vc.modalPresentationStyle = .overFullScreen
        parentViewController?.navigationController?.pushViewController(vc, animated: true)
    }

}
