import UIKit

class VenueExclusiveDealsCollectionCell: UICollectionViewCell {

    @IBOutlet public weak var _imageiView: UIImageView!
    @IBOutlet private weak var _mainContainerView: ConicalGradientView!
//    @IBOutlet private weak var _badgeView: CustomBadgeView!
    @IBOutlet private weak var _titleLabel: UILabel!
    @IBOutlet private weak var _subTitleLabel: UILabel!
    @IBOutlet private weak var _buyNowButton: UIButton!
    private var _dealsId: String = kEmptyString
    private var _dealsModel: DealsModel?
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat {
        156
    }
    
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
        
        DISPATCH_ASYNC_MAIN_AFTER(0.5) {
            self._mainContainerView.roundCorners(corners: [.bottomLeft, .bottomRight, .topLeft, .topRight], radius: 10)
//            self._badgeView.roundCorners(corners: [.bottomLeft, .topRight], radius: 10)
        }
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------

    public func setUpdata(_ model: DealsModel) {
        _dealsModel = model
        _dealsId = model.id
        _titleLabel.text = model.title
        _subTitleLabel.text = model.descriptions
        _buyNowButton.setTitle("from".localized() + "\(Utils.getCurrentCurrencySymbol())\(model.discountedPrice)", for: .normal)
//        _badgeView.setupData(originalPrice: model.actualPrice, discountedPrice: "\(model.discountedPrice)", isNoDiscount: model._isNoDiscount)
        _imageiView.loadWebImage(model.image)
        _mainContainerView.color1 = UIColor.init(hexString: "#C72C5F")
        _mainContainerView.color2 = UIColor.init(hexString: "#CE5C38")
        _mainContainerView.color3 = UIColor.init(hexString: "#F47D0F")
        _mainContainerView.color4 = UIColor.init(hexString: "#C22366")
        _buyNowButton.isHidden = model.isZeroPrice
    }
    
    @IBAction private func _handleBuyNowButton(_ sender: UIButton) {
        parentBaseController?.feedbackGenerator?.impactOccurred()
        let controller = INIT_CONTROLLER_XIB(BuyPackgeVC.self)
        controller.dealsId = _dealsId
        controller.dealsModel = _dealsModel
        controller.setCallback {
            let controller = INIT_CONTROLLER_XIB(MyCartVC.self)
            controller.modalPresentationStyle = .overFullScreen
            self.parentViewController?.navigationController?.pushViewController(controller, animated: true)
        }
        parentViewController?.navigationController?.pushViewController(controller, animated: true)
    }
}
