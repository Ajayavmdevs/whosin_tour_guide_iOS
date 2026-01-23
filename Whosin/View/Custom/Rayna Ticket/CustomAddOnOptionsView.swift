import UIKit
import PanModal
import SnapKit

class CustomAddOnOptionsView: UIView {
    
    @IBOutlet weak var _collectionView: CustomNoKeyboardCollectionView!
    @IBOutlet weak var _collectionViewHieghtConstraint: NSLayoutConstraint!
    @IBOutlet weak var _viewTitle: CustomLabel!
    private let kCellIdentifier = String(describing: AddOnOptionCollectionCell.self)
    private var isExpanded: Bool = true
    private var expandedHeight: CGFloat = 0
    private var optionModel: TourOptionDetailModel?
    private var models: [TourOptionsModel] = []
    public var reloadCallback: (() -> Void)?


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
        layoutIfNeeded()
        layoutMarginsDidChange()
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func _setupUi() {
        if let view = Bundle.main.loadNibNamed("CustomAddOnOptionsView", owner: self, options: nil)?.first as? UIView {
            addSubview(view)
            view.snp.makeConstraints { make in
                make.leading.trailing.top.bottom.equalToSuperview()
            }
        }
        _collectionView.setup(cellPrototypes: _prototypes,
                              hasHeaderSection: false,
                              enableRefresh: false,
                              columns: 1,
                              rows: 5,
                              edgeInsets: .zero,
                              spacing: CGSize(width: 0, height: 0),
                              scrollDirection: .vertical,
                              emptyDataText: nil,
                              emptyDataIconImage: nil,
                              delegate: self)
        _collectionView.showsVerticalScrollIndicator = false
        _collectionView.showsHorizontalScrollIndicator = false
        _collectionView.isUserInteractionEnabled = true
    }
    
    private var _prototypes: [[String: Any]]? {
        return [ [kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: String(describing: AddOnOptionCollectionCell.self), kCellClassKey: AddOnOptionCollectionCell.self, kCellHeightKey: AddOnOptionCollectionCell.height] ]
    }
    
    private func _loadData(_ model: [TourOptionsModel]) {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        var height = 0.0
        
        model.forEach { option in
            let itemHeight = AddOnOptionCollectionCell.height(for: option, selectedOption: optionModel, width: _collectionView.frame.width)
            height += itemHeight
            cellData.append([
                kCellIdentifierKey: self.kCellIdentifier,
                kCellTagKey: self.kCellIdentifier,
                kCellObjectDataKey: option.detached(),
                kCellClassKey: AddOnOptionCollectionCell.self,
                kCellHeightKey: itemHeight
            ])
        }
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        var spacing: CGFloat = 0
        if let layout = _collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            spacing = layout.minimumLineSpacing
        }
        let totalSpacing = model.count > 1 ? spacing * CGFloat(model.count - 1) : 0
        _collectionViewHieghtConstraint.constant = height + 8
        expandedHeight = height + totalSpacing
        
