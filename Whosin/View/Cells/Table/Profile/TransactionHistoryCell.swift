import UIKit

class TransactionHistoryCell: UITableViewCell {

    @IBOutlet private var ticketImage: UIImageView!
    @IBOutlet private var titleText: CustomLabel!
    @IBOutlet private var userText: CustomLabel!
    @IBOutlet private var ticketPrice: CustomLabel!
    @IBOutlet private var status: CustomLabel!
    @IBOutlet private var ticketDate: CustomLabel!
    @IBOutlet private var ticketStatus: CustomLabel!
    @IBOutlet private var totalPrice: CustomLabel!
    @IBOutlet private var statusImage: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        disableSelectEffect()
    }

    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    static var height: CGFloat { UITableView.automaticDimension }
    
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------

    func setUpdata(model: TransactionHistoryModel) {
        titleText.text = model.title
        userText.text = model.subtitle
        ticketDate.text = model.date
        ticketPrice.text = model.amount
        status.text = model.status
        ticketStatus.text = model.bottomText
        totalPrice.text = model.bottomRightText
        
        if !model.bottomIcon.isEmpty {
            statusImage.image = UIImage(named: model.bottomIcon)
        }
        
        // Set colors based on transaction type (credit/debit)
        if model.isCredit {
            ticketPrice.textColor = UIColor(hexString: "4CAF50") // Green
        } else {
            ticketPrice.textColor = UIColor(hexString: "F44336") // Red
        }
        
        // Set status color
        switch model.status.lowercased() {
        case "cancelled":
            status.textColor = ColorBrand.brandBorderRed
        case "pending":
            status.textColor = ColorBrand.amberColor
        case "refund":
            status.textColor = ColorBrand.brandGreen
        case "completed":
            status.textColor = ColorBrand.brandGreen
        default:
            status.textColor = ColorBrand.white
        }
    }

}
