import UIKit

class ActivitySearchCollectionCell: UICollectionViewCell {

    @IBOutlet weak var _providerInfoView: CustomVenueInfoView!
    @IBOutlet private weak var _activityName: UILabel!
    @IBOutlet private weak var _activityCoverImage: UIImageView!
    @IBOutlet private weak var _ratingView: UIView!
    @IBOutlet private weak var _startDate: UILabel!
    @IBOutlet private weak var _endDate: UILabel!
    @IBOutlet private weak var _priceView: CustomBadgeView!
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat {
        480
    }
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func awakeFromNib() {
        super.awakeFromNib()
        _priceView.roundCorners(corners: [.bottomLeft], radius: 10.0)
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------

    public func setupData(_ data: ActivitiesModel) {
        _activityName.text = data.name
        _priceView.setupData(originalPrice: data.price, discountedPrice: data._disocuntedPrice, isNoDiscount: data._isNoDiscount)
        _activityCoverImage.loadWebImage(data.cover)
        _ratingView.isHidden = data.avgRating.isZero
        _providerInfoView.setupProviderData(venue: data.provider ?? ProviderModel())
        _startDate.text = data._startDate
        _endDate.text = data._endDate
    }

}
