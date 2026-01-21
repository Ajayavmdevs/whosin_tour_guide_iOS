import UIKit
import PanModal
import SnapKit

class CustomAddOnOptionWalletView: UIView {
    
    @IBOutlet weak var _collectionView: CustomNoKeyboardCollectionView!
    @IBOutlet weak var _collectionViewHieghtConstraint: NSLayoutConstraint!
    @IBOutlet weak var _imgArrow: UIImageView!
    private let kCellIdentifier = String(describing: AddOnWalletOptionCell.self)
    private var isExpanded: Bool = true
    private var expandedHeight: CGFloat = 0


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
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func _setupUi() {
        if let view = Bundle.main.loadNibNamed("CustomAddOnOptionWalletView", owner: self, options: nil)?.first as? UIView {
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
        _imgArrow.isHidden = true
    }
    
    private var _prototypes: [[String: Any]]? {
        return [ [kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: String(describing: AddOnWalletOptionCell.self), kCellClassKey: AddOnWalletOptionCell.self, kCellHeightKey: AddOnWalletOptionCell.height] ]
    }
    
    private func _loadData(_ model: [TourDetailsModel]) {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        var height = 0.0
        
        model.forEach { option in
            let itemHeight = AddOnWalletOptionCell.height
            height += itemHeight
            cellData.append([
                kCellIdentifierKey: self.kCellIdentifier,
                kCellTagKey: self.kCellIdentifier,
                kCellObjectDataKey: option,
                kCellClassKey: AddOnWalletOptionCell.self,
                kCellHeightKey: AddOnWalletOptionCell.height
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
    
    private func collapseCollection() {
        _imgArrow.image = UIImage(systemName: "chevron.down")

        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            usingSpringWithDamping: 0.9,
            initialSpringVelocity: 0.3,
            options: [.curveEaseInOut]
        ) {
            self._collectionView.alpha = 0
            self._collectionViewHieghtConstraint.constant = 0
            self.layoutIfNeeded()
        } completion: { _ in
            self._collectionView.isHidden = true
        }
    }

    private func expandCollection() {
        _collectionView.isHidden = false
        _imgArrow.image = UIImage(systemName: "chevron.up")

        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            usingSpringWithDamping: 0.9,
            initialSpringVelocity: 0.3,
            options: [.curveEaseInOut]
        ) {
            self._collectionView.alpha = 1
            self._collectionViewHieghtConstraint.constant = self.expandedHeight
            self.layoutIfNeeded()
        }
    }

    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setupData(model: [TourDetailsModel]) {
        _loadData(model)
    }
    
    @IBAction func _handleToggleEvent(_ sender: UIButton) {
//        isExpanded.toggle()
//
//        if isExpanded {
//            expandCollection()
//        } else {
//            collapseCollection()
//        }
    }
}

extension CustomAddOnOptionWalletView: CustomNoKeyboardCollectionViewDelegate {
    
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let cell = cell as? AddOnWalletOptionCell ,let object = cellDict?[kCellObjectDataKey] as? TourDetailsModel else { return }
        cell.setupData(object)
        
    }
    
    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: AddOnWalletOptionCell.height)
    }

    
}

