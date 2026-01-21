import UIKit
import DropDown

class SelectPaidPassTypeTableCell: UITableViewCell {

    @IBOutlet weak var _eventPassStack: UIStackView!
    @IBOutlet weak var _randomButton: CustomButton!
    @IBOutlet weak var _specificButton: CustomButton!
    @IBOutlet weak var _eventPassName: CustomLabel!
    public var updateCallBack: ((_ params: [String: Any]) -> Void)?
    private var passList: [PaidPassModel] = []
    let dropDown = DropDown()
    private var type: String = kEmptyString
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat {
        UITableView.automaticDimension
    }
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setupData(_ data: [String: Any], pass: [PaidPassModel] = []) {
        passList = pass
        if let type = data["paidPassType"] as? String {
            self.type = type
            self.updateTypeSelection(for: type)
            if type == "override" {
                _eventPassStack.isHidden = false
                if let id = data["paidPassId"] as? String {
                    if let matchedPass = pass.first(where: { $0.id == id }) {
                        _eventPassName.text = matchedPass.title
                    } else {
                        _eventPassName.text = "select_event_pass".localized()
                    }
                }
            } else {
                _eventPassStack.isHidden = true
            }
            
        }
    }
    
    func updateTypeSelection(for type: String) {
        self.type = type
        switch type {
        case "default":
            _randomButton.isSelected = true
            _specificButton.isSelected = false
        case "override":
            _randomButton.isSelected = false
            _specificButton.isSelected = true
        default:
            _randomButton.isSelected = true
            _specificButton.isSelected = false
        }
    }


    // --------------------------------------
    // MARK: Event
    // --------------------------------------

    @IBAction func _handleRandomEvent(_ sender: UIButton) {
        updateTypeSelection(for: "default")
        updateCallBack?(["paidPassType" : "default"])
    }
    
    @IBAction func _handleSpecificButton(_ sender: UIButton) {
        updateTypeSelection(for: "override")
        updateCallBack?(["paidPassType" : "override"])
    }
    
    @IBAction func _handleSelectEventPassEvent(_ sender: UIButton) {
        dropDown.dataSource = passList.map({ $0.title })
        dropDown.anchorView = sender
        dropDown.bottomOffset = CGPoint(x: 0, y: sender.frame.size.height)
        dropDown.direction = .bottom
        dropDown.backgroundColor = ColorBrand.cardBgColor
        dropDown.textColor = ColorBrand.white
        dropDown.show()
        dropDown.selectionAction = { [weak self] (index: Int, item: String) in
            guard let self = self else { return }
            self._eventPassName.text = item
            if let id = passList.first(where: { $0.title == item })?.id {
                updateCallBack?(["paidPassType":self.type, "paidPassId": id])
            }
        }
    }
}
