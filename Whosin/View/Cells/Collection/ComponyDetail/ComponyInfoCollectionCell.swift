import UIKit

class ComponyInfoCollectionCell: UICollectionViewCell {

    @IBOutlet public weak var _imageiView: UIImageView!
    @IBOutlet private weak var _mainContainerView: ConicalGradientView!
    @IBOutlet private weak var _titleLabel: UILabel!
    @IBOutlet private weak var _subTiteLabel: UILabel!
    @IBOutlet private weak var _yearLabel: UILabel!
    @IBOutlet private weak var _peopleLabel: UILabel!
    @IBOutlet private weak var _cabinsLabel: UILabel!
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat {
        174
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
        DISPATCH_ASYNC_MAIN_AFTER(0.2) {
            self._mainContainerView.roundCorners(corners: [.bottomLeft, .bottomRight, .topLeft, .topRight], radius: 10)
        }
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------

    public func setUpdata(_ model: DealsModel) {
        _titleLabel.text = model.title
        _subTiteLabel.text = model.descriptions
        _yearLabel.text = "2010"
        _peopleLabel.text = "10"
        _cabinsLabel.text = "5"
        _imageiView.loadWebImage(model.venueModel?.cover ?? "")
        _mainContainerView.color1 = UIColor.init(hexString: "#2CC7BE")
        _mainContainerView.color2 = UIColor.init(hexString: "#39AACE")
        _mainContainerView.color3 = UIColor.init(hexString: "#388FCE")
        _mainContainerView.color4 = UIColor.init(hexString: "#0FE7F4")
        _mainContainerView.color5 = UIColor.init(hexString: "#2389C2")

    }
}