        DispatchQueue.main.async {
            self._collectionView.loadData(cellSectionData)
        }
    }
    
    private func _loadDetailData(_ model: [TourOptionDetailModel]) {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        var height = 0.0
        
        model.forEach { option in
            let itemHeight = AddOnOptionCollectionCell.height(option, width: _collectionView.frame.width)
            height += itemHeight
            cellData.append([
                kCellIdentifierKey: self.kCellIdentifier,
                kCellTagKey: self.kCellIdentifier,
                kCellObjectDataKey: option,
                kCellClassKey: AddOnOptionCollectionCell.self,
                kCellHeightKey: itemHeight
            ])
        }
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        var spacing: CGFloat = 0
        if let layout = _collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            spacing = layout.minimumLineSpacing
        }
        let totalSpacing = model.count > 1 ? spacing * CGFloat(model.count - 1) : 0
        _collectionViewHieghtConstraint.constant = height + totalSpacing
        expandedHeight = height + totalSpacing
        
        DispatchQueue.main.async {
            self._collectionView.loadData(cellSectionData)
        }
    }
    
    private func _loadWalletData(_ model: [TourDetailsModel]) {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        var height = 0.0
        
        model.forEach { option in
            let itemHeight = AddOnOptionCollectionCell.height(option, width: _collectionView.frame.width)
            height += itemHeight
            cellData.append([
                kCellIdentifierKey: self.kCellIdentifier,
                kCellTagKey: self.kCellIdentifier,
                kCellObjectDataKey: option,
                kCellClassKey: AddOnOptionCollectionCell.self,
                kCellHeightKey: itemHeight
            ])
        }
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        var spacing: CGFloat = 0
        if let layout = _collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            spacing = layout.minimumLineSpacing
        }
        let totalSpacing = model.count > 1 ? spacing * CGFloat(model.count - 1) : 0
        _collectionViewHieghtConstraint.constant = height + totalSpacing
        expandedHeight = height + totalSpacing
        
//        DispatchQueue.main.async {
            self._collectionView.loadData(cellSectionData)
//        }
    }

    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setupData(model: [TourOptionsModel],_ optionModel: TourOptionDetailModel?) {
        _viewTitle.text = "Customize your ticket"
        self.optionModel = optionModel
        self.models = model
        _loadData(model)
    }
    
    public func setupData(model: [TourOptionDetailModel]) {
        _viewTitle.text = "Add-ons"
        _loadDetailData(model)
    }
    
    public func setupWalletData(model: [TourDetailsModel]) {
        _viewTitle.text = "Add-ons"
        _loadWalletData(model)
    }

}

extension CustomAddOnOptionsView: CustomNoKeyboardCollectionViewDelegate {
    
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? AddOnOptionCollectionCell ,let object = cellDict?[kCellObjectDataKey] as? TourOptionsModel {
            cell.setupData(object, selectedOption: optionModel)
        } else if let cell = cell as? AddOnOptionCollectionCell, let object = cellDict?[kCellObjectDataKey] as? TourOptionDetailModel {
            cell.setupData(object)
        } else if let cell = cell as? AddOnOptionCollectionCell, let object = cellDict?[kCellObjectDataKey] as? TourDetailsModel {
            cell.setupData(object)
        }
    }
    
    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        if let object = cellDict?[kCellObjectDataKey] as? TourOptionsModel {
            let h = AddOnOptionCollectionCell.height(for: object, selectedOption: optionModel, width: collectionView.frame.width)
            return CGSize(width: collectionView.frame.width, height: h)
        } else if let object = cellDict?[kCellObjectDataKey] as? TourOptionDetailModel {
            let h = AddOnOptionCollectionCell.height(object, width: _collectionView.frame.width)
            return CGSize(width: collectionView.frame.width, height: h)
        } else if let object = cellDict?[kCellObjectDataKey] as? TourDetailsModel {
            let h = AddOnOptionCollectionCell.height(object, width: _collectionView.frame.width)
            return CGSize(width: collectionView.frame.width, height: h)
        }
        return CGSize(width: collectionView.frame.width, height: AddOnOptionCollectionCell.height)
    }
    
    
    func didSelectCell(_ cell: UICollectionViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let object = cellDict?[kCellObjectDataKey] as? TourOptionsModel else { return }
        guard !Utils.stringIsNullOrEmpty(optionModel?.tourDate) else {
            parentBaseController?.alert(message: "Please choose your ticket first")
            return
        }
        let vc = INIT_CONTROLLER_XIB(AddOptionSelectPaxSheet.self)
        vc.optionDetail = self.optionModel
        vc.addOnOption = object
        vc.reloadCallback = { [weak self] in
            guard let self = self else { return }
            self._loadData(self.models)
            self.reloadCallback?()
        }
        self.parentViewController?.presentAsPanModal(controller: vc)
    }
    
}

