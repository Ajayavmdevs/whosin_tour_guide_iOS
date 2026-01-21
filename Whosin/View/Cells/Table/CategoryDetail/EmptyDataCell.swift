import UIKit

class EmptyDataCell: UITableViewCell {

    @IBOutlet weak var _image: UIImageView!
    @IBOutlet weak var _subtitleText: UILabel!
    
    class var height: CGFloat {
        UITableView.automaticDimension
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        disableSelectEffect()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    public func setupData(_ model: [String : Any]) {
        _image.image = UIImage(named: model["icon"] as! String)
        _subtitleText.text = model["title"] as? String
    }

}
