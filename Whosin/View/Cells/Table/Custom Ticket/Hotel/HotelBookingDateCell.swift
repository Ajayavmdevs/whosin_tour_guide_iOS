import UIKit

class HotelBookingDateCell: UITableViewCell {

    @IBOutlet private weak var _startDate: CustomLabel!
    @IBOutlet private weak var _endDate: CustomLabel!
    @IBOutlet private weak var _checkIn: CustomLabel!
    @IBOutlet private weak var _checkOut: CustomLabel!
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------

    class var height: CGFloat { UITableView.automaticDimension }

    // --------------------------------------
    // MARK:
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
        disableSelectEffect()
    }
    
    // --------------------------------------
    // MARK: Public setup
    // --------------------------------------

    public func setupdata(_ model: JPHotelBookingRequiredFields, info: JPHotelInfoModel) {
        _startDate.text = model.startDate
        _endDate.text = model.endDate
        _checkIn.text = info.checkTime?.checkIn ?? ""
        _checkOut.text = info.checkTime?.checkOut ?? ""
    }

}
