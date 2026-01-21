import UIKit

class TicketCartOptionCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var _optionTitle: CustomLabel!
    @IBOutlet weak var _optionDesc: CustomLabel!
    @IBOutlet weak var _numberOfPax: CustomLabel!
    @IBOutlet weak var _optionDate: CustomLabel!
    @IBOutlet weak var _totalAmountStack: UIStackView!
    @IBOutlet weak var _addonAmountStack: UIStackView!
    @IBOutlet weak var _optionTime: CustomLabel!
    @IBOutlet weak var _menuBtn: UIButton!
    @IBOutlet weak var _totalAmount: CustomLabel!
    @IBOutlet weak var _addonAmount: CustomLabel!
    @IBOutlet weak var _customAddonView: CustomAddOnOptionsView!
    
    private var optionId: String = kEmptyString
    private var detail: TourOptionDetailModel?
    private var travelOption: TravelDeskTourModel?
    private var bigBusOption: BigBusOptionsModel?
    private var tourOption: TourOptionsModel?
    private var ticketModel: TicketModel?
    public var booking: BookingModel?
    
    
    // --------------------------------------
    // MARK: Life cycle
    // --------------------------------------
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat { 100 }
    
    private static var sizingCell: TicketCartOptionCollectionCell = {
        let nib = UINib(nibName: "TicketCartOptionCollectionCell", bundle: .main)
        let cell = nib.instantiate(withOwner: nil, options: nil).first as? TicketCartOptionCollectionCell
        return cell ?? TicketCartOptionCollectionCell()
    }()
    
    class func dynamicHeight(option: Any?, tourDetail: TourOptionDetailModel, bookingType: String, ticket: TicketModel, booking: BookingModel, width: CGFloat) -> CGFloat {
        let cell = sizingCell
        cell.booking = booking
        cell.ticketModel = ticket
        cell.optionId = tourDetail.optionId
        cell.detail = tourDetail
        
        let targetWidth = width > 0 ? width : UIScreen.main.bounds.width
        cell.bounds = CGRect(x: 0, y: 0, width: targetWidth, height: 0)
        cell.contentView.bounds = CGRect(x: 0, y: 0, width: targetWidth, height: 0)
        
        if let optionModel = option as? TourOptionsModel {
            cell.setUpdata(optionModel, tourDetail: tourDetail, type: bookingType, ticket: ticket, booking: booking)
        } else if let optionModel = option as? TravelDeskTourModel {
            cell.setUpdata(optionModel, tourDetail: tourDetail, ticket: ticket, booking: booking)
        } else if let optionModel = option as? BigBusOptionsModel {
            cell.setUpdata(optionModel, tourDetail: tourDetail, ticket: ticket, booking: booking)
        }
        
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        
        let fittingSize = CGSize(width: targetWidth, height: UIView.layoutFittingCompressedSize.height)
        let size = cell.contentView.systemLayoutSizeFitting(fittingSize,
                                                            withHorizontalFittingPriority: .required,
                                                            verticalFittingPriority: .fittingSizeLevel)
        
        return ceil(size.height)
    }
    
    // --------------------------------------
    // MARK: public
    // --------------------------------------
    
    public func setUpdata(_ data: TourOptionsModel, tourDetail: TourOptionDetailModel, type: String, ticket: TicketModel, booking: BookingModel) {
        self.booking = booking
        optionId = tourDetail.optionId
        tourOption = data
        detail = tourDetail
        ticketModel = ticket
        _customAddonView.setupData(model: tourDetail.Addons)
        _customAddonView.isHidden = tourDetail.Addons.isEmpty
        if type == "whosin" {
            _optionTitle.text = Utils.stringIsNullOrEmpty(data.displayName) ? data.title : data.displayName
            _optionDesc.text = Utils.stringIsNullOrEmpty(data.optionDescription) ? Utils.convertHTMLToPlainText(from: data.descriptions) : data.optionDescription
        } else {
            _optionTitle.text = data.optionName
            if Utils.stringIsNullOrEmpty(data.transferName) {
                _optionDesc.text = Utils.convertHTMLToPlainText(from: data.optionDescription)
            } else {
                _optionDesc.text = data.transferName
            }
        }
        _totalAmountStack.isHidden = false
        
        let paxes = LANGMANAGER.localizedString(forKey: "numberOfPax", arguments:
                                                    ["value1": "\(tourDetail.adult)",
                                                     "value2": Utils.stringIsNullOrEmpty(tourDetail.adultTitle) ? "adult".localized() : tourDetail.adultTitle ,
                                                     "value3": "\(tourDetail.child)",
                                                     "value4": Utils.stringIsNullOrEmpty(tourDetail.childTitle) ? "childTitle".localized() : tourDetail.childTitle,
                                                     "value5": "\(tourDetail.infant)" ,
                                                     "value6": Utils.stringIsNullOrEmpty(tourDetail.infantTitle) ? "infant_title".localized() : tourDetail.infantTitle])
        _numberOfPax.text = paxes
        let startTime = Utils.stringToDate(tourDetail.startTime, format: "HH:mm:ss") == nil ? Utils.stringToDate(tourDetail.startTime, format: "HH:mm") : Utils.stringToDate(tourDetail.startTime, format: "HH:mm:ss")
        let time = (Utils.stringIsNullOrEmpty(tourDetail.timeSlot)) ? startTime  : Utils.stringToDate(tourDetail.timeSlot, format: "HH:mm:ss")
        _optionTime.text = type == "whosin" ? Utils.stringIsNullOrEmpty(tourDetail.startTime) ? tourDetail.timeSlot : tourDetail.startTime : Utils.stringIsNullOrEmpty(Utils.dateToString(time, format: "HH:mm")) ? tourDetail.timeSlot : Utils.dateToString(time, format: "HH:mm")
        let date = Utils.stringToDate(tourDetail.tourDate, format: kStanderdDate)
        _optionDate.text = Utils.dateToString(date, format: kFormatEventDate)
        
        _totalAmount.attributedText = "\(Utils.getCurrentCurrencySymbol())\(Utils.convertCurrent(tourDetail.whosinTotal).formattedWithoutDecimal())".withCurrencyFont(13, false)
        let addonAmount = tourDetail.Addons.reduce(into: 0.0) { $0 += $1.whosinTotal }
        _addonAmountStack.isHidden = addonAmount == 0
        _addonAmount.attributedText = "\(Utils.getCurrentCurrencySymbol())\(Utils.convertCurrent(addonAmount).formattedWithoutDecimal())".withCurrencyFont(13, false)
    }
    
    public func setUpdata(_ data: TravelDeskTourModel, tourDetail: TourOptionDetailModel, ticket: TicketModel, booking: BookingModel) {
        self.booking = booking
        travelOption = data
        detail = tourDetail
        ticketModel = ticket
        optionId = tourDetail.optionId
        _totalAmountStack.isHidden = false
        _optionTitle.text = data.name
        _optionDesc.text = Utils.convertHTMLToPlainText(from: data.salesDescription)
        let paxes = LANGMANAGER.localizedString(forKey: "numberOfPax", arguments:
                                                    ["value1": "\(tourDetail.adult)",
                                                     "value2": Utils.stringIsNullOrEmpty(tourDetail.adultTitle) ? "adult".localized() : tourDetail.adultTitle ,
                                                     "value3": "\(tourDetail.child)",
                                                     "value4": Utils.stringIsNullOrEmpty(tourDetail.childTitle) ? "childTitle".localized() : tourDetail.childTitle,
                                                     "value5": "\(tourDetail.infant)" ,
                                                     "value6": Utils.stringIsNullOrEmpty(tourDetail.infantTitle) ? "infant_title".localized() : tourDetail.infantTitle])
        _numberOfPax.text = paxes
        let startTime = Utils.stringToDate(tourDetail.startTime, format: "HH:mm:ss") == nil ? Utils.stringToDate(tourDetail.startTime, format: "HH:mm") : Utils.stringToDate(tourDetail.startTime, format: "HH:mm:ss")
        let time = (Utils.stringIsNullOrEmpty(tourDetail.timeSlot)) ? startTime  : Utils.stringToDate(tourDetail.timeSlot, format: "HH:mm:ss")
        _optionTime.text = Utils.stringIsNullOrEmpty(tourDetail.timeSlot) ? Utils.dateToString(time, format: "HH:mm") : tourDetail.timeSlot
        let date = Utils.stringToDate(tourDetail.tourDate, format: kStanderdDate)
        _optionDate.text = Utils.dateToString(date, format: kFormatEventDate)
        let addonAmount = tourDetail.Addons.reduce(into: 0.0) { $0 += $1.whosinTotal }
        _addonAmountStack.isHidden = addonAmount == 0
        _addonAmount.attributedText = "\(Utils.getCurrentCurrencySymbol())\(Utils.convertCurrent(addonAmount).formattedWithoutDecimal())".withCurrencyFont(13, false)
        _totalAmount.attributedText = "\(Utils.getCurrentCurrencySymbol())\(Utils.convertCurrent(tourDetail.whosinTotal).formattedWithoutDecimal())".withCurrencyFont(13, false)
    }
    
    public func setUpdata(_ data: BigBusOptionsModel, tourDetail: TourOptionDetailModel, ticket: TicketModel, booking: BookingModel) {
        self.booking = booking
        bigBusOption = data
        detail = tourDetail
        ticketModel = ticket
        optionId = tourDetail.optionId
        _totalAmountStack.isHidden = false
        _optionTitle.text = data.title
        _optionDesc.text = Utils.convertHTMLToPlainText(from: data.shortDescription)
        let paxes = LANGMANAGER.localizedString(forKey: "numberOfPax", arguments:
                                                    ["value1": "\(tourDetail.adult)",
                                                     "value2": Utils.stringIsNullOrEmpty(tourDetail.adultTitle) ? "adult".localized() : tourDetail.adultTitle ,
                                                     "value3": "\(tourDetail.child)",
                                                     "value4": Utils.stringIsNullOrEmpty(tourDetail.childTitle) ? "childTitle".localized() : tourDetail.childTitle,
                                                     "value5": "\(tourDetail.infant)" ,
                                                     "value6": Utils.stringIsNullOrEmpty(tourDetail.infantTitle) ? "infant_title".localized() : tourDetail.infantTitle])
        _numberOfPax.text = paxes
        let startTime = Utils.stringToDate(tourDetail.startTime, format: "HH:mm:ss") == nil ? Utils.stringToDate(tourDetail.startTime, format: "HH:mm") : Utils.stringToDate(tourDetail.startTime, format: "HH:mm:ss")
        let time = (Utils.stringIsNullOrEmpty(tourDetail.timeSlot)) ? startTime  : Utils.stringToDate(tourDetail.timeSlot, format: "HH:mm:ss")
        _optionTime.text = Utils.stringIsNullOrEmpty(tourDetail.timeSlot) ? Utils.dateToString(time, format: "HH:mm") : tourDetail.timeSlot
        let date = Utils.stringToDate(tourDetail.tourDate, format: kStanderdDate)
        _optionDate.text = Utils.dateToString(date, format: kFormatEventDate)
        let addonAmount = tourDetail.Addons.reduce(into: 0.0) { $0 += $1.whosinTotal }
        _addonAmountStack.isHidden = addonAmount == 0
        _addonAmount.attributedText = "\(Utils.getCurrentCurrencySymbol())\(Utils.convertCurrent(addonAmount).formattedWithoutDecimal())".withCurrencyFont(13, false)
        _totalAmount.attributedText = "\(Utils.getCurrentCurrencySymbol())\(Utils.convertCurrent(tourDetail.whosinTotal).formattedWithoutDecimal())".withCurrencyFont(13, false)
    }
    
    @IBAction func _handleMenuBtnEvent(_ sender: UIButton) {
        guard let vc = self.parentBaseController else { return}
        showRemoveItemActionSheet(from: vc)
    }
    
    private func _removeItem() {
        guard let id = booking?._id else { return }
        parentBaseController?.showHUD(self)
        LOGMANAGER.logTicketEvent(.removeCart, id: optionId, name: _optionTitle.text ?? "")
        WhosinServices.RemoveOptionFromCart(params: ["id": id, "optionId": optionId]) { [weak self] container, error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.parentBaseController?.hideHUD(self, error: error)
                guard let container, container.code == 1 else { return }
                NotificationCenter.default.post(name: Notification.Name("addtoCartCount"), object: nil)
                self.parentBaseController?.showSuccessMessage("item_removed".localized(), subtitle: "removed_from_cart".localized())
            }
        }
    }
    
    func showRemoveItemActionSheet(from viewController: UIViewController) {
        let actionSheet = UIAlertController(title: nil, message: "choose_option".localized(), preferredStyle: .actionSheet)
        
        let editAction = UIAlertAction(title: "edit".localized(), style: .default) { _ in
            DISPATCH_ASYNC_MAIN {
                let vc = INIT_CONTROLLER_XIB(EditTicketCartVC.self)
                vc.bookingModel = self.booking
                vc.ticketModel = self.ticketModel
                vc.detail = self.detail
                vc.hidesBottomBarWhenPushed = true
                self.parentBaseController?.navigationController?.pushViewController(vc, animated: true)
            }
        }
        
        let removeAction = UIAlertAction(title: "remove_item".localized(), style: .destructive) { _ in
            self.parentBaseController?.confirmAlert(message: "remove_item_message".localized(), okHandler: { action in
                self._removeItem()
            })
        }
        
        let cancelAction = UIAlertAction(title: "cancel".localized(), style: .cancel, handler: nil)
        
        actionSheet.addAction(editAction)
        actionSheet.addAction(removeAction)
        actionSheet.addAction(cancelAction)
        
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.sourceView = viewController.view
            popoverController.sourceRect = CGRect(x: viewController.view.bounds.midX,
                                                  y: viewController.view.bounds.midY,
                                                  width: 0,
                                                  height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        viewController.present(actionSheet, animated: true, completion: nil)
    }
    
}
