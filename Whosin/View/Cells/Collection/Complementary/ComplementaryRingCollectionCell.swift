import UIKit

class ComplementaryRingCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var _userImage: UIImageView!
    @IBOutlet weak var _ringUserName: CustomLabel!
    @IBOutlet weak var _ringUserDesc: CustomLabel!
    @IBOutlet weak var _promoterText: CustomLabel!
    @IBOutlet weak var _myCircleList: CustomUserListView!
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat { 160.0 }
    
    // --------------------------------------
    // MARK: Life-Cycle
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    public func setupData(_ data: UserDetailModel) {
        _userImage.loadWebImage(data.image)
        _ringUserName.text = data.fullName
        _ringUserDesc.text = data.bio
        _myCircleList.setupData(data.circles.toArrayDetached(ofType: UserDetailModel.self), title: "my_circles".localized(), titleFont: FontBrand.SFboldFont(size: 14.0))
    }

}
