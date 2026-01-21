import UIKit

class CancellationPolicyTableCell: UITableViewCell {

    @IBOutlet weak var _bgView: UIView!
    @IBOutlet weak var _sapratorView: UIView!
    @IBOutlet weak var _cancellationTime: CustomLabel!
    @IBOutlet weak var _refundLabel: CustomLabel!
    
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

    public func setupData(_ data: TourPolicyModel) {
        let date1 = Utils.stringToDate(data.fromDate, format: "yyyy-MM-dd'T'HH:mm:ss")
        let fromDate = Utils.dateToString(date1, format: "h:mm a, E, d MMM yyyy")
        
        let date2 = Utils.stringToDate(data.toDate, format: "yyyy-MM-dd'T'HH:mm:ss")
        let toDate = Utils.dateToString(date2, format: "h:mm a, E, d MMM yyyy")
        _cancellationTime.font = FontBrand.SFregularFont(size: 13.0)

        _cancellationTime.attributedText = formattedDateString(fromDate: fromDate, toDate: toDate) 
        _refundLabel.text = LANGMANAGER.localizedString(forKey: "refund_value", arguments: ["value": "\(100 - data.percentage)"])
        _refundLabel.font = FontBrand.SFboldFont(size: 13.0)
        _bgView.backgroundColor = UIColor(hexString: "#343434")
        _cancellationTime.textAlignment = .left
        _refundLabel.textAlignment = .right
    }
    
    public func setupData(_ data: JPCancellationPolicyModel) {
        let date1 = Utils.stringToDate(data.dateFrom, format: "yyyy-MM-dd")
        let fromDate = Utils.dateToString(date1, format: "h:mm a, E, d MMM yyyy")
        
        let date2 = Utils.stringToDate(data.DateTo, format: "yyyy-MM-dd")
        let toDate = Utils.dateToString(date2, format: "h:mm a, E, d MMM yyyy")
        _cancellationTime.font = FontBrand.SFregularFont(size: 13.0)

        _cancellationTime.attributedText = formattedDateString(fromDate: fromDate, toDate: toDate) 
        _refundLabel.text = LANGMANAGER.localizedString(forKey: "refund_value", arguments: ["value": "\(100 - (Int(data.percentPrice) ?? 0))"])
        _refundLabel.font = FontBrand.SFboldFont(size: 13.0)
        _bgView.backgroundColor = UIColor(hexString: "#343434")
        _cancellationTime.textAlignment = .left
        _refundLabel.textAlignment = .right
    }
    
    func formattedDateString(fromDate: String, toDate: String) -> NSAttributedString {
        let fullString = "and_from".localized() + "\(fromDate)\n" + "and_to".localized() +  "\(toDate)"
        let attributedString = NSMutableAttributedString(string: fullString)

        let boldFont = FontBrand.SFboldFont(size: 13)
        let regularFont = FontBrand.SFregularFont(size: 13)

        let boldAttributes: [NSAttributedString.Key: Any] = [.font: boldFont]
        let regularAttributes: [NSAttributedString.Key: Any] = [.font: regularFont]

        if let fromRange = fullString.range(of: "and_from".localized()) {
            let nsRange = NSRange(fromRange, in: fullString)
            attributedString.addAttributes(boldAttributes, range: nsRange)
        }

        if let toRange = fullString.range(of: "and_to".localized()) {
            let nsRange = NSRange(toRange, in: fullString)
            attributedString.addAttributes(boldAttributes, range: nsRange)
        }

        let fromDateRange = NSRange(location: fullString.range(of: "and_from".localized())!.upperBound.utf16Offset(in: fullString), length: fromDate.count)
        let toDateRange = NSRange(location: fullString.range(of: "and_to".localized())!.upperBound.utf16Offset(in: fullString), length: toDate.count)
        
        attributedString.addAttributes(regularAttributes, range: fromDateRange)
        attributedString.addAttributes(regularAttributes, range: toDateRange)

        return attributedString
    }

    
    public func setupFirstCellData() {
        _cancellationTime.text = "cancellation_time".localized()
        _refundLabel.text = "refund".localized()
        _cancellationTime.font = FontBrand.SFboldFont(size: 14.0)
        _refundLabel.font = FontBrand.SFboldFont(size: 14.0)
        _bgView.layer.cornerRadius = 9.0
        _bgView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        _bgView.backgroundColor = UIColor(hexString: "#282828")
        _cancellationTime.textAlignment = .left
        _refundLabel.textAlignment = .right
    }
    
    public func setCorners(lastRow: Bool = false, firstRow: Bool = false) {
        DispatchQueue.main.async {
            self._bgView.roundCorners(corners: (firstRow ? (lastRow ? [.allCorners] : [.topLeft, .topRight]) : (lastRow ? [.bottomRight, .bottomLeft] : [])), radius: (firstRow && lastRow ? 9 : 9))
        }
        _sapratorView.isHidden = lastRow
    }
}
