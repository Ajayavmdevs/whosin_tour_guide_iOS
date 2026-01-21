import UIKit

class AllUserSearchTableCell: UITableViewCell {
    
    weak var delegate: ShowCategoryDetailsDelegate?
    @IBOutlet weak var _titleLabel: UILabel!
    @IBOutlet private weak var _collectionView: CustomNoKeyboardCollectionView!
    @IBOutlet weak var _collectionHeight: NSLayoutConstraint!
    private let kCellIdentifierUser = String(describing: UserCollectionCell.self)
    private var _userModel: [UserDetailModel] = []
    
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat {
        UITableView.automaticDimension
    }
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUi(4)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func setupUi(_ row: Int) {
        let spacing = 0
        _collectionView.setup(cellPrototypes: _prototypes,
                              hasHeaderSection: false,
                              enableRefresh: false,
                              columns: 1.1,
                              rows: row,
                              edgeInsets: UIEdgeInsets(top: .zero, left: 0, bottom: .zero, right: 0),
                              spacing: CGSize(width: spacing, height: spacing),
                              scrollDirection: .horizontal,
                              emptyDataText: nil,
                              emptyDataIconImage: nil,
                              delegate: self)
        _collectionView.showsVerticalScrollIndicator = false
        _collectionView.showsHorizontalScrollIndicator = false
        _collectionHeight.constant = CGFloat(row < 4 ? row * 65 : 260)
        _collectionView.reload()
    }
    
    private func _loadData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        
        _userModel.forEach { user in
            cellData.append([
                kCellIdentifierKey: kCellIdentifierUser,
                kCellTagKey: kCellIdentifierUser,
                kCellObjectDataKey: user,
                kCellClassKey: UserCollectionCell.self,
                kCellHeightKey: UserCollectionCell.height
            ])
        }
        
        
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _collectionView.loadData(cellSectionData)
    }
    
    private var _prototypes: [[String: Any]]? {
        return [ [kCellIdentifierKey: kCellIdentifierUser, kCellNibNameKey: String(describing: UserCollectionCell.self), kCellClassKey: UserCollectionCell.self, kCellHeightKey: UserCollectionCell.height]]
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setupData(_ data: [UserDetailModel]) {
        setupUi(data.count < 4 ? data.count : 4)
        _userModel = data
        _loadData()
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    @IBAction func _handleMoreEvent(_ sender: UIButton) {
        delegate?.didSelectCategory("user")
    }
    
}

// --------------------------------------
// MARK: Custom Collection View
// --------------------------------------

extension AllUserSearchTableCell: CustomNoKeyboardCollectionViewDelegate {
    
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? UserCollectionCell {
            guard let object = cellDict?[kCellObjectDataKey] as? UserDetailModel else { return }
            cell.setup(object)
        }
    }
    
    func didSelectCell(_ cell: UICollectionViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let object = cellDict?[kCellObjectDataKey] as? UserDetailModel else { return }
        guard let userDetail = APPSESSION.userDetail else { return }
        if object.id != userDetail.id {
            APPSETTING.addSearchHistory(id: object.id, title: object.fullName, subtitle: object.email, type: "user", image: object.image)
            if object.isPromoter, userDetail.isRingMember {
                let vc = INIT_CONTROLLER_XIB(PromoterPublicProfileVc.self)
                vc.promoterId = object.id
                vc.isFromPersonal = true
                parentViewController?.navigationController?.pushViewController(vc, animated: true)
            } else if object.isRingMember, userDetail.isPromoter {
                let vc = INIT_CONTROLLER_XIB(ComplementaryPublicProfileVC.self)
                vc.complimentryId = object.id
                vc.isFromPersonal = true
                parentViewController?.navigationController?.pushViewController(vc, animated: true)
            } else {
                let controller = INIT_CONTROLLER_XIB(UsersProfileVC.self)
                controller.contactId = object.id
                self.parentViewController?.navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
}

