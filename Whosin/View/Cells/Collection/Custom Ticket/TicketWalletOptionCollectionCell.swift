import UIKit

class TicketWalletOptionCollectionCell: UICollectionViewCell {

    @IBOutlet weak var _optionTitle: CustomLabel!
    @IBOutlet weak var _optionDesc: CustomLabel!
    @IBOutlet weak var _numberOfPax: CustomLabel!
    @IBOutlet weak var _optionDate: CustomLabel!
    @IBOutlet weak var _optionTime: CustomLabel!
    @IBOutlet weak var _addOnView: UIView!
    @IBOutlet weak var _addOnOptionView: CustomAddOnOptionsView!
    
    // --------------------------------------
    // MARK: Life cycle
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    static let baseHeight: CGFloat = 105
    
    private static var sizingCell: TicketWalletOptionCollectionCell = {
        let nib = UINib(nibName: "TicketWalletOptionCollectionCell", bundle: .main)
        let cell = nib.instantiate(withOwner: nil, options: nil).first as? TicketWalletOptionCollectionCell
        return cell ?? TicketWalletOptionCollectionCell()
    }()

    static func height(for model: TourDetailsModel, type: String, width: CGFloat) -> CGFloat {
        let cell = sizingCell
        let targetWidth = width > 0 ? width : UIScreen.main.bounds.width
        cell.bounds = CGRect(x: 0, y: 0, width: targetWidth, height: 0)
        cell.contentView.bounds = CGRect(x: 0, y: 0, width: targetWidth, height: 0)
        cell.setUpdata(model, type: type)
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        let fittingSize = CGSize(width: targetWidth, height: UIView.layoutFittingCompressedSize.height)
        let size = cell.contentView.systemLayoutSizeFitting(fittingSize,
                                                            withHorizontalFittingPriority: .required,
                                                            verticalFittingPriority: .fittingSizeLevel)
        let height = ceil(size.height)
        return max(height, baseHeight)
    }

    // --------------------------------------
    // MARK: public
    // --------------------------------------

