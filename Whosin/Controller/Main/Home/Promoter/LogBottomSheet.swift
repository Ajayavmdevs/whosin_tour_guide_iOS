import UIKit

class LogBottomSheet: ChildViewController {

    @IBOutlet weak var _tableView: CustomNoKeyboardTableView!
    @IBOutlet weak var _visualEffectView: UIVisualEffectView!
    private var kCellIdentifier = String(describing: BottomSheetTableCell.self)
    public var logsList: [LogsModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapOnVisualEffectView))
        _visualEffectView.addGestureRecognizer(tapGesture)
        _visualEffectView.isUserInteractionEnabled = true

    }

    // --------------------------------------
    // MARK: SetUp
    // --------------------------------------
    
    private func setupUI() {
        _tableView.setup(
            cellPrototypes: _prototypes,
            hasHeaderSection: false,
            hasFooterSection: false,
            isHeaderCollapsible: false,
            isDummyLoad: false,
            enableRefresh: false,
            emptyDataText: kEmptyString,
            emptyDataIconImage: nil,
            emptyDataDescription: kEmptyString,
            delegate: self)
        _loadData()
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func _loadData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        
        logsList.forEach { logs in
            cellData.append([
                kCellIdentifierKey: kCellIdentifier,
                kCellTagKey: kCellIdentifier,
                kCellObjectDataKey: logs,
                kCellClassKey: BottomSheetTableCell.self,
                kCellHeightKey: BottomSheetTableCell.height
            ])
        }
        
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _tableView.loadData(cellSectionData)
    }
    
    private var _prototypes: [[String: Any]]? {
        return [ [kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: String(describing: BottomSheetTableCell.self), kCellClassKey: BottomSheetTableCell.self, kCellHeightKey: BottomSheetTableCell.height]]
    }
        
    @IBAction func _handleCloseEvent(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @objc private func handleTapOnVisualEffectView() {
        dismiss(animated: true)
    }


}

extension LogBottomSheet: CustomNoKeyboardTableViewDelegate {
    
    // --------------------------------------
    // MARK: <CustomTableViewDelegate>
    // --------------------------------------
    
    func setupCell(_ cell: UITableViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let cell = cell as? BottomSheetTableCell,
              let model = cellDict?[kCellObjectDataKey] as? LogsModel else { return }
        cell.setupLogs(model)
    }

    
}
