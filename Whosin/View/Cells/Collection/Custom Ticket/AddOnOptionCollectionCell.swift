import UIKit

class AddOnOptionCollectionCell: UICollectionViewCell {


    @IBOutlet weak var _bgView: UIView!
    @IBOutlet weak var _title: CustomLabel!
    @IBOutlet weak var _description: CustomLabel!
    @IBOutlet weak var _price: CustomLabel!
    @IBOutlet weak var _adultTimeStack: UIStackView!
    @IBOutlet weak var _adultLabel: CustomLabel!
    @IBOutlet weak var _timeSlot: CustomLabel!
    @IBOutlet weak var _addonImage: UIImageView!
    @IBOutlet weak var _addOnButton: UIButton!
    private var selectedAddOnOption: TourOptionsModel?
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class func height(for data: TourOptionsModel, selectedOption: TourOptionDetailModel?, width: CGFloat) -> CGFloat {
        var extraHeight: CGFloat = 0
        
        if let addon = getAddonDetail(from: selectedOption, for: data) {
            let labelFont = FontBrand.SFregularFont(size: 12)
            let adultTitle = Utils.stringIsNullOrEmpty(addon.adultTitle) ? "Adults" : addon.adultTitle
            let childTitle = Utils.stringIsNullOrEmpty(addon.childTitle) ? "Child" : addon.childTitle
            let infantTitle = Utils.stringIsNullOrEmpty(addon.infantTitle) ? "" : addon.infantTitle
            var paxParts: [String] = []
            if addon.adult > 0 {
                paxParts.append("\(addon.adult)x \(adultTitle)")
            }
            if addon.child > 0 {
                paxParts.append("\(addon.child)x \(childTitle)")
            }
            if addon.infant > 0 {
                paxParts.append("\(addon.infant)x \(infantTitle.isEmpty ? "Infant" : infantTitle)")
            }
            let adultText = paxParts.joined(separator: ", ")
            let timeText = addon.timeSlot
            
            let labelWidth = (width - 84) / 2
            let adultHeight = adultText.heightOfString(usingFont: labelFont, constrainedToWidth: labelWidth)
            let timeHeight = Utils.stringIsNullOrEmpty(timeText) ? 0 : timeText.heightOfString(usingFont: labelFont, constrainedToWidth: labelWidth)
            let contentHeight = max(adultHeight, timeHeight)
            
            if (addon.adult + addon.child + addon.infant) > 0 || !Utils.stringIsNullOrEmpty(timeText) {
                extraHeight = 0.5 + 8 + contentHeight + 8
            }
        }
        
        let total = 102 + extraHeight
        return ceil(max(total, 50))
    }
    
    class var height: CGFloat {
        135
    }
    
    class func height(_ data: TourOptionDetailModel, width: CGFloat) -> CGFloat {
        var extraHeight: CGFloat = 0
        
        let labelFont = FontBrand.SFregularFont(size: 12)
        let adultTitle = Utils.stringIsNullOrEmpty(data.adultTitle) ? "Adults" : data.adultTitle
        let childTitle = Utils.stringIsNullOrEmpty(data.childTitle) ? "Child" : data.childTitle
        let infantTitle = Utils.stringIsNullOrEmpty(data.infantTitle) ? "" : data.infantTitle
        var paxParts: [String] = []
        if data.adult > 0 {
            paxParts.append("\(data.adult)x \(adultTitle)")
        }
        if data.child > 0 {
            paxParts.append("\(data.child)x \(childTitle)")
        }
        if data.infant > 0 {
            paxParts.append("\(data.infant)x \(infantTitle.isEmpty ? "Infant" : infantTitle)")
        }
        let adultText = paxParts.joined(separator: ", ")
        let timeText = data.timeSlot
        
        let labelWidth = (width - 84) / 2
        let adultHeight = adultText.heightOfString(usingFont: labelFont, constrainedToWidth: labelWidth)
        let timeHeight = Utils.stringIsNullOrEmpty(timeText) ? 0 : timeText.heightOfString(usingFont: labelFont, constrainedToWidth: labelWidth)
        let contentHeight = max(adultHeight, timeHeight)
        
