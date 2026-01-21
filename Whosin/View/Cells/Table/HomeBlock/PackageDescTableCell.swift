import UIKit

class PackageDescTableCell: UITableViewCell {

    @IBOutlet weak var _bgView: GradientView!
    @IBOutlet private weak var _descLabel: UILabel!
    @IBOutlet private weak var _title: UILabel!
    @IBOutlet private weak var _discountPriceLabel: UILabel!
    @IBOutlet private weak var _discountLabel: UILabel!
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
        disableSelectEffect()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------

    public func setupData(_ model: PackageModel) {
        if APPSETTING.subscription?.userId == APPSESSION.userDetail?.id {
            _bgView.startColor = UIColor.init(hexString: "#F30092")
            _bgView.endColor = UIColor.init(hexString: "#9026E3")
        }
        _descLabel.text = model.descriptions
        _title.text = model.title
        _discountLabel.text = model._discount
        _discountPriceLabel.text = "D" + "\(model.actualPrice)"
    }
}
