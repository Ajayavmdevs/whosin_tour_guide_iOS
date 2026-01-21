import UIKit

class ProfileScoreTableCell: UITableViewCell {

    @IBOutlet weak var _cellTitle: CustomLabel!
    @IBOutlet weak var _punctualityScore: CustomLabel!
    @IBOutlet weak var _activityScore: CustomLabel!
    @IBOutlet weak var _valueScore: CustomLabel!
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat { UITableView.automaticDimension }

    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
        disableSelectEffect()
    }

    // --------------------------------------
    // MARK: Public
    // --------------------------------------

    public func setupData(_ data: ProfileScoreModel, isPublic: Bool = false) {
        if isPublic {
            _cellTitle.text = "profile_score".localized()
            _cellTitle.font = FontBrand.SFboldFont(size: 22)
        }
        _punctualityScore.text = "\(data.punctuality)"
        _activityScore.text = "\(data.activity)"
        _valueScore.text = "\(data.value)"
    }
    
}
