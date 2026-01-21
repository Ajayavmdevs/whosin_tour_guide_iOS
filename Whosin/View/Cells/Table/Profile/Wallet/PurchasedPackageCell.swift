import UIKit

class PurchasedPackageCell: UICollectionViewCell {

    @IBOutlet weak var _packageWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var _packageDisc: UILabel!
    @IBOutlet weak var _packagePrice: UILabel!
    @IBOutlet weak var _packageQty: UILabel!
    @IBOutlet weak var _packageTitle: UILabel!
    @IBOutlet weak var _discount: UILabel!
    @IBOutlet weak var _bgView: GradientView!

    class var height: CGFloat {
        45
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    // --------------------------------------
    // MARK: Public
    // --------------------------------------

    public func setupData(_ model: PackageModel, item: VoucherItems, isFrom: String = kEmptyString) {
        if isFrom == "gift" {
            _packageQty.text = "\(item.remainingQty)"
            _packagePrice.isHidden = true
        } else if isFrom == "history" {
            _packageQty.text = "\(item.usedQty)"
            _packagePrice.isHidden = false
        } else {
            _packageQty.text = "\(item.remainingQty)"
            _packagePrice.isHidden = false
        }

        if APPSETTING.subscription?.userId == APPSESSION.userDetail?.id {
            _bgView.startColor = UIColor.init(hexString: "#F30092")
            _bgView.endColor = UIColor.init(hexString: "#9026E3")
        }
        _packageWidthConstraint.constant = model._discount == "0%" ? 0 : 44
        _packageDisc.text = model.descriptions
        _packageTitle.text = model.title
        if Utils.stringIsNullOrEmpty(model.discount) {
            _discount.text = model._discounts
        } else {
            _discount.text = model._discount
        }
        _packagePrice.text = "D\(item.price)"
        
    }

}
