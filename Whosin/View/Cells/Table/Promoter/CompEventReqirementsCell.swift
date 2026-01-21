import UIKit

class CompEventReqirementsCell: UITableViewCell {

    @IBOutlet weak var _titleLabel: CustomLabel!
    @IBOutlet weak var _collectionHight: NSLayoutConstraint!
    @IBOutlet weak var _customCollectionView: CustomCollectionView!
    private let kCellIdentifier = String(describing: RequirementCollectionCell.self)

    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat { UITableView.automaticDimension }

    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
        disableSelectEffect()
        _setupCollectionView()
    }

    private func _setupCollectionView() {
        _customCollectionView.setup(cellPrototypes: _prototype,
                              hasHeaderSection: false,
                              enableRefresh: false,
                              columns: 1,
                              rows: 1,
                              scrollDirection: .vertical,
                              emptyDataText: "There is no data available",
                              emptyDataIconImage: UIImage(named: "empty_following"),
                              delegate: self)
        _customCollectionView.showsVerticalScrollIndicator = false
        _customCollectionView.showsHorizontalScrollIndicator = false
    }
    
    private func _loadData(_ event: PromoterEventsModel, title: String) {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        var totalHeight: CGFloat = 0

        if title == "Requirements" {
            if !event.requirementsAllowed.isEmpty {
                event.requirementsAllowed.forEach { string in
                    let cellHeight = string.heightOfString(usingFont: FontBrand.SFsemiboldFont(size: 17), constrainedToWidth: _customCollectionView.frame.width - 30)
                    totalHeight +=  cellHeight < 35 ? 40 : cellHeight
                    cellData.append([
                        kCellIdentifierKey: kCellIdentifier,
                        kCellTagKey: true,
                        kCellObjectDataKey: string,
                        kCellClassKey: RequirementCollectionCell.self,
                        kCellHeightKey: RequirementCollectionCell.height
                    ])
                }
            }
            
            if !event.requirementsNotAllowed.isEmpty {
                event.requirementsNotAllowed.forEach { string in
                    let cellHeight = string.heightOfString(usingFont: FontBrand.SFsemiboldFont(size: 17), constrainedToWidth: _customCollectionView.frame.width - 30)
                    totalHeight +=  cellHeight < 40 ? 35 : cellHeight
                    cellData.append([
                        kCellIdentifierKey: kCellIdentifier,
                        kCellTagKey: false,
                        kCellObjectDataKey: string,
                        kCellClassKey: RequirementCollectionCell.self,
                        kCellHeightKey: RequirementCollectionCell.height
                    ])
                }
            }
        } else {
            if !event.benefitsIncluded.isEmpty {
                event.benefitsIncluded.forEach { string in
                    let cellHeight = string.heightOfString(usingFont: FontBrand.SFsemiboldFont(size: 17), constrainedToWidth: _customCollectionView.frame.width - 30)
                    totalHeight +=  cellHeight < 35 ? 35 : cellHeight
                    cellData.append([
                        kCellIdentifierKey: kCellIdentifier,
                        kCellTagKey: true,
                        kCellObjectDataKey: string,
                        kCellClassKey: RequirementCollectionCell.self,
                        kCellHeightKey: RequirementCollectionCell.height
                    ])
                }
            }
            
            if !event.benefitsNotIncluded.isEmpty {
                event.benefitsNotIncluded.forEach { string in
                    let cellHeight = string.heightOfString(usingFont: FontBrand.SFsemiboldFont(size: 17), constrainedToWidth: _customCollectionView.frame.width - 30)
                    totalHeight +=  cellHeight < 35 ? 35 : cellHeight
                    cellData.append([
                        kCellIdentifierKey: kCellIdentifier,
                        kCellTagKey: false,
                        kCellObjectDataKey: string,
                        kCellClassKey: RequirementCollectionCell.self,
                        kCellHeightKey: RequirementCollectionCell.height
                    ])
                }
            }
        }
        
        _collectionHight.constant = totalHeight
        _customCollectionView.layoutIfNeeded()
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _customCollectionView.loadData(cellSectionData)

    }
    
    
    private var _prototype: [[String: Any]]? {
        return [[kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: kCellIdentifier, kCellClassKey: RequirementCollectionCell.self, kCellHeightKey: RequirementCollectionCell.height]]
    }
    
    public func setupData(_ listArray: [String], titleText: String, isAllow: Bool) {
        _titleLabel.text = titleText.lowercased().localized()
    }
    
    public func setupData(_ model: PromoterEventsModel, titleText: String) {
        _titleLabel.text = titleText.lowercased().localized()
        _loadData(model, title: titleText)
    }
}

extension CompEventReqirementsCell: CustomCollectionViewDelegate {
    
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? RequirementCollectionCell {
            guard let isAllow = cellDict?[kCellTagKey] as? Bool, let object = cellDict?[kCellObjectDataKey] as? String else { return }
            cell.editBtn.isHidden = true
            cell._deleteBtn.isHidden = true
            cell.setup(object, isAllow: isAllow)
        }
    }
    
    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        guard let object = cellDict?[kCellObjectDataKey] as? String else { return  CGSize(width: 0, height: 0)}
        let cellHeight = object.heightOfString(usingFont: FontBrand.SFsemiboldFont(size: 17), constrainedToWidth: _customCollectionView.frame.width - 30)
        return CGSize(width: collectionView.frame.width - 30, height: cellHeight < 35 ? 35 : cellHeight)
    }
    
}
