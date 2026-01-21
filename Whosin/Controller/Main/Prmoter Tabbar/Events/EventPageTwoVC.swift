import UIKit

class EventPageTwoVC: ChildViewController {

    @IBOutlet weak var _tableView: CustomNoKeyboardTableView!
    private let kCellIdentifiereRequirement = String(describing: RequirementTableCell.self)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUi()
    }

    
    override func setupUi() {
        _tableView.setup(
            cellPrototypes: _prototype,
            hasHeaderSection: false,
            hasFooterSection: false,
            isHeaderCollapsible: false,
            isDummyLoad: false,
            enableRefresh: false,
            isShowRefreshing: false,
            emptyDataText: "empty_promoter_detail".localized(),
            emptyDataIconImage: UIImage(named: "empty_explore"),
            emptyDataDescription: nil,
            delegate: self)
        _loadData()
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------

    private var _prototype: [[String: Any]]? {
        return [
            [kCellIdentifierKey: kCellIdentifiereRequirement, kCellNibNameKey: kCellIdentifiereRequirement, kCellClassKey: RequirementTableCell.self, kCellHeightKey: RequirementTableCell.height]
        ]
    }
    
    private func _loadData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        
        cellData.append([
            kCellIdentifierKey: kCellIdentifiereRequirement,
            kCellTagKey: true,
            kCellObjectDataKey: PromoterCreateEventVC.eventParams["requirementsAllowed"] as? [String] ?? [],
            kCellTitleKey: RequirementType.requirementsAllowed.rawValue,
            kCellClassKey: RequirementTableCell.self,
            kCellHeightKey: RequirementTableCell.height
        ])
        
        cellData.append([
            kCellIdentifierKey: kCellIdentifiereRequirement,
            kCellTagKey: false,
            kCellObjectDataKey: PromoterCreateEventVC.eventParams["requirementsNotAllowed"] as? [String] ?? [],
            kCellTitleKey: RequirementType.requirementsNotAllowed.rawValue,
            kCellClassKey: RequirementTableCell.self,
            kCellHeightKey: RequirementTableCell.height
        ])
        
        cellData.append([
            kCellIdentifierKey: kCellIdentifiereRequirement,
            kCellTagKey: true,
            kCellObjectDataKey: PromoterCreateEventVC.eventParams["benefitsIncluded"] as? [String] ?? [],
            kCellTitleKey: RequirementType.benefitsIncluded.rawValue,
            kCellClassKey: RequirementTableCell.self,
            kCellHeightKey: RequirementTableCell.height
        ])
        
        cellData.append([
            kCellIdentifierKey: kCellIdentifiereRequirement,
            kCellTagKey: false,
            kCellTitleKey: RequirementType.benefitsNotIncluded.rawValue,
            kCellObjectDataKey: PromoterCreateEventVC.eventParams["benefitsNotIncluded"] as? [String] ?? [],
            kCellClassKey: RequirementTableCell.self,
            kCellHeightKey: RequirementTableCell.height
        ])
        
        if cellData.count != .zero {
            cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        }
        _tableView.loadData(cellSectionData)
        
    }
    
        private func appendDataByType(_ type: RequirementType, data: [String]) {
            switch type {
            case .requirementsAllowed:
                PromoterCreateEventVC.eventParams["requirementsAllowed"] = data
            case .requirementsNotAllowed:
                PromoterCreateEventVC.eventParams["requirementsNotAllowed"] = data
            case .benefitsIncluded:
                PromoterCreateEventVC.eventParams["benefitsIncluded"] = data
            case .benefitsNotIncluded:
                PromoterCreateEventVC.eventParams["benefitsNotIncluded"] = data
            }
            _loadData()
        }
}

extension EventPageTwoVC: CustomNoKeyboardTableViewDelegate {
    func setupCell(_ cell: UITableViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? RequirementTableCell {
            guard let title = cellDict?[kCellTitleKey] as? String else { return }
            guard let isAllow = cellDict?[kCellTagKey] as? Bool else { return }
            guard let object = cellDict?[kCellObjectDataKey] as? [String] else { return }
            cell.setupData(title, isAllow: isAllow, list: object)
            cell.callback = { list, type in
                self.appendDataByType(type, data: list)
            }
        }
    }
}

