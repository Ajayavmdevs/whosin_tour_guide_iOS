import UIKit
import SnapKit

class LoadingCollectionCell: UICollectionViewCell {
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    private let indicator = MLTontiatorView()
    class var height: CGFloat { 200 }

    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUi()
    }
    
    func setupUi() {
        indicator.spinnerSize = .MLSpinnerSizeSmall
        indicator.spinnerColor = ColorBrand.brandPink
        self.addSubview(indicator)
        indicator.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        indicator.startAnimating()
    }

}
