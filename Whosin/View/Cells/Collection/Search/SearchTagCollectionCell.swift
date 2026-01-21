import UIKit

class SearchTagCollectionCell: UICollectionViewCell {
    
    @IBOutlet private weak var _bgView: UIView!
    @IBOutlet private weak var _title: UILabel!


    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    override func prepareForReuse() {
        super.prepareForReuse()
        self.layoutIfNeeded()
        self.layoutMarginsDidChange()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    // --------------------------------------
    // MARK: Class
    // --------------------------------------

    class var height: CGFloat {
        40
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------

    public func setupData(_ data: String) {
        _title.text = data
        _title.textColor = .white
        _bgView.backgroundColor = ColorBrand.white.withAlphaComponent(0.13)
        self.layoutIfNeeded()
        self.layoutMarginsDidChange()

    }
    
    public func select() {
        _bgView.backgroundColor = ColorBrand.brandPink
    }

    public func deselect() {
        _bgView.backgroundColor = ColorBrand.white.withAlphaComponent(0.13)
    }
}
