import UIKit

class SharedUserNoMarginCell: UICollectionViewCell {

    @IBOutlet private weak var _nameText: UILabel!
    @IBOutlet private weak var _contactImage: UIImageView!
    @IBOutlet public weak var _contactButton: UIButton!
    private var contacts: UserDetailModel?
    private var islastIndex: Bool = false
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------

    class var height: CGFloat {
        80
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
//        _contactImage.sd_cancelCurrentImageLoad()
//        if islastIndex {
//            _contactImage.borderColor = .clear
//            _contactImage.borderWidth = 0
//            _contactImage.image = UIImage(named: "icon_coverRound")
//            _contactButton.isHidden = true
//        } else {
//            if let contactData = contacts {
//                _contactImage.borderColor = ColorBrand.brandImageBorder
//                _contactImage.borderWidth = 1.5
//                _contactImage.loadWebImage(contactData.image, name: contactData.firstName)
//                _nameText.text = contactData.fullName
//                _contactButton.isHidden = false
//            } else {
//                _contactImage.borderColor = .clear
//                _contactImage.borderWidth = 0
//                _contactImage.image = UIImage(named: "icon_coverRound")
//                _nameText.text = "Add"
//                _contactButton.isHidden = true
//            }
//        }
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
        self.islastIndex = islastIndex
        _contactImage.sd_cancelCurrentImageLoad()
        if let contactData = data {
            _contactImage.borderColor = ColorBrand.brandImageBorder
            _contactImage.borderWidth = 1.5
            _contactImage.loadWebImage(contactData.image, name: contactData.firstName)
            _nameText.text = contactData.fullName
            _contactButton.isHidden = false
        } else {
            _contactImage.borderColor = .clear
            _contactImage.borderWidth = 0
            _contactImage.image = UIImage(named: "icon_coverRound")
            _nameText.text = "add".localized()
            _contactButton.isHidden = true
        }
    }
    
    public func setUpRings(_ model: UserDetailModel) {
        _contactImage.loadWebImage(model.image, name: model.firstName)
        _contactImage.borderWidth = 0
        _nameText.text = model.firstName
        _contactButton.isHidden = true
    }

    // --------------------------------------
    // MARK: Event
    // --------------------------------------

    @IBAction func _handleContactEvent(_ sender: UIButton) {
        guard let model = contacts else { return }
        guard let userDetail = APPSESSION.userDetail else { return }
    }
    
}
