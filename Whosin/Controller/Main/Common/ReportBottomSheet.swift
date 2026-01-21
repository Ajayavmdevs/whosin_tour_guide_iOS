import UIKit
import PanModal

class ReportBottomSheet: BaseViewController {

    @IBOutlet weak var _tableView: CustomNoKeyboardTableView!
    private let kCellIdentifier = String(describing: ReportTableCell.self)
    var didUpdateCallback: ((_ type: String, _ reason: String, _ msg: String) -> Void)?
    private var _text: String = kEmptyString
    public var type: String = kEmptyString
    public var userTitle: String = kEmptyString
    private var _reportList: [String] = [
        "Harassment/Abuse",
        "Hate Speech",
        "Sexual/Inappropriate Content",
        "Threats",
        "Spam/Scams",
        "Fake or Impersonation",
        "Misinformation",
        "Other"
    ]
    private var selectedIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUi()
    }
    
    // --------------------------------------
    // MARK: Setup
    // --------------------------------------

    override func setupUi() {
        _tableView.setup(
            cellPrototypes: _prototype,
            hasHeaderSection: true,
            hasFooterSection: false,
            isHeaderCollapsible: false,
            isDummyLoad: false,
            enableRefresh: false,
            isShowRefreshing: false,
            emptyDataText: "You haven’t attended any events yet!",
            emptyDataIconImage: UIImage(named: "empty_explore"),
            emptyDataDescription: nil,
            delegate: self)
        _tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 70, right: 0)
        _loadData()
    }
    
    
    private var _prototype: [[String: Any]]? {
        return [[kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: kCellIdentifier, kCellClassKey: ReportTableCell.self, kCellHeightKey: ReportTableCell.height]]
    }
    
    private func _loadData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        
        _reportList.forEach { report in
            cellData.append([
                kCellIdentifierKey: kCellIdentifier,
                kCellTagKey: kCellIdentifier,
                kCellObjectDataKey: report,
                kCellClassKey: ReportTableCell.self,
                kCellHeightKey: ReportTableCell.height
            ])
        }
        
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _tableView.loadData(cellSectionData)
    }

    @IBAction func _handleCloseEvent(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func _handleSubmitEvent(_ sender: UIButton) {
        guard let selectedIndex = selectedIndex else {
            alert(message: "please_select_reason_to_report".localized())
            return
        }
        
        guard !Utils.stringIsNullOrEmpty(_text) else {
            alert(message: "please_enter_message_to_report".localized())
            return
        }

        
        if _reportList[selectedIndex] == "Other", Utils.stringIsNullOrEmpty(_reportList[selectedIndex]) {
            alert(message: "please_select_reason_to_report".localized())
            return
        }
        let text = type == "both" ? "you_sure_you_want_to_block_and_report".localized() + "\(userTitle)?" : "are_you_sure_you_want_to_report".localized() + "\(userTitle)?"
        alert(title: kAppName, message: text, okActionTitle: "yes".localized()) { UIAlertAction in
            self.dismiss(animated: true) {
                self.dismissAllPresentedControllers(animated: true)
                self.didUpdateCallback?(self.type, self._reportList[selectedIndex], self._text)
            }
        } cancelHandler: { UIAlertAction in
            self.dismiss(animated: true)
        }

        
    }
}

extension ReportBottomSheet: CustomNoKeyboardTableViewDelegate {
    func setupCell(_ cell: UITableViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? ReportTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? String else { return }
            let isSelected = indexPath.row == selectedIndex
            cell.setup(object,msgTxt: _text, isSelected: isSelected)
            cell.updateCallBack = { [weak self] text in
                guard let self = self else { return }
                self._text = text
            }
        }
    }
    
    func didSelectTableCell(_ cell: UITableViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        selectedIndex = indexPath.row
        _tableView.reloadData()
    }
    
}


extension ReportBottomSheet: PanModalPresentable {
    
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
