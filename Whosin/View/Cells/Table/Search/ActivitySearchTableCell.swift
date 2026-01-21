import UIKit

class ActivitySearchTableCell: UITableViewCell {
    
    @IBOutlet weak var _venueInfoView: CustomVenueInfoView!
    @IBOutlet private weak var _activityName: UILabel!
    @IBOutlet private weak var _activityCoverImage: UIImageView!
    @IBOutlet private weak var _ratingView: UIView!
    @IBOutlet private weak var _startDate: UILabel!
    @IBOutlet private weak var _endDate: UILabel!
    @IBOutlet private weak var _priceView: CustomBadgeView!
    @IBOutlet weak var _createdDateView: UIStackView!
    @IBOutlet weak var _createdDate: UILabel!
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat { UITableView.automaticDimension }
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func awakeFromNib() {
        super.awakeFromNib()
        _priceView.roundCorners(corners: [.bottomLeft], radius: 10.0)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setupData(_ data: ActivitiesModel) {
        _activityName.text = data.name
        if let provider = data.provider {
            _venueInfoView.setupProviderData(venue: provider)
        }
        _priceView.setupData(originalPrice: data.price, discountedPrice: data._disocuntedPrice, isNoDiscount: data._isNoDiscount)
        _activityCoverImage.loadWebImage(data.cover)
        _ratingView.isHidden = data.avgRating.isZero
        _startDate.text = data._startDate
        _endDate.text = data._endDate
    }
    
}
