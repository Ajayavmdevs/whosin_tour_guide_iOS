import UIKit

class CustomVenueCalloutView: UIView {

    @IBOutlet private weak var _tableView: UITableView!
    @IBOutlet private weak var _checkInView: GradientView!
    @IBOutlet private weak var _checkInLabel: UILabel!
    @IBOutlet private weak var _checkInViewHeight: NSLayoutConstraint!
    @IBOutlet private weak var _tableBottomMargin: NSLayoutConstraint!
    private let kCellIdentifier = String(describing: UserTableCell.self)
    private var _userList: [UserDetailModel] = []
    private var _venueId: String = kEmptyString
    

    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    public class func initFromNib() -> CustomVenueCalloutView {
        UINib(nibName: "CustomVenueCalloutView", bundle: nil).instantiate(withOwner: nil, options: nil).first as! CustomVenueCalloutView
    }
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
        _setupUi()
    }
    
    private func _setupUi() {
        //TABLE VIEW
        _tableView.register(UINib(nibName: kCellIdentifier, bundle: nil), forCellReuseIdentifier: kCellIdentifier)
        _tableView.delegate = self
        _tableView.dataSource = self
    }
    
    public func setupData(_ model: [UserDetailModel], venueId: String) {
        _userList = model
        _venueId = venueId
        _tableView.reloadData()
        guard let userDetail = APPSESSION.userDetail else {
            _checkInLabel.text = "Check-In"
            return }
        if(model.contains(where: {$0.id == userDetail.id})) {
            _checkInLabel.text = "Check-Out"
        } else {
            _checkInLabel.text = "Check-In"
        }
    }
    
    public func hideCheckinButton() {
        _checkInView.isHidden = true
        _checkInViewHeight.constant = 0
        _tableBottomMargin.constant = 0
    }
    
    // --------------------------------------
    // MARK: Height & Width of View
    // --------------------------------------
    
    var userHeight: CGFloat {
        45
    }
    
    var viewHeight: CGFloat {
        let totalRowHeight = CGFloat(_userList.count) * UserTableCell.height
        let tableViewHeight = totalRowHeight + 10
        
        let checkInViewHeight: CGFloat = 30
        let totalHeight = tableViewHeight + checkInViewHeight
        
        return totalHeight
        
    }
    
    var viewWidth: CGFloat {
        return 250
    }
    
    private func _requestCheckIn() {
        guard let userDetail = APPSESSION.userDetail else { return }
        WhosinServices.venueCheckIn(venueId: _venueId, user: userDetail) { container, error in
            if error != nil {
                self.parentBaseController?.showError(error)
                return
            }
            guard let data = container?.message else { return }
            if data == "check-out" {
                self._checkInLabel.text = "Check-In"
            } else {
                self._checkInLabel.text = "Check-Out"
            }
        }
    }
    
    
    @IBAction func _handleCheckInEvent(_ sender: UIButton) {
        _requestCheckIn()
    }

}

extension CustomVenueCalloutView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        _userList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UserTableCell.height
    }
    // 5300
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kCellIdentifier, for: indexPath) as! UserTableCell
        let user = _userList[indexPath.row]
        cell.setup(user)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = _userList[indexPath.row]
        guard let userDetail = APPSESSION.userDetail, user.id != userDetail.id else { return}
    }
}

