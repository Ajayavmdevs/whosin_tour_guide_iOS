import UIKit

class SelectContactTableCell: UITableViewCell {
    
    @IBOutlet weak var _selectImage: UIImageView!
    @IBOutlet weak var _sapratorView: UIView!
    @IBOutlet private weak var _bgViewTariling: NSLayoutConstraint!
    @IBOutlet private weak var _bgViewConstraint: NSLayoutConstraint!
    @IBOutlet private weak var _bgView: UIView!
    @IBOutlet private weak var _avatarImageView: UIImageView!
    @IBOutlet private weak var _titleLabel: UILabel!
    @IBOutlet private weak var _subtitleLabel: UILabel!
    public var openChatCallBack: ((_ chatModel: ChatModel) -> Void)?

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
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        let imageName = selected ? "icon_selectedGreen" : "icon_deselcetCode"
        _selectImage.image = UIImage(named: imageName)
    }

    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    func setup(_ model:UserDetailModel, isSelected: Bool = false) {
        _avatarImageView.loadWebImage(model.image, name: model.firstName)
        _titleLabel.text = model.fullName
//        _selectImage.image = UIImage(named: isSelected ? "icon_selectedGreen" : "icon_deselcetCode")
    }
    
    public func setPrifileConstraint(lastRow: Bool = false, firstRow: Bool = false) {
        self._bgViewTariling.constant = 10
        self._bgViewConstraint.constant = 10
        self._bgView.backgroundColor = ColorBrand.cardBgColor
        DispatchQueue.main.async {
            self._bgView.roundCorners(corners: (firstRow ? (lastRow ? [.allCorners] : [.topLeft, .topRight]) : (lastRow ? [.bottomRight, .bottomLeft] : [])), radius: (firstRow && lastRow ? 15 : 15))
        }
        _sapratorView.isHidden = lastRow
    }
}