        if (data.adult + data.child + data.infant) > 0 || !Utils.stringIsNullOrEmpty(timeText) {
            extraHeight = 0.5 + 8 + contentHeight + 8
        }
        
        let total = 102 + extraHeight
        return ceil(max(total, 50))
    }
    
    class func height(_ data: TourDetailsModel, width: CGFloat) -> CGFloat {
        var extraHeight: CGFloat = 0
        
        let labelFont = FontBrand.SFregularFont(size: 12)
        let adultTitle = Utils.stringIsNullOrEmpty(data.adultTitle) ? "Adults" : data.adultTitle
        let childTitle = Utils.stringIsNullOrEmpty(data.childTitle) ? "Child" : data.childTitle
        let infantTitle = Utils.stringIsNullOrEmpty(data.infantTitle) ? "" : data.infantTitle
        var paxParts: [String] = []
        if data.adult > 0 {
            paxParts.append("\(data.adult)x \(adultTitle)")
        }
        if data.child > 0 {
            paxParts.append("\(data.child)x \(childTitle)")
        }
        if data.infant > 0 {
            paxParts.append("\(data.infant)x \(infantTitle.isEmpty ? "Infant" : infantTitle)")
        }
        let adultText = paxParts.joined(separator: ", ")
        let timeText = data.timeSlot
        
        let labelWidth = (width - 84) / 2
        let adultHeight = adultText.heightOfString(usingFont: labelFont, constrainedToWidth: labelWidth)
        let timeHeight = Utils.stringIsNullOrEmpty(timeText) ? 0 : timeText.heightOfString(usingFont: labelFont, constrainedToWidth: labelWidth)
        let contentHeight = max(adultHeight, timeHeight)
        
        if (data.adult + data.child + data.infant) > 0 || !Utils.stringIsNullOrEmpty(timeText) {
            extraHeight = 0.5 + 8 + contentHeight + 8
        }
        
        let total = 102 + extraHeight
        return ceil(max(total, 50))
    }

    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
        _description.numberOfLines = 2
        _description.isUserInteractionEnabled = true
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setupData(_ data: TourOptionsModel, selectedOption: TourOptionDetailModel?) {
        selectedAddOnOption = data
        
        _title.text = data.title
        _description.text = data.sortDescription
        _description.numberOfLines = 2
//        _description.lineBreakMode = .byTruncatingTail
//
        setNeedsLayout()
        layoutIfNeeded()
//
//        applySeeMoreIfNeeded(text: data.sortDescription)
        
        let imageUrl = data.images.toArray(ofType: String.self).filter({ !Utils.isVideo($0) }).first ?? kEmptyString
        _addonImage.loadWebImage(imageUrl)
        
        let addon = AddOnOptionCollectionCell.getAddonDetail(from: selectedOption, for: data)
        let adultCount = addon?.adult ?? 0
        let childCount = addon?.child ?? 0
        let timeSlot = addon?.timeSlot ?? ""
        let adultTitle = Utils.stringIsNullOrEmpty(addon?.adultTitle ?? "") ? "Adults" : (addon?.adultTitle ?? "")
        let childTitle = Utils.stringIsNullOrEmpty(addon?.childTitle ?? "") ? "Child" : (addon?.childTitle ?? "")
        
        let selectedTotal = (addon != nil && (adultCount + childCount + (addon?.infant ?? 0)) > 0 ) ? addon!.whosinTotal : data.finalAmount
        let currencySymbol = NSAttributedString(
            string: " \(Utils.getCurrentCurrencySymbol())",
            attributes: [.foregroundColor: UIColor.white, .font: APPSESSION.userDetail?.currency == "AED" || APPSESSION.userDetail?.currency == "D" ? FontBrand.dirhamText(size: 13) : FontBrand.SFboldFont(size: 13)]
        )
        let priceText = NSAttributedString(
            string: "\(selectedTotal)",
            attributes: [.foregroundColor: UIColor.white, .font: FontBrand.SFmediumFont(size: 14)]
        )
        let finalText = NSMutableAttributedString()
        finalText.append(currencySymbol)
        finalText.append(priceText)
        _price.attributedText = finalText
        
        let infantCount = addon?.infant ?? 0
        var paxParts: [String] = []
        if adultCount > 0 {
            paxParts.append("\(adultCount)x \(adultTitle)")
        }
        if childCount > 0 {
            paxParts.append("\(childCount)x \(childTitle)")
        }
        if infantCount > 0 {
            let infantTitle = Utils.stringIsNullOrEmpty(addon?.infantTitle ?? "") ? "Infant" : (addon?.infantTitle ?? "")
            paxParts.append("\(infantCount)x \(infantTitle)")
        }
        _adultLabel.text = paxParts.joined(separator: ", ")
        _timeSlot.text = timeSlot
        
        let hasPax = (adultCount + childCount + infantCount) > 0
        _adultTimeStack.isHidden = !(hasPax || !Utils.stringIsNullOrEmpty(timeSlot))
        let buttonTitle = (hasPax || !Utils.stringIsNullOrEmpty(timeSlot)) ? "ADD MORE" : "ADD"
        _addOnButton.setTitle(buttonTitle, for: .normal)
        
        let isSelected = hasPax || !Utils.stringIsNullOrEmpty(timeSlot)
        _bgView.layer.borderWidth = isSelected ? 1 : 0.5
        _bgView.borderColor = isSelected ? UIColor(hexString: "#2BA735") : ColorBrand.brandGray 
    }
    
