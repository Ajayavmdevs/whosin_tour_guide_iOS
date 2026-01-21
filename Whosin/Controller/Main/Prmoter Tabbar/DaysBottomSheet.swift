import UIKit

protocol SelectDaysDelegate: AnyObject {
    func selectDay(_ days: [String])
}

class DaysBottomSheet: PanBaseViewController {

    @IBOutlet weak var _selectAllButton: CustomButton!
    weak var delegate: SelectDaysDelegate?
    @IBOutlet weak var _tableView: CustomNoKeyboardTableView!
    @IBOutlet weak var _titleText: UILabel!
    private let kCellIdentifier = String(describing: WeekdaysTableCell.self)
    private var _selectedIndexes: Set<Int> = []
    public var selectedDays: [String] = [] {
            didSet {
                _selectedIndexes = Set(selectedDays.compactMap { weekdays.firstIndex(of: $0.capitalized) })
            }
        }
    private let weekdayIndex = Calendar.current.component(.weekday, from: Date()) - 1
    public var weekdays: [String] = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    public var titleTxt: String = kEmptyString

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // --------------------------------------
    // MARK: SetUp
    // --------------------------------------
    
    private func setupUI() {
        _titleText.text = "select_days".localized()
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
        
        weekdays.forEach { days in
            cellData.append([
                kCellIdentifierKey: kCellIdentifier,
                kCellTagKey: kCellIdentifier,
                kCellObjectDataKey: days,
                kCellClassKey: WeekdaysTableCell.self,
                kCellHeightKey: WeekdaysTableCell.height
            ])
        }
        
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _tableView.loadData(cellSectionData)
    }
    
    private var _prototypes: [[String: Any]]? {
        return [ [kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: String(describing: WeekdaysTableCell.self), kCellClassKey: WeekdaysTableCell.self, kCellHeightKey: WeekdaysTableCell.height]]
    }

    @IBAction func _handleDoneEvent(_ sender: Any) {
        delegate?.selectDay(selectedDays)
        dismiss(animated: true)
    }
        
    @IBAction func _handleCloseEvent(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func _handleSelectAllEvent(_ sender: Any) {
        if _selectedIndexes.count == weekdays.count {
            _selectedIndexes.removeAll()
        } else {
            _selectedIndexes = Set(0..<weekdays.count)
        }
        
        selectedDays = _selectedIndexes.map { weekdays[$0].lowercased() }
        _tableView.reloadData()
        
        updateSelectAllButtonTitle()
    }
    
    private func updateSelectAllButtonTitle() {
        if _selectedIndexes.count == weekdays.count {
            _selectAllButton.setTitle("deselect_all".localized(), for: .normal)
        } else {
            _selectAllButton.setTitle("select_all".localized(), for: .normal)
        }
    }
}


extension DaysBottomSheet: CustomNoKeyboardTableViewDelegate {
    
    // --------------------------------------
    // MARK: <CustomTableViewDelegate>
    // --------------------------------------
    
    func setupCell(_ cell: UITableViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? WeekdaysTableCell {
            if let object = cellDict?[kCellObjectDataKey] as? String {
                let isSelected = _selectedIndexes.contains(indexPath.row)
                cell.setupData(object, isSelected: isSelected)
            }
        }
    }
    
    func didSelectTableCell(_ cell: UITableViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        if _selectedIndexes.contains(indexPath.row) {
            _selectedIndexes.remove(indexPath.row)
        } else {
            _selectedIndexes.insert(indexPath.row)
        }
        selectedDays = _selectedIndexes.map { weekdays[$0].lowercased() }
        _tableView.reloadData()
    }
    
}
