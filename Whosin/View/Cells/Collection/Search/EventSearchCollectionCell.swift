import UIKit
import ExpandableLabel
import CountdownLabel

class EventSearchCollectionCell: UICollectionViewCell {

    @IBOutlet weak var _venueInfoView: CustomVenueInfoView!
    @IBOutlet weak var _orgImg: UIImageView!
    @IBOutlet weak var _orgView: UIView!
    @IBOutlet weak var _orgName: UILabel!
    @IBOutlet weak var _orgWebsite: UILabel!
    @IBOutlet private weak var _eventTitle: UILabel!
    @IBOutlet weak var _countDownLabel: CountdownLabel!
    @IBOutlet weak var _countdownView: UIVisualEffectView!
    @IBOutlet private weak var _eventCoverImage: UIImageView!
    @IBOutlet private weak var _eventDescription: ExpandableLabel!
    @IBOutlet private weak var _eventTime: UILabel!
    @IBOutlet private weak var _eventDate: UILabel!
    private var _orgId: String = kEmptyString
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat {
        325
    }
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setExpandableLbl()
        let orgGesture = UITapGestureRecognizer(target: self, action: #selector(orgDetail))
         _orgView.addGestureRecognizer(orgGesture)
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------

    private func setExpandableLbl() {
        _eventDescription.isUserInteractionEnabled = false
        _eventDescription.delegate = self
        _eventDescription.shouldCollapse = true
        _eventDescription.numberOfLines = 2
        _eventDescription.ellipsis = NSAttributedString(string: "....")
        _eventDescription.collapsedAttributedLink = NSAttributedString(string: "more".localized(), attributes: [NSAttributedString.Key.foregroundColor: ColorBrand.brandPink])
    }
    
    public func setupData(_ data: EventModel) {
        _orgId = data.orgData?.id ?? kEmptyString
        _orgImg.loadWebImage(data.orgData?.logo ?? kEmptyString, name: data.orgData?.name ?? kEmptyString)
        _orgName.text = data.orgData?.name
        _orgWebsite.text = data.orgData?.website
        _eventTitle.text = data.title
        _eventDescription.text = data.descriptions
        _eventCoverImage.loadWebImage(data.image)
        if let venue = data.venueDetail {
            _venueInfoView.setupData(venue: venue, isAllowClick: true)
        }
        _eventTime.text = data.eventTimeSlot
        _eventDate.text = data._eventDate
        
        if !Utils.stringIsNullOrEmpty(data.eventTime) {
            let _starttime = Date(timeInterval: "\(Date())".toDate(format: kStanderdDate).timeIntervalSince(Date()), since: Date())
            let _endtime = Date(timeInterval: data.eventTime.toDate(format: kStanderdDate).timeIntervalSince(Date()), since: Date())
            _countDownLabel.animationType = .Evaporate
            _countDownLabel.timeFormat = "dd:HH:mm:ss"
            _countDownLabel.setCountDownDate(fromDate: _starttime as NSDate, targetDate: _endtime as NSDate)
            _countDownLabel.start()
            _countdownView.isHidden = data._isEventExpired ? true : false
        } else {
            _countdownView.isHidden = true
        }
    }
    
    @objc private func orgDetail() {
        let vc = INIT_CONTROLLER_XIB(EventOrganisierVC.self)
        vc.orgId = _orgId
        parentViewController?.navigationController?.pushViewController(vc, animated: true)
    }

}

extension EventSearchCollectionCell:  ExpandableLabelDelegate {

    func willExpandLabel(_ label: ExpandableLabel) {
    }

    func didExpandLabel(_ label: ExpandableLabel) {
        _eventDescription.superview?.setNeedsLayout()
        _eventDescription.superview?.layoutIfNeeded()
    }

    func willCollapseLabel(_ label: ExpandableLabel) {
    }

    func didCollapseLabel(_ label: ExpandableLabel) {
        _eventDescription.superview?.setNeedsLayout()
        _eventDescription.superview?.layoutIfNeeded()
    }
}
