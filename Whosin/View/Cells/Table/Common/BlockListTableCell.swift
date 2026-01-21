import UIKit

protocol ReloadBlockList {
    func reload()
}

class BlockListTableCell: UITableViewCell {
    
    @IBOutlet weak var _userImage: UIImageView!
    @IBOutlet weak var _userName: UILabel!
    private var user: UserDetailModel?
    public var delegate: ReloadBlockList?
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat { UITableView.automaticDimension }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setupData(_ data: UserDetailModel) {
        user = data
        _userImage.loadWebImage(data.image, name: data.firstName)
        _userName.text = data.fullName
    }
    
    // --------------------------------------
    // MARK: Service
    // --------------------------------------
    
    private func _unBlockUser() {
        guard let id = user?.id else { return }
        WhosinServices.unblockUser(blockId: id) { [weak self] container, error in
            guard let self = self else { return}
            self.parentBaseController?.showError(error)
            guard let data = container else { return }
            Preferences.blockedUsers.removeAll(where: { $0 == id})
            self.parentBaseController?.showSuccessMessage("\(user?.fullName ?? "User")" + "has_been_unblocked".localized(), subtitle: "")
            self.delegate?.reload()
        }
    }
    
    private func showAlert() {
        guard let name = user?.fullName else { return }        
        self.parentBaseController?.showCustomAlert(title: kAppName, message:  "do_you_want_to_unblock".localized() + "\(name) ?", yesButtonTitle: "yes".localized(), noButtonTitle: "cancel".localized(), okHandler: { UIAlertAction in
            self._unBlockUser()
        }, noHandler:  { UIAlertAction in
        })
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    @IBAction func _handleUnBlockEvent(_ sender: UIButton) {
        showAlert()
    }
}
