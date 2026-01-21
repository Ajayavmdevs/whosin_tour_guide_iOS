import UIKit

class UserCircleListTableCell: UITableViewCell {

    @IBOutlet weak var _circleImage: UIImageView!
    @IBOutlet weak var _circleName: CustomLabel!
    @IBOutlet weak var _circleDesc: CustomLabel!
    private var _circleDetail: UserDetailModel?
    private var _userId: String = kEmptyString
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat { UITableView.automaticDimension }
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // --------------------------------------
    // MARK: Services
    // --------------------------------------

    private func _requestRemoveFromCircle(_ id: String, memberIds: [String], name: String) {
        parentBaseController?.showHUD()
        WhosinServices.removeFromCircle(id: id, memberIds: memberIds) { [weak self] container, error in
            guard let self = self else { return }
            self.parentBaseController?.hideHUD()
            guard let data = container?.data else { return }
            self.parentBaseController?.showSuccessMessage(LANGMANAGER.localizedString(forKey: "removed_from_circle", arguments: ["value": name]), subtitle: kEmptyString)
            NotificationCenter.default.post(name: .reloadPromoterProfileNotifier, object: nil)
            self.parentBaseController?.dismiss(animated: true)
        }
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------

    public func setupData(_ data: UserDetailModel, userId: String = kEmptyString) {
        _circleImage.loadWebImage(data.avatar)
        _circleName.text = data.title
        _circleDesc.text = data.descriptions
        _circleDetail = data
        _userId = userId
    }
    
    // --------------------------------------
    // MARK: Events
    // --------------------------------------
    
    @IBAction func _handleMenuOptionsEvent(_ sender: UIButton) {
        _userBottomSheet()
    }
    
    private func _userBottomSheet() {
        guard let circle = _circleDetail else { return }

        let alert = UIAlertController(title: circle.fullName, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "remove_from_circle".localized(), style: .default, handler: { action in
            self.parentBaseController?.confirmAlert(message: "remove_circle_alert".localized(), okHandler: { action in
                    self._requestRemoveFromCircle(circle.id, memberIds: [self._userId], name: circle.members.first(where: { $0.id == self._userId})?.fullName ?? kEmptyString)
                })
            }))

        alert.addAction(UIAlertAction(title: "cancel".localized(), style: .destructive, handler: { _ in }))
        parentViewController?.present(alert, animated: true)
    }
}
