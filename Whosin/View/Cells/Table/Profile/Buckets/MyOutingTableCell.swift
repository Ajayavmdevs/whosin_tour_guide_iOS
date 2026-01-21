import UIKit

class MyOutingTableCell: UITableViewCell {
    
    @IBOutlet private weak var _collectionView: CustomNoKeyboardCollectionView!
    @IBOutlet private weak var _titleLbl: UILabel!
    @IBOutlet private weak var _subTitleLbl: UILabel!
    @IBOutlet weak var _emptyImg: UIImageView!
    @IBOutlet weak var _emptyText: UILabel!
    private var isOneRecord: Bool = false
    private let kCellIdentifierStory = String(describing: OutingCollectionCell.self)
    var _outingList: [OutingListModel] = []
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    static var height: CGFloat { UITableView.automaticDimension }
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func awakeFromNib() {
        super.awakeFromNib()
        disableSelectEffect()
        setupUi()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    func setupUi() {
        disableSelectEffect()
        _collectionView.setup(cellPrototypes: _storyPrototype,
                              hasHeaderSection: false,
                              enableRefresh: false,
                              columns: isOneRecord ? 1 : 1.1,
                              rows: 1,
                              edgeInsets: UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 14),
                              spacing: CGSize(width: 10, height: 10),
                              scrollDirection: .horizontal,
                              emptyDataText: nil,
                              emptyDataIconImage: nil,
                              delegate: self)
        _collectionView.showsVerticalScrollIndicator = false
        _collectionView.showsHorizontalScrollIndicator = false
    }
    
    private var _storyPrototype: [[String: Any]]? {
        return [[kCellIdentifierKey: kCellIdentifierStory, kCellNibNameKey: kCellIdentifierStory, kCellClassKey: OutingCollectionCell.self, kCellHeightKey: OutingCollectionCell.height]]
    }
    
    private func _loadData() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            var cellSectionData = [[String: Any]]()
            var cellData = [[String: Any]]()
            
            if self._outingList.isEmpty {
                DispatchQueue.main.async {
                    self._emptyImg.isHidden = false
                    self._emptyText.isHidden = false
                }
            } else {
                self._outingList.forEach { model in
                    if model.owner != nil {
                        cellData.append([
                            kCellIdentifierKey: self.kCellIdentifierStory,
                            kCellTagKey: model.id,
                            kCellObjectDataKey: model,
                            kCellClassKey: OutingCollectionCell.self,
                            kCellHeightKey: OutingCollectionCell.height
                        ])
                    }
                }
                DispatchQueue.main.async {
                    self._emptyImg.isHidden = true
                    self._emptyText.isHidden = true
                }
            }
            
            cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
            DispatchQueue.main.async {
                self._collectionView.loadData(cellSectionData)
            }
        }
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setupData(_ model: [OutingListModel],_ title:String, subTitle:String = kEmptyString) {
        isOneRecord = model.count == 1
        _titleLbl.text = title
        _subTitleLbl.text = subTitle
        _subTitleLbl.isHidden = subTitle.isEmpty
        _outingList = model
        _loadData()
    }
    
    // --------------------------------------
    // MARK: Events
    // --------------------------------------
    
    @IBAction private  func _handleSeeAllEvent(_ sender: UIButton) {
        let controller = INIT_CONTROLLER_XIB(SeeAllOutingListVC.self)
        controller.modalPresentationStyle = .overFullScreen
        parentViewController?.navigationController?.pushViewController(controller, animated: true) //present(controller, animated: true)
    }
    
}

extension MyOutingTableCell: CustomNoKeyboardCollectionViewDelegate {
    
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let cell = cell as? OutingCollectionCell else { return }
        if let object = cellDict?[kCellObjectDataKey] as? OutingListModel {
            cell.setupData(object)
        }
    }
    
    func didSelectCell(_ cell: UICollectionViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        if cell is OutingCollectionCell {
            guard let object = cellDict?[kCellObjectDataKey] as? OutingListModel else { return }
            let controller = INIT_CONTROLLER_XIB(OutingDetailVC.self)
            controller.outingId = object.id
            parentViewController?.navigationController?.pushViewController(controller, animated: true)
            // TODO: kReloadBucketList for check
            //NotificationCenter.default.post(name:kReloadBucketList, object: nil, userInfo: nil)
        }

    }
    
}
