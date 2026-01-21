import UIKit
import StripeCore
import ExpandableLabel

class OutingOfferTableCell: UITableViewCell {

    @IBOutlet weak var _bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var _topConstraint: NSLayoutConstraint!
    @IBOutlet weak var packageHight: NSLayoutConstraint!
    @IBOutlet private weak var _customPackageView: CustomPackageView!
    @IBOutlet private weak var _customTitleView: CustomOfferTitleView!
    @IBOutlet private weak var _customOfferView: CustomOfferInfoView!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet private weak var _badgeView: UIView!
    @IBOutlet private weak var _status: UILabel!
    @IBOutlet weak var _customVenueInfo: CustomVenueInfoView!

    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat {
        UITableView.automaticDimension
    }
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func prepareForReuse() {
        super.prepareForReuse()
        layoutIfNeeded()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        _setupUi()
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------

    private func _setupUi() {
        disableSelectEffect()
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
    
    public func setupData(_ data: OffersModel, outingModel: OutingListModel?) {
        _customOfferView.setupData(model: data, venue: data.venue)
        if let venue = data.venue {
            _customVenueInfo.setupData(venue: venue, isAllowClick: true)
        }
        if !data.packages.isEmpty {
            _customPackageView.isHidden = false
            _customPackageView.setupData(model: data.packages.toArrayDetached(ofType: PackageModel.self))
        } else {
            _customPackageView.isHidden = true
        }
        packageHight.constant = CGFloat(data.packages.count * 45)
        _customTitleView.setupData(model: data)
        if  let model = outingModel {
            _status.text = model.status
            if model.status == "cancelled" {
                _badgeView.backgroundColor = ColorBrand.brandBorderRed
            } else if model.status == "upcoming" {
                _badgeView.backgroundColor = ColorBrand.yellowColor
            } else {
                _badgeView.backgroundColor = ColorBrand.brandGreen
            }
        } else {
            statusView.isHidden = true
        }
    }
    
    public func setupEventData(_ data: OffersModel) {
        _topConstraint.constant = 10
        _bottomConstraint.constant = 10
        _customOfferView.setupData(model: data, venue: data.venue)
        _customVenueInfo.isHidden = true
        _customPackageView.isHidden = true
        _customTitleView.setupData(model: data)
        statusView.isHidden = true
    }
    
    @objc func alertControllerBackgroundTapped() {
        self.parentViewController?.dismiss(animated: true, completion: nil)
    }
    
    
}
