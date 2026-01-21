import UIKit

class SearchHeaderCollectionCell: UICollectionViewCell {

    @IBOutlet weak var _headerText: UILabel!
    @IBOutlet weak var _selectedView: UIView!
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------

    class var height: CGFloat {
        30
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    public func setupData(data: String) {
        _headerText.text = data.capitalized
    }

}
