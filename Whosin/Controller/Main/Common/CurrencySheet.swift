
import UIKit
import PanModal
import FSCalendar
import SnapKit


class CurrencySheet: BaseViewController {
    @IBOutlet private weak var _mainContainerView: UIView!
    @IBOutlet weak var _tableView: CustomNoKeyboardTableView!
    @IBOutlet weak var _updateBtn: CustomActivityButton!
    @IBOutlet weak var _viewHeight: NSLayoutConstraint!
    @IBOutlet weak var _sheetTitle: CustomLabel!
    private var kCellIdentifier = String(describing: LanguageTableViewCell.self)
    public var isCurrency: Bool = false
    var languages: [LanguagesModel] = []
    var curruncies: [CurrenciesModel] = []
    var selectedLanguage: LanguagesModel? = nil
    var selectedCurrency: CurrenciesModel? = nil


    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUi()
    }
        
    override func setupUi() {
        _sheetTitle.text = isCurrency ? "select_currency".localized() : "select_language".localized()
        _mainContainerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        _tableView.setup(
            cellPrototypes: _prototypes,
            hasHeaderSection: false,
            hasFooterSection: false,
            isHeaderCollapsible: false,
            isDummyLoad: false,
            enableRefresh: false,
            emptyDataText: "oops_empty".localized(),
            emptyDataIconImage: UIImage(named: "empty_event"),
            emptyDataDescription: nil,
            delegate: self)
        _tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        _loadData()
    }
    
    // --------------------------------------
    // MARK: Private Accessor
    // --------------------------------------
    
    private func _loadData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        
        if isCurrency {
            APPSETTING.currencies.forEach { model in
                cellData.append([
                    kCellIdentifierKey: kCellIdentifier,
                    kCellTagKey: kCellIdentifier,
                    kCellObjectDataKey: model,
                    kCellClassKey: LanguageTableViewCell.self,
                    kCellHeightKey: LanguageTableViewCell.height
                ])
            }
        } else {
            APPSETTING.languages.forEach { model in
                cellData.append([
                    kCellIdentifierKey: kCellIdentifier,
                    kCellTagKey: kCellIdentifier,
                    kCellObjectDataKey: model,
                    kCellClassKey: LanguageTableViewCell.self,
                    kCellHeightKey: LanguageTableViewCell.height
                ])
            }
        }
        let totalHeight = cellData.reduce(0) { $0 + (( $1[kCellHeightKey] as? CGFloat) ?? 0) }
        _viewHeight.constant = min(totalHeight + 20, 600)

        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _tableView.loadData(cellSectionData)
    }

    private var _prototypes: [[String: Any]]? {
        return [[kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: kCellIdentifier, kCellClassKey: LanguageTableViewCell.self, kCellHeightKey: LanguageTableViewCell.height]
        ]
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    @IBAction func _handleCloseEvent(_ sender: UIButton) {
        dismiss(animated: true)
    }

    @IBAction func _handleUpdateEvent(_ sender: CustomActivityButton) {
        let nationality = APPSESSION.userDetail?.nationality ?? ""
        
        if isCurrency {
            guard let selectedCurrency = selectedCurrency else {
                self.showCustomAlert(title: "Error", message: "select_currency_alert".localized(), yesButtonTitle: "ok".localized())
                return
            }
            
            self.showCustomAlert(
                title: "confirm_currency".localized(),
                message: LANGMANAGER.localizedString(forKey: "currency_update_dialog".localized(), arguments: ["value": selectedCurrency.currency]),
                yesButtonTitle: "yes".localized(),
                noButtonTitle: "cancel".localized(),
                okHandler: { [weak self] _ in
                    guard let self = self else { return }
                    
                    let params: [String: Any] = [
                        "currency": selectedCurrency.currency,
                        "nationality": nationality
                    ]
                    
                    APPSESSION.updateProfile(param: params, isUpdate: true) { [weak self] isSuccess, error in
                        guard let self = self else { return }
                        self.hideHUD(error: error)
                        guard isSuccess else { return }
                        CurrencyLoaderView.show()
                    }
                }
            )
        } else {
            guard let selectedLanguage = selectedLanguage else {
                self.showCustomAlert(title: "Error", message: "select_language_alert".localized(), yesButtonTitle: "ok".localized())
                return
            }
            
            self.showCustomAlert(
                title: "confirm_language".localized(),
                message: LANGMANAGER.localizedString(forKey: "language_update_dialog", arguments: ["value": selectedLanguage.name]),
                yesButtonTitle: "yes".localized(),
                noButtonTitle: "cancel".localized(),
                okHandler: { [weak self] _ in
                    guard let self = self else { return }
                    let params: [String: Any] = [
                        "lang": selectedLanguage.code,
                        "nationality": nationality
                    ]
                    LanguageManager.shared.currentLanguage = selectedLanguage.code
                    APPSESSION.updateProfile(param: params, isUpdate: true) { [weak self] isSuccess, error in
                        guard let self = self else { return }
                        self.hideHUD(error: error)
                        guard isSuccess else { return }
                        NotificationCenter.default.post(name: .reloadShoutouts, object: nil)
                        LangguageLoaderView.show()
                    }
                }
            )
        }
        
    }
    
}

extension CurrencySheet: CustomNoKeyboardTableViewDelegate {
    
    // --------------------------------------
    // MARK: <CustomTableViewDelegate>
    // --------------------------------------
    
    func setupCell(_ cell: UITableViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let cell = cell as? LanguageTableViewCell else { return }
        if let object = cellDict?[kCellObjectDataKey] as? CurrenciesModel {
            let current = APPSESSION.userDetail?.currency
            cell.setupData(object, selectedCurrency == nil ? current == object.currency : selectedCurrency == object)
        } else if let object = cellDict?[kCellObjectDataKey] as? LanguagesModel {
            cell.setupData(object, selectedLanguage == nil ? LANGMANAGER.currentLanguage == object.code : selectedLanguage == object)
        }
    }
    
    func didSelectTableCell(_ cell: UITableViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let cell = cell as? LanguageTableViewCell else { return }
        if let object = cellDict?[kCellObjectDataKey] as? CurrenciesModel {
            selectedCurrency = object
        } else if let object = cellDict?[kCellObjectDataKey] as? LanguagesModel {
            selectedLanguage = object
        }
        _tableView.reload()
    }

    
}


extension CurrencySheet: PanModalPresentable {
    
    var panScrollable: UIScrollView? {
        return nil
    }
    
    var anchorModalToLongForm: Bool {
        return true
    }
    
    var springDamping: CGFloat {
        return 1.0
    }
    
    var panModalBackgroundColor: UIColor {
        return UIColor.black.withAlphaComponent(0.4)
    }
    
    var isHapticFeedbackEnabled: Bool {
        return true
    }
    
    var allowsTapToDismiss: Bool {
        return true
    }
    
    var allowsDragToDismiss: Bool {
        return true
    }
    
    public var showDragIndicator: Bool {
        return false
    }
    
    func panModalWillDismiss() {
    }
    
}
