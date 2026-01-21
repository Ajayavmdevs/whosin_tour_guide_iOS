import UIKit

class LargeOffersCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var _venueInfoView: CustomVenueInfoView!
    @IBOutlet private weak var _coverImage: UIImageView!
    @IBOutlet public weak var _mainContainerView: UIView!
    @IBOutlet private weak var _OfferTitle: UILabel!
    @IBOutlet private weak var _offerDesc: UILabel!
    private var _offerModel: OffersModel!
    private var _venueId: String = kEmptyString
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat { 393 }
    
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
        DISPATCH_ASYNC_MAIN_AFTER(0.02) {
            self._mainContainerView.cornerRadius = 10
        }
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setUpdata(_ data: OffersModel) {
        _offerModel = data
        _OfferTitle.text = data.title
        _offerDesc.text = data.descriptions
        _venueInfoView.setupData(venue: data.venue ?? VenueDetailModel(), isAllowClick: true)
        _coverImage.loadWebImage(data.image)
        _venueId = data.venue?.id ?? kEmptyString
    }
    
    @IBAction func _handleInviteEvent(_ sender: UIButton) {
    }
    
}
