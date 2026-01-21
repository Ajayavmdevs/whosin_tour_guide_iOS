import UIKit

class OutingHeaderDetailCell: UITableViewCell {

    @IBOutlet private weak var _venueInfoView: CustomVenueInfoView!
    @IBOutlet weak var _badgeView: UIView!
    @IBOutlet weak var _status: UILabel!
    @IBOutlet weak var _visualEffect: UIVisualEffectView!
    private var _logoHeroId: String = kEmptyString
    private var _heroId: String = kEmptyString
    @IBOutlet weak var _coverImage: UIImageView!
    private var _venueId: String = kEmptyString
    private var _outingModel: OutingListModel?


    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    static var height: CGFloat { UITableView.automaticDimension }

    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
        disableSelectEffect()
        setupUi()
    }
    
    private func setupUi() {
        DISPATCH_ASYNC_MAIN_AFTER(0.01) {
            self._badgeView.roundCorners(corners: [.bottomLeft, .topRight], radius: 10)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setupData(_ model: OutingListModel) {
        _outingModel = model
        if let venue = model.venue {
            _coverImage.loadWebImage(model.venue?.cover ?? kEmptyString)
            _venueInfoView.setupData(venue: venue, isAllowClick: true)
        }
        if model.userId == APPSESSION.userDetail?.id {
            _visualEffect.isHidden = true
        } else {
            _visualEffect.isHidden = false
        }
        _status.text = model.status
        if model.status == "cancelled" {
            _badgeView.backgroundColor = ColorBrand.brandBorderRed
        } else if model.status == "upcoming" {
            _badgeView.backgroundColor = ColorBrand.yellowColor
        } else {
            _badgeView.backgroundColor = ColorBrand.brandGreen
        }
        _venueId = model.venueId
        
        let endDate = "\(_outingModel?.date ?? kEmptyString) \(_outingModel?.endTime ?? kEmptyString)"

    }

}
