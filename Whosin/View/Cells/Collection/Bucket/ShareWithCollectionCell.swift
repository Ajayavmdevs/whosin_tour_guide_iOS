import UIKit

class ShareWithCollectionCell: UICollectionViewCell {

    @IBOutlet private weak var _nameLabel: UILabel!
    @IBOutlet private weak var _contactImage: UIImageView!
    @IBOutlet public weak var _contactButton: UIButton!
    private var contacts: UserDetailModel?
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------

    class var height: CGFloat {
        86
    }
    
    // --------------------------------------
    // MARK: Life cycle
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------

    public func setupContactData(data: UserDetailModel? = nil, islastIndex: Bool = false) {
        contacts = data
        if islastIndex {
            _contactImage.image = UIImage(named: "icon_coverRound")
            _nameLabel.text = "add".localized()
            _contactButton.isHidden = true
        } else {
            if let contactData = data {
                _nameLabel.text = contactData.fullName
                
                _contactImage.loadWebImage(contactData.image, name: contactData.firstName)
                _contactButton.isHidden = false
            }
        }
    }

    // --------------------------------------
    // MARK: Event
    // --------------------------------------

    @IBAction func _handleContactEvent(_ sender: UIButton) {
        guard let model = contacts else { return }
        guard let userDetail = APPSESSION.userDetail else { return }
    }
    
}
