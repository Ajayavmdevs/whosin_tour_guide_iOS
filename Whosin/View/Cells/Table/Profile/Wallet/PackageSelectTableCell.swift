import UIKit

class PackageSelectTableCell: UITableViewCell {
        
    @IBOutlet weak var _widthConstraint: NSLayoutConstraint!
    @IBOutlet weak var _discountLabel: UILabel!
    @IBOutlet weak var _packageValue: UILabel!
    @IBOutlet weak var _packageQty: UILabel!
    @IBOutlet weak var _title: UILabel!
    @IBOutlet weak var _bgView: GradientView!
    @IBOutlet weak var _discription: UILabel!
    
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
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------

    public func setupData(_ model: PackageModel, item: VoucherItems) {
        if APPSETTING.subscription?.userId == APPSESSION.userDetail?.id {
            _bgView.startColor = UIColor.init(hexString: "#F30092")
            _bgView.endColor = UIColor.init(hexString: "#9026E3")
        }
        _discription.text = model.descriptions
        _title.text = model.title
        _packageQty.text = "\(item.remainingQty)"
        if Utils.stringIsNullOrEmpty(model.discount) {
            _discountLabel.text = model._discounts
            _widthConstraint.constant = model._discounts == "0%" ? 0 : 44
        } else {
            _discountLabel.text = model._discount
            _widthConstraint.constant = model._discount == "0%" ? 0 : 44
        }
        _packageValue.text = "D" + "\(item.price)"
    }
}