    public func setupData(_ data: TourOptionDetailModel) {
        _title.text = data.addOnTitle
        _description.text = data.addOndesc
        _description.numberOfLines = 2
        _addOnButton.isHidden = true
//        _description.lineBreakMode = .byTruncatingTail
//
        setNeedsLayout()
        layoutIfNeeded()
//
//        applySeeMoreIfNeeded(text: data.sortDescription)
        
        _addonImage.loadWebImage(data.addOnImage)
        let adultCount = data.adult
        let childCount = data.child
        let timeSlot = data.timeSlot
        let adultTitle = Utils.stringIsNullOrEmpty(data.adultTitle) ? "Adults" : (data.adultTitle)
        let childTitle = Utils.stringIsNullOrEmpty(data.childTitle) ? "Child" : (data.childTitle)
        
        let selectedTotal = data.whosinTotal
        let currencySymbol = NSAttributedString(
            string: " \(Utils.getCurrentCurrencySymbol())",
            attributes: [.foregroundColor: UIColor.white, .font: APPSESSION.userDetail?.currency == "AED" || APPSESSION.userDetail?.currency == "D" ? FontBrand.dirhamText(size: 13) : FontBrand.SFboldFont(size: 13)]
        )
        let priceText = NSAttributedString(
            string: "\(selectedTotal)",
            attributes: [.foregroundColor: UIColor.white, .font: FontBrand.SFmediumFont(size: 14)]
        )
        let finalText = NSMutableAttributedString()
        finalText.append(currencySymbol)
        finalText.append(priceText)
        _price.attributedText = finalText
        
        let infantCount = data.infant
        var paxParts: [String] = []
        if adultCount > 0 {
            paxParts.append("\(adultCount)x \(adultTitle)")
        }
        if childCount > 0 {
            paxParts.append("\(childCount)x \(childTitle)")
        }
        if infantCount > 0 {
            let infantTitle = Utils.stringIsNullOrEmpty(data.infantTitle) ? "Infant" : (data.infantTitle)
            paxParts.append("\(infantCount)x \(infantTitle)")
        }
        _adultLabel.text = paxParts.joined(separator: ", ")
        _timeSlot.text = timeSlot
        
        let hasPax = (adultCount + childCount + infantCount) > 0
        _adultTimeStack.isHidden = !(hasPax || !Utils.stringIsNullOrEmpty(timeSlot))
        
        _bgView.layer.borderWidth = 0.5
        _bgView.borderColor = ColorBrand.brandGray
    }
    
