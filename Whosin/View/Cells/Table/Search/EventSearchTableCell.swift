import UIKit
import CountdownLabel
import ExpandableLabel

class EventSearchTableCell: UITableViewCell {
    
    @IBOutlet weak var _venueInfoView: CustomVenueInfoView!
    @IBOutlet weak var _orgImg: UIImageView!
    @IBOutlet weak var _orgName: UILabel!
    @IBOutlet weak var _orgAddress: UILabel!
    @IBOutlet weak var _countDownLabel: CountdownLabel!
    @IBOutlet weak var countdownView: UIVisualEffectView!
    @IBOutlet private weak var _eventTitle: UILabel!
    @IBOutlet private weak var _eventCoverImage: UIImageView!
    @IBOutlet private weak var _eventDescription: ExpandableLabel!
    @IBOutlet weak var _orgView: UIView!
    @IBOutlet private weak var _eventTime: UILabel!
    @IBOutlet private weak var _eventDate: UILabel!
    @IBOutlet weak var _createdDateView: UIStackView!
    @IBOutlet weak var _createdDate: UILabel!
    private var _eventModel: EventModel?
    
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
        let orgGesture = UITapGestureRecognizer(target: self, action: #selector(orgDetail))
         _orgView.addGestureRecognizer(orgGesture)
        setExpandableLbl()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
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
        _eventModel = data
        _eventTitle.text = data.title
        _eventDescription.text = data.descriptions
        _orgImg.loadWebImage(data.orgData?.logo ?? kEmptyString, name: data.orgData?.name ?? kEmptyString)
        _orgName.text = data.orgData?.name
        _orgAddress.text = data.orgData?.website
        _eventCoverImage.loadWebImage(data.image)
        _eventTime.text = data.eventTimeSlot
        _eventDate.text = data._eventDate
        if data.venueDetail == nil {
            guard let venue = APPSETTING.venueModel?.filter({ $0.id == data.venue }).first else { return }
            _venueInfoView.setupData(venue: venue, isAllowClick: true)
        } else if let venue = data.venueDetail {
            _venueInfoView.setupData(venue: venue, isAllowClick: true)
        }
    }
    
    @objc private func orgDetail() {
    }

}

extension EventSearchTableCell:  ExpandableLabelDelegate {
    
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
