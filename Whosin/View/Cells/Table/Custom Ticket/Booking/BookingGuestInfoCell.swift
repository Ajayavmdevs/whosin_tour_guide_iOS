import UIKit

class BookingGuestInfoCell: UITableViewCell {

    @IBOutlet weak var _firstName: CustomLabel!
    @IBOutlet weak var _lastName: CustomLabel!
    @IBOutlet weak var _email: CustomLabel!
    @IBOutlet weak var _phoneNumber: CustomLabel!
    @IBOutlet weak var _nationality: CustomLabel!
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
        disableSelectEffect()
    }
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat { UITableView.automaticDimension }

    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setupData(_ data: PassengersModel) {
        _firstName.text = data.firstName
        _lastName.text = data.lastName
        _email.text = data.email
        _phoneNumber.text = data.mobile
        _nationality.text = data.nationality
    }
    
}
