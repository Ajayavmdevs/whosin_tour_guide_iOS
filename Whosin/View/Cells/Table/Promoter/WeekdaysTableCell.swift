import UIKit

class WeekdaysTableCell: UITableViewCell {

    @IBOutlet weak var _name: UILabel!
    @IBOutlet weak var _iconCheck: UIImageView!
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------

    class var height: CGFloat { 50 }
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    public func setupData(_ data: String, isSelected: Bool) {
        _name.text = data
//        _iconCheck.isHidden = !isSelected
        _iconCheck.image = UIImage(named: isSelected ? "icon_selectedGreen" : "icon_deselcetCode")
    }
    
}
