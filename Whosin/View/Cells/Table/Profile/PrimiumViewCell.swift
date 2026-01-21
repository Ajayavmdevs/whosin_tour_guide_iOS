import UIKit

class PrimiumViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    static var height: CGFloat { UITableView.automaticDimension }

    func setup(_ title:String) {
    }

}
