import UIKit

class ActivityListCollectionCell: UICollectionViewCell {

    @IBOutlet private weak var _iconImage: UIImageView!
    @IBOutlet private weak var _activityName: UILabel!
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat {
        28
    }
    
    // --------------------------------------
    // MARK: Life cycle
    // --------------------------------------
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setupData(_ model: AvilableFeaturesModel) {
        _activityName.text = model.feature
        _iconImage.loadWebImage(model.icon, placeholder: UIImage(named: ""))
    }
    
    public func setupDealsData(_ model: CommonSettingsModel) {
        _activityName.text = model.title
        _iconImage.loadWebImage(model.icon, placeholder: UIImage(named: ""))
    }

}
