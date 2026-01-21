import UIKit

class SideMenuTableCell: UITableViewCell {
    
    @IBOutlet private weak var _iconImageView: UIImageView!
    @IBOutlet private weak var _titleLabel: UILabel!
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    static var height: CGFloat { 50 }
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    func setup(title: String, iconName: String) {
        _titleLabel.text = title
        _iconImageView.image = UIImage(named: iconName)
    }
    
    func setupVenue(data: VenueDetailModel) {
        _titleLabel.text = data.name
        _iconImageView.loadWebImage(data.cover, name: data.name)
    }
}
