import UIKit

class ReportedUsersTableCell: UITableViewCell {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var reason: UILabel!
    @IBOutlet weak var dateTime: UILabel!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var statusView: UIView!
    private var reportedId: String = kEmptyString
    public var callback: ((_ id: String) -> Void)?
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    static var height: CGFloat { UITableView.automaticDimension }

    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
        disableSelectEffect()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setupData(_ data: ReportedUserListModel) {
        self.reportedId = data.id
        let image = data.type == "review" ? data.review?.image ?? "" : data.chat?.authorImage ?? ""
        userImage.loadWebImage(image)
        userName.text = data.title
        reason.text = data.reason
        dateTime.text = Utils.dateToString(data.createdAt, format: kFormatDateReview)
        status.text = data.status
        if data.status == "pending" {
            statusView.backgroundColor = ColorBrand.amberColor
        } else if data.status == "reviewed" {
            statusView.backgroundColor = UIColor.red
        } else if data.status == "dismissed" {
            statusView.backgroundColor = ColorBrand.brandGreen
        } else if data.status == "actioned" {
            statusView.backgroundColor = ColorBrand.brandPink
        }
        statusView.isHidden = Utils.stringIsNullOrEmpty(data.status)
    }
    
    // --------------------------------------
    // MARK: Actions
    // --------------------------------------
    
    @IBAction func _handleMenuEvent(_ sender: UIButton) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: "delete".localized(), style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            self.callback?(self.reportedId)
        }
        alertController.addAction(deleteAction)
        
        let cancelAction = UIAlertAction(title: "cancel".localized(), style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        parentViewController?.present(alertController, animated: true, completion: nil)
    }
}
