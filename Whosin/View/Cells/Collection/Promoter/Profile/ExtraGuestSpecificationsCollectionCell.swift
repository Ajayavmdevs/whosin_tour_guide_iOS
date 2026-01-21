import UIKit
import RealmSwift
import ObjectMapper
protocol SpecificationsViewCellDelegate: AnyObject {
    func didTapDeleteButton(at indexPath: IndexPath)
}

class ExtraGuestSpecificationsCollectionCell: UICollectionViewCell {

    @IBOutlet var _genderBtns: [UIButton]!
    @IBOutlet weak var _nationality: CustomFormField!
    @IBOutlet weak var _dressCode: LeftSpaceTextField!
    @IBOutlet weak var _minAge: LeftSpaceTextField!
    @IBOutlet weak var _maxAge: LeftSpaceTextField!
    @IBOutlet weak var _genderView: UIView!
    @IBOutlet weak var _nationalityView: UIView!
    @IBOutlet weak var _dressCodeView: UIView!
    @IBOutlet weak var _ageView: UIView!
    @IBOutlet weak var _deleteView: UIView!
    @IBOutlet weak var deleteBtn: UIButton!
    weak var delegate: SpecificationsViewCellDelegate?
    var indexPath: IndexPath?
    private var selectGender: String = "both"
    private var _textString: String = kEmptyString
    public var callback: ((_ text: String?,_ type: ExtraGuestSpecificationsType) -> Void)?

    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat { 50 }
    
    // --------------------------------------
    // MARK: Life-Cycle
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setupData(_ type: ExtraGuestSpecificationsType = .age, model: ExtraGuestModel?) {
        handleHideView(type)
    }
    
    func handleHideView(_ type: ExtraGuestSpecificationsType = .age) {
        if type == .age {
            _ageView.isHidden = false
            _genderView.isHidden = true
            _nationalityView.isHidden = true
            _dressCodeView.isHidden = true
        } else if type == .dresscode {
            _ageView.isHidden = true
            _genderView.isHidden = true
            _nationalityView.isHidden = true
            _dressCodeView.isHidden = false
        } else if type == .gender {
            _ageView.isHidden = true
            _genderView.isHidden = false
            _nationalityView.isHidden = true
            _dressCodeView.isHidden = true
        } else if type == .nationality {
            _ageView.isHidden = true
            _genderView.isHidden = true
            _nationalityView.isHidden = false
            _dressCodeView.isHidden = true
        }
    }
    

    @IBAction func _handleDeleteEvent(_ sender: UIButton) {
        guard let indexPath = indexPath else { return }
        delegate?.didTapDeleteButton(at: indexPath)
    }
    
    func updateGenderSelection(for gender: String) {
        for button in _genderBtns {
            switch gender {
            case "both":
                button.isSelected = (button.tag == 0)
            case "male":
                button.isSelected = (button.tag == 1)
            case "female":
                button.isSelected = (button.tag == 2)
            default:
                button.isSelected = false
            }
        }
    }
    
    @IBAction func _handleSelectGenderEvent(_ sender: UIButton) {
        for button in _genderBtns {
            button.isSelected = (button.tag == sender.tag)
        }
        switch sender.tag {
        case 0:
            selectGender = "both"
        case 1:
            selectGender = "male"
        case 2:
            selectGender = "female"
        default:
            break
        }
    }
}

class ExtraGuestModel: Object, Mappable, ModelProtocol  {

    @objc var type: String = kEmptyString
    @objc var gender: String = kEmptyString
    @objc var minAge: String = kEmptyString
    @objc var maxAge: String = kEmptyString
    @objc var dresscode: String = kEmptyString
    @objc var nationality: String = kEmptyString

//    @objc var id: String = kEmptyString
    
    // --------------------------------------
    // MARK: <Mappable>
    // --------------------------------------
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        type <- map["type"]
        maxAge <- map["maxAge"]
        gender <- map["gender"]
        minAge <- map["minAge"]
        dresscode <- map["dresscode"]
        nationality <- map["nationality"]
//        id <- map["_id"]
    }
    
    // --------------------------------------
    // MARK: <ModelProtocol>
    // --------------------------------------
    
    func isValid() -> Bool {
        return true
    }
}
