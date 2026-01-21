import UIKit
import PanModal

class BottomSheetVC: BaseViewController {
    
    var optionList: [BottomSheetTupple] = []
    var didSelectCallback: ((BottomSheetTupple) -> Void)?
    
    @IBOutlet private weak var _containerView: UIView!
    @IBOutlet private weak var _tableView: CustomTableView!
    @IBOutlet private weak var _tableViewHeight: NSLayoutConstraint!
    

    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUi()
        _loadData()
    }
    
    override func setupUi() {
        //TABLE VIEW
        _tableView.setup(
            cellPrototypes: _prototypes,
            hasHeaderSection: false,
            hasFooterSection: false,
            isHeaderCollapsible: false,
            isDummyLoad: false,
            enableRefresh: false,
            emptyDataText: nil,
            emptyDataIconImage: nil,
            emptyDataDescription: nil,
            delegate: self)
        _tableView.contentInset = .zero
    }
    
    // --------------------------------------
    // MARK: Data
    // --------------------------------------
    
    private func _loadData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        
        optionList.forEach { option in
            cellData.append([:
            ])
        }
        
        let cancel: BottomSheetTupple = (tag: 0, title: "Cancel", icon: nil)
        cellData.append([
            :        ])
        
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _tableView.loadData(cellSectionData)
        _tableViewHeight.constant =  CGFloat(cellData.count)
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private var _prototypes: [[String: Any]]? {
        return [ [:] ]
    }
}

extension BottomSheetVC: CustomTableViewDelegate {
    
    // --------------------------------------
    // MARK: <CustomTableViewDelegate>
    // --------------------------------------
    
    func setupCell(_ cell: UITableViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
    }
    
    func didSelectTableCell(_ cell: UITableViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let tuple = cellDict?[kCellObjectDataKey] as? BottomSheetTupple else { return }
        
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            if tuple.tag != 0 { self.didSelectCallback?(tuple) }
        }
    }
}
