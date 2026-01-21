import UIKit

class DealsFeaturesCell: UITableViewCell {
    
    @IBOutlet private weak var _collectionView: CustomCollectionView!
    @IBOutlet private weak var _collectionViewHieghtConstraint: NSLayoutConstraint!
    @IBOutlet weak var _expiredView: UIView!
    @IBOutlet weak var _buyNowView: UIView!
    private let kCellIdentifier = String(describing: ActivityListCollectionCell.self)
    private var _dealsModel: DealsModel?
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat { UITableView.automaticDimension }
    
    // --------------------------------------
    // MARK: Life cycle
    // --------------------------------------
    
    override func awakeFromNib() {
        super.awakeFromNib()
        _setupUi()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func _setupUi() {
        disableSelectEffect()
        //TABLE VIEW
        _collectionView.setup(cellPrototypes: _prototypes,
                              hasHeaderSection: false,
                              enableRefresh: false,
                              columns: 2,
                              rows: 5,
                              scrollDirection: .vertical,
                              emptyDataText: nil,
                              emptyDataIconImage: nil,
                              delegate: self)
        _collectionView.showsVerticalScrollIndicator = false
        _collectionView.showsHorizontalScrollIndicator = false
    }
    
    private var _prototypes: [[String: Any]]? {
        return [ [kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: kCellIdentifier, kCellClassKey: ActivityListCollectionCell.self, kCellHeightKey: ActivityListCollectionCell.height]]
    }
    
    private func _loadDealsData(_ model: DealsModel?) {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        guard let features = model?.features else { return }
        if !features.isEmpty {
            features.forEach({ data in
                cellData.append([
                    kCellIdentifierKey: kCellIdentifier,
                    kCellTagKey: kCellIdentifier,
                    kCellObjectDataKey: data,
                    kCellClassKey: ActivityListCollectionCell.self,
                    kCellHeightKey: ActivityListCollectionCell.height
                ])
            })
        }
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _collectionView.loadData(cellSectionData)
        _collectionViewHieghtConstraint.constant = 18 * CGFloat(cellData.count)
    }
    
    public func setupDealsData(_ model: DealsModel) {
        _dealsModel = model
        _expiredView.isHidden = model._isExpired ? false : true
        _buyNowView.isHidden = model._isExpired ? true : model.isZeroPrice
        _loadDealsData(model)
    }
    
    @IBAction private func _handleBuyNowEvent(_ sender: UIButton) {
        parentBaseController?.feedbackGenerator?.impactOccurred()
        let controller = INIT_CONTROLLER_XIB(BuyPackgeVC.self)
        controller.dealsId = _dealsModel?.id ?? ""
        controller.dealsModel = _dealsModel
        controller.modalPresentationStyle = .overFullScreen
        controller.setCallback {
            let controller = INIT_CONTROLLER_XIB(MyCartVC.self)
            controller.modalPresentationStyle = .overFullScreen
            self.parentViewController?.navigationController?.pushViewController(controller, animated: true)
        }
        parentViewController?.navigationController?.pushViewController(controller, animated: true)
    }
    
}


extension DealsFeaturesCell: CustomCollectionViewDelegate {
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? ActivityListCollectionCell {
            if let object = cellDict?[kCellObjectDataKey] as? CommonSettingsModel {
                cell.setupDealsData(object)
            }
        }
    }
    
    
    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width / 2, height: ActivityListCollectionCell.height)
    }
}
