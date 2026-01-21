import UIKit

class YachtInfoCollectionCell: UICollectionViewCell {
    
    @IBOutlet public weak var _imageiView: UIImageView!
    @IBOutlet private weak var _mainContainerView: GradientView!
    @IBOutlet private weak var _titleLabel: UILabel!
    @IBOutlet private weak var _specificationLabel: UILabel!
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat {
        154
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
    
    public func setUpdata(_ model: YachtDetailModel) {
        _titleLabel.text = model.name
        _imageiView.loadWebImage(model.images.first ?? kEmptyString)
        
        var specifications: [NSAttributedString] = []
        specifications.removeAll()
        model.specifications.forEach { spec in
            specifications.append(spec.attributedString)
        }
        
        // Create a mutable attributed string
        let combinedAttributedString = NSMutableAttributedString()
        
        // Append each attributed string with a line break
        specifications.forEach { attributedString in
            if !combinedAttributedString.string.isEmpty {
                combinedAttributedString.append(NSAttributedString(string: "\n"))
            }
            combinedAttributedString.append(attributedString)
        }
        
        // Set the combined attributed string to the label
        _specificationLabel.attributedText = combinedAttributedString
    }
}