    public func setupData(_ data: TourDetailsModel) {
        
        _title.text = data.addonOption?.title ?? data.addOnTitle
        _description.text = data.addonOption?.sortDescription ?? data.addOndesc
        _addOnButton.isHidden = true
        
        let imageUrl = data.addonOption?.images.toArray(ofType: String.self).filter({ !Utils.isVideo($0) }).first ?? data.addOnImage
        _addonImage.loadWebImage(imageUrl)
        
        let adultCount = data.adult
        let childCount = data.child
        let timeSlot = data.timeSlot
        let adultTitle = Utils.stringIsNullOrEmpty(data.adultTitle) ? "Adults" : data.adultTitle
        let childTitle = Utils.stringIsNullOrEmpty(data.childTitle) ? "Child" : data.childTitle
        
        let selectedTotal = ((adultCount + childCount + (data.infant)) > 0 ) ? data.whosinTotal : data.serviceTotal
        let currencySymbol = NSAttributedString(
            string: " \(Utils.getCurrentCurrencySymbol())",
            attributes: [.foregroundColor: UIColor.white, .font: APPSESSION.userDetail?.currency == "AED" || APPSESSION.userDetail?.currency == "D" ? FontBrand.dirhamText(size: 13) : FontBrand.SFboldFont(size: 13)]
        )
        let priceText = NSAttributedString(
            string: "\(selectedTotal)",
            attributes: [.foregroundColor: UIColor.white, .font: FontBrand.SFmediumFont(size: 14)]
        )
        let finalText = NSMutableAttributedString()
        finalText.append(currencySymbol)
        finalText.append(priceText)
        _price.attributedText = finalText
        
        let infantCount = data.infant
        var paxParts: [String] = []
        if adultCount > 0 {
            paxParts.append("\(adultCount)x \(adultTitle)")
        }
        if childCount > 0 {
            paxParts.append("\(childCount)x \(childTitle)")
        }
        if infantCount > 0 {
            let infantTitle = Utils.stringIsNullOrEmpty(data.infantTitle) ? "Infant" : data.infantTitle
            paxParts.append("\(infantCount)x \(infantTitle)")
        }
        _adultLabel.text = paxParts.joined(separator: ", ")
        _timeSlot.text = timeSlot
        
        let hasPax = (adultCount + childCount + infantCount) > 0
        _adultTimeStack.isHidden = !(hasPax || !Utils.stringIsNullOrEmpty(timeSlot))
        
        _bgView.layer.borderWidth = 0.5
        _bgView.borderColor = ColorBrand.brandGray
    }

    
    private static func getAddonDetail(from selectedOption: TourOptionDetailModel?, for data: TourOptionsModel) -> TourOptionDetailModel? {
        return selectedOption?.Addons.first(where: {
            $0.optionId == data._id ||
            $0.optionId == "\(data.tourOptionId)" ||
            $0.optionId == data.optionId
        })
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func isTextTruncated(_ label: UILabel, maxLines: Int) -> Bool {
        guard let text = label.text, let font = label.font else { return false }

        let maxHeight = font.lineHeight * CGFloat(maxLines)
        let size = CGSize(width: label.frame.width, height: .greatestFiniteMagnitude)

        let rect = (text as NSString).boundingRect(
            with: size,
            options: [.usesLineFragmentOrigin],
            attributes: [.font: font],
            context: nil
        )

        return rect.height > maxHeight
    }


    private func applySeeMoreIfNeeded(text: String) {
        guard isTextTruncated(_description, maxLines: 3) else {
            _description.attributedText = NSAttributedString(
                string: text,
                attributes: [.foregroundColor: UIColor.white]
            )
            return
        }

        let readMoreText = " See More"
        
        let attrText = NSMutableAttributedString(
            string: text,
            attributes: [
                .foregroundColor: UIColor.white,
                .font: FontBrand.SFregularFont(size: 12)
            ]
        )

        let seeMoreAttr = NSAttributedString(
            string: readMoreText,
            attributes: [
                .foregroundColor: ColorBrand.brandPink,
                .font: FontBrand.SFmediumFont(size: 12)
            ]
        )

        attrText.append(seeMoreAttr)
        _description.attributedText = attrText

        let tap = UITapGestureRecognizer(target: self, action: #selector(openDescriptionBottomSheet))
        _description.addGestureRecognizer(tap)
    }



    // --------------------------------------
    // MARK: Events
    // --------------------------------------
    
    @objc private func openDescriptionBottomSheet() {
        let vc = INIT_CONTROLLER_XIB(DeclaimerBottomSheet.self)
        vc.disclaimerTitle = "description".localized()
        vc.disclaimerdescriptions = selectedAddOnOption?.descriptions ?? ""
        parentBaseController?.presentAsPanModal(controller: vc)
    }

}
