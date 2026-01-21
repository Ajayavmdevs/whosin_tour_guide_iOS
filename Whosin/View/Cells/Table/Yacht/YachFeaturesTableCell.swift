import UIKit

class YachFeaturesTableCell: UITableViewCell {

    @IBOutlet weak var _featuresView: CustomFeaturesView!
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    static var height: CGFloat { UITableView.automaticDimension }

    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    // --------------------------------------
    // MARK: Public
    // --------------------------------------

    public func setup(_ features: [CommonSettingsModel], isOffer: Bool = false) {
        _featuresView.setupData(model: features, isOffer: isOffer)
    }
}
