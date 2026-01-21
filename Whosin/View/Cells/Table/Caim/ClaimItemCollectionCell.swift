import UIKit

class ClaimItemCollectionCell: UICollectionViewCell {

    @IBOutlet weak var _totalItem: UILabel!
    @IBOutlet weak var _discountedPrice: UILabel!
    @IBOutlet weak var _orignPrice: UILabel!
    @IBOutlet weak var _itemName: UILabel!
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------

    class var height: CGFloat { 50 }

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------

    public func setupBruncData(_ model: BrunchModel) {
        let actualPrice = model.qty > 1 ? (model.amount + model.discount) / model.qty : model.amount + model.discount
        _orignPrice.attributedText = "\(Utils.getCurrentCurrencySymbol())\(actualPrice)".strikethrough().withCurrencyFont(11)
        _itemName.text = model.item
        let discount = Utils.calculateDiscountValue(originalPrice: model.amount, discountPercentage: model.discount)
        if model.qty > 1 {
            _discountedPrice.attributedText = "\(Utils.getCurrentCurrencySymbol())\(model.amount / model.qty)".withCurrencyFont(11)
        } else {
            _discountedPrice.attributedText = "\(Utils.getCurrentCurrencySymbol())\(model.amount)".withCurrencyFont(11)
        }
        _totalItem.text = "\(model.qty)"
        _orignPrice.isHidden = model.amount == 0 || model.amount == Int(discount)
    }

}
