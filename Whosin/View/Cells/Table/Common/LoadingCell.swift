import UIKit
import SnapKit

class LoadingCell: UITableViewCell {

    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    private let indicator = MLTontiatorView()
    @IBOutlet weak var _bgView: UIView!
    class var height: CGFloat { 300 }

    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
        disableSelectEffect()
        setupUi()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func setupUi() {
        indicator.spinnerSize = .MLSpinnerSizeSmall
        indicator.spinnerColor = ColorBrand.brandPink
        _bgView.addSubview(indicator)
        indicator.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        indicator.startAnimating()
    }
    
}
