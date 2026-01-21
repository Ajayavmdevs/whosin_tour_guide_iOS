import UIKit

class InvitedUserRequestTableCell: UITableViewCell {
    
    @IBOutlet weak var _customEventRequestView: CustomPlusOneRequestView!
    public var openCallback:((_ model: ChatModel) -> Void)?
    public var updateStatusCallback:(( _ status: String) -> Void)?
    public var openProfile: ((_ id: String, _ isRingMember: Bool)-> Void)?

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
    
    // --------------------------------------
    // MARK: public
    // --------------------------------------
    
    public func setUpData(_ model: InvitedUserModel, isEventFull: Bool = false, isConfirmation: Bool = false, isNoAction: Bool = false, type: String = kEmptyString) {
        _customEventRequestView.setupEventData(model, isEventFull: isEventFull, isConfirmation: isConfirmation, isNoAction: isNoAction, type: type)
        _customEventRequestView.openCallback = { [weak self] chat in
            guard let self = self else { return }
            self.openCallback?(chat)
        }
        _customEventRequestView.updateStatusCallback = { [weak self] status in
            guard let self = self else { return }
            self.updateStatusCallback?(status)
            
        }
        _customEventRequestView.openProfile = { [weak self] id, isRingMember in
            guard let self = self else { return }
            self.openProfile?(id, isRingMember)
            
        }
    }

}
