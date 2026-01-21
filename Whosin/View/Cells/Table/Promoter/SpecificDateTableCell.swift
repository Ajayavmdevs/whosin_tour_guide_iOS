import UIKit

class SpecificDateTableCell: UITableViewCell {
    
    @IBOutlet weak var _customSocialView: CustomSpecificDateView!
    public var callback: ((_ model: [RepeatDateAndTimeModel]) -> Void)?
    public var clearAll:(() -> Void)?
    
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
        _customSocialView.updateDataCallback = { data in
            self.callback?(data)
        }
    }
    
    public func setupData(_ model: [RepeatDateAndTimeModel], params: [String: Any]) {
        let startTime = params["repeatStartDate"] as? String ?? kEmptyString
        let endTime = params["repeatEndDate"] as? String ?? kEmptyString
        _customSocialView.setupData(model, startTime: startTime, endTime: endTime)
    }

    @IBAction func _handleClearAllEvent(_ sender: CustomButton) {
        parentBaseController?.confirmAlert(message: "clear_all_date_alert".localized(), okHandler: { UIAlertAction in
            self.clearAll?()
        })
    }
}


