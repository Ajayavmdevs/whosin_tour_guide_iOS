import UIKit
import SnapKit

class CustomRequirementView: UIView {
    
    @IBOutlet weak var _titleText: CustomLabel!
    @IBOutlet weak var _iconView: UIImageView!
    @IBOutlet weak var _collectionHight: NSLayoutConstraint!
    @IBOutlet weak var _customCollectionView: CustomCollectionView!
    private let kCellIdentifier = String(describing: RequirementCollectionCell.self)
    private var arrayList: [String] = []
    public var updateCallback: ((_ model: [String], _ type: RequirementType) -> Void)?
    private var type: RequirementType = RequirementType.requirementsAllowed
    private var isAllow: Bool = true
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _setupUi()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        _setupUi()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
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
    
    private func _loadData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        var totalHeight: CGFloat = 0

        _customCollectionView.isHidden = arrayList.isEmpty
        if !arrayList.isEmpty {
            arrayList.forEach { string in
                let cellHeight = string.heightOfString(usingFont: FontBrand.SFsemiboldFont(size: 15), constrainedToWidth: _customCollectionView.frame.width - 28) + 18
                totalHeight += cellHeight < 28 ? 30 : cellHeight
                cellData.append([
                    kCellIdentifierKey: kCellIdentifier,
                    kCellTagKey: isAllow,
                    kCellObjectDataKey: string,
                    kCellClassKey: RequirementCollectionCell.self,
                    kCellHeightKey: RequirementCollectionCell.height
                ])
            }
        }

        _collectionHight.constant = max(totalHeight, 28)
        _customCollectionView.layoutIfNeeded()
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _customCollectionView.loadData(cellSectionData)

    }
    
    private var _prototype: [[String: Any]]? {
        return [[kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: kCellIdentifier, kCellClassKey: RequirementCollectionCell.self, kCellHeightKey: RequirementCollectionCell.height]]
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------

    private func _setupUi() {
        if var view = Bundle.main.loadNibNamed("CustomRequirementView", owner: self, options: nil)?.first as? UIView {
            addSubview(view)
            view.snp.makeConstraints { make in
                make.leading.trailing.top.bottom.equalToSuperview()
            }
        }
    }
    
    public func setupData(_ listArray: [String], titleText: String, isAllow: Bool, type: RequirementType) {
        self.type = type
        self.isAllow = isAllow
        _iconView.image = UIImage(named: isAllow ? "ic_congratulation" : "ic_reject")
        _titleText.text = titleText
        arrayList = listArray
        _loadData()
    }
    
    private func openRequirementSheet(_ text: String = kEmptyString, index: Int = 0, isEdit: Bool = false) {
        guard let parentVC = parentViewController else { return }
        let vc = INIT_CONTROLLER_XIB(RequirementsBottomSheet.self)
        vc.requireTitle = _titleText.text ?? kEmptyString
        vc.requirementText = text
        vc.isEdit = isEdit
        vc.callback = { [weak self] inputText in
            guard let self = self else { return }
            if text.isEmpty {
                self.arrayList.append(inputText)
            } else {
                self.arrayList[index] = inputText
            }
            self.updateCallback?(self.arrayList.isEmpty ? [] : self.arrayList, self.type)
        }
        parentVC.presentAsPanModal(controller: vc)
    }

    @IBAction private func _handleAddmoreEvent(_ sender: UIButton) {
        openRequirementSheet()
    }
    
}

extension CustomRequirementView: CustomCollectionViewDelegate {
    
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? RequirementCollectionCell {
            guard let isAllow = cellDict?[kCellTagKey] as? Bool, let object = cellDict?[kCellObjectDataKey] as? String else { return }
            cell.setup(object, isAllow: isAllow)
            cell.editBtn.tag = indexPath.row
            cell._deleteBtn.tag = indexPath.row
            cell.editBtn.addTarget(self, action: #selector(_editEvent(_:)), for: .touchUpInside)
            cell._deleteBtn.addTarget(self, action: #selector(_deleteEvent(_:)), for: .touchUpInside)

        }
    }
    
    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        guard let object = cellDict?[kCellObjectDataKey] as? String else { return  CGSize(width: 0, height: 0)}
        let cellHeight = object.heightOfString(usingFont: FontBrand.SFsemiboldFont(size: 15), constrainedToWidth: _customCollectionView.frame.width - 28) + 15
        return CGSize(width: collectionView.frame.width - 28, height: cellHeight < 28 ? 28 : cellHeight)
    }
    
    @objc private func _editEvent(_ sender: UIButton) {
        guard sender.tag < arrayList.count else { return }
        openRequirementSheet(arrayList[sender.tag], index: sender.tag, isEdit: true)
    }
    
    @objc private func _deleteEvent(_ sender: UIButton) {
        guard sender.tag < arrayList.count else { return }
        self.parentBaseController?.showCustomAlert(title: kAppName, message: "are_you_sure_remove".localized(), yesButtonTitle: "yes".localized(), noButtonTitle: "no".localized(), okHandler: { UIAlertAction in
            self.arrayList.remove(at: sender.tag)
            self.updateCallback?(self.arrayList, self.type)
        }, noHandler:  { UIAlertAction in
        })
    }
}