    public func setUpdata(_ data: TourDetailsModel, type: String) {
        if let model = data.whosinOptionData, type == "whosin-ticket" {
            _addOnView.isHidden = data.addons.count == 0
            _addOnOptionView.setupWalletData(model: data.addons.toArrayDetached(ofType: TourDetailsModel.self))
            _optionTitle.text = model.displayName
            _optionDesc.text = model.optionDescription
            if let date = Utils.stringToDate(data.tourDate, format: kStanderdDate) {
                _optionDate.text = Utils.dateToString(date, format: kFormatDate)
            } else {
                _optionDate.text = data.tourDate
            }
            _optionTime.text = data.timeSlot
            
            let paxes = LANGMANAGER.localizedString(forKey: "numberOfPax", arguments:
                                                        ["value1": "\(data.adult)",
                                                         "value2": Utils.stringIsNullOrEmpty(data.adultTitle) ? "adult".localized() : data.adultTitle ,
                                                         "value3": "\(data.child)",
                                                         "value4": Utils.stringIsNullOrEmpty(data.childTitle) ? "childTitle".localized() : data.childTitle,
                                                         "value5": "\(data.infant)" ,
                                                         "value6": Utils.stringIsNullOrEmpty(data.infantTitle) ? "infant_title".localized() : data.infantTitle])

            _numberOfPax.text = paxes
        }
        else if let model = data.optionData, type == "big-bus" || type == "hero-balloon" {
            _optionTitle.text = model.title
            _optionDesc.text = model.shortDescription
            if let date = Utils.stringToDate(data.tourDate, format: kStanderdDate) {
                _optionDate.text = Utils.dateToString(date, format: kFormatDate)
            } else {
                _optionDate.text = data.tourDate.toDisplayDate()
            }
            _optionTime.text = data.timeSlot
            
            let paxes = LANGMANAGER.localizedString(forKey: "numberOfPax", arguments:
                                                        ["value1": "\(data.adult)",
                                                         "value2": Utils.stringIsNullOrEmpty(data.adultTitle) ? "adult".localized() : data.adultTitle ,
                                                         "value3": "\(data.child)",
                                                         "value4": Utils.stringIsNullOrEmpty(data.childTitle) ? "childTitle".localized() : data.childTitle,
                                                         "value5": "\(data.infant)" ,
                                                         "value6": Utils.stringIsNullOrEmpty(data.infantTitle) ? "infant_title".localized() : data.infantTitle])

            _numberOfPax.text = paxes
        }
        else if let model = data.optionData {
            _optionTitle.text = model.name
            _optionDesc.text = Utils.convertHTMLToPlainText(from: model.descriptionText)
            if let date = Utils.stringToDate(data.tourDate, format: kStanderdDate) {
                _optionDate.text = Utils.dateToString(date, format: kFormatDate)
            } else {
                _optionDate.text = data.tourDate
            }
            _optionTime.text = data.timeSlot
            
            let paxes = LANGMANAGER.localizedString(forKey: "numberOfPax", arguments:
                                                        ["value1": "\(data.adult)",
                                                         "value2": Utils.stringIsNullOrEmpty(data.adultTitle) ? "adult".localized() : data.adultTitle ,
                                                         "value3": "\(data.child)",
                                                         "value4": Utils.stringIsNullOrEmpty(data.childTitle) ? "childTitle".localized() : data.childTitle,
                                                         "value5": "\(data.infant)" ,
                                                         "value6": Utils.stringIsNullOrEmpty(data.infantTitle) ? "infant_title".localized() : data.infantTitle])

            _numberOfPax.text = paxes
        }
        else if let model = data.customData {
            _addOnView.isHidden = data.addons.count == 0
            _addOnOptionView.setupWalletData(model: data.addons.toArrayDetached(ofType: TourDetailsModel.self))
            _optionTitle.text = model.displayName
            _optionDesc.text = Utils.convertHTMLToPlainText(from: model.optionDescription)
            if let date = Utils.stringToDate(data.tourDate, format: kStanderdDate) {
                _optionDate.text = Utils.dateToString(date, format: kFormatDate)
            } else {
                _optionDate.text = data.tourDate
            }
            _optionTime.text = data.timeSlot
            
            let paxes = LANGMANAGER.localizedString(forKey: "numberOfPax", arguments:
                                                        ["value1": "\(data.adult)",
                                                         "value2": Utils.stringIsNullOrEmpty(data.adultTitle) ? "adult".localized() : data.adultTitle ,
                                                         "value3": "\(data.child)",
                                                         "value4": Utils.stringIsNullOrEmpty(data.childTitle) ? "childTitle".localized() : data.childTitle,
                                                         "value5": "\(data.infant)" ,
                                                         "value6": Utils.stringIsNullOrEmpty(data.infantTitle) ? "infant_title".localized() : data.infantTitle])

            _numberOfPax.text = paxes
        }
        else {
            _addOnView.isHidden = data.addons.count == 0
            _addOnOptionView.setupWalletData(model: data.addons.toArrayDetached(ofType: TourDetailsModel.self))
            _optionTitle.text = data.tourOption?.optionName
            _optionDesc.text = Utils.stringIsNullOrEmpty(data.tourOption?.optionDescription) ? data.tourOption?.descriptions : data.tourOption?.optionDescription
            
            if let date = Utils.stringToDate(data.tourDate, format: kStanderdDate) {
                _optionDate.text = Utils.dateToString(date, format: kFormatDate)
            } else {
                _optionDate.text = data.tourDate
            }
            _optionTime.text = Utils.stringIsNullOrEmpty(data.startTime) ? data.timeSlot : data.startTime
            
            let paxes = LANGMANAGER.localizedString(forKey: "numberOfPax", arguments:
                                                        ["value1": "\(data.adult)",
                                                         "value2": Utils.stringIsNullOrEmpty(data.adultTitle) ? "adult".localized() : data.adultTitle ,
                                                         "value3": "\(data.child)",
                                                         "value4": Utils.stringIsNullOrEmpty(data.childTitle) ? "childTitle".localized() : data.childTitle,
                                                         "value5": "\(data.infant)" ,
                                                         "value6": Utils.stringIsNullOrEmpty(data.infantTitle) ? "infant_title".localized() : data.infantTitle])
            _numberOfPax.text = paxes

        }
    }

}
