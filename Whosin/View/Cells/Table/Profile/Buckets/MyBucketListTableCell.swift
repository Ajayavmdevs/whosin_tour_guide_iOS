import UIKit

class MyBucketListTableCell: UITableViewCell {

    @IBOutlet weak var _collectionView: CustomNoKeyboardCollectionView!
//    private let kCellIdentifier = String(describing: BucketListCollectionCell.self)
    private var _bucketList: [BucketDetailModel] = []

    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    static var height: CGFloat { UITableView.automaticDimension }

    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUi()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func setupUi() {

        _collectionView.showsVerticalScrollIndicator = false
        _collectionView.showsHorizontalScrollIndicator = false
    }


    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func _loadColletionData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        
//        _bucketList.forEach { list in
//            cellData.append([
//                kCellIdentifierKey: kCellIdentifier,
//                kCellTagKey: kCellIdentifier,
//                kCellObjectDataKey: list,
//                kCellClassKey: BucketListCollectionCell.self,
//                kCellHeightKey: BucketListCollectionCell.height
//            ])
//        }
        
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _collectionView.loadData(cellSectionData)
    }
    
//    private var _collectionPrototype: [[String: Any]]? {
//        return [
//            [kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: String(describing: BucketListCollectionCell.self), kCellClassKey: BucketListCollectionCell.self, kCellHeightKey: BucketListCollectionCell.height]
//        ]
//    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setupData(_ data: [BucketDetailModel]) {
        _bucketList = data
        _loadColletionData()
    }
    
    // --------------------------------------
    // MARK: Events
    // --------------------------------------

    @IBAction private func _handleCreateBucketEvent(_ sender: UIButton) {
        let presentedViewController = INIT_CONTROLLER_XIB(CreateBucketBottomSheet.self)
//        presentedViewController.modalPresentationStyle = .custom
//        presentedViewController.transitioningDelegate = self
        parentViewController?.presentAsPanModal(controller: presentedViewController)
    }
    
    
}

extension MyBucketListTableCell: CustomNoKeyboardCollectionViewDelegate {
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
//        if let cell = cell as? BucketListCollectionCell {
//            guard let object = cellDict?[kCellObjectDataKey] as? BucketDetailModel else { return }
//            cell.setupData(object, userModel: APPSETTING.users ?? [])
//        }
    }
    
    func didSelectCell(_ cell: UICollectionViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
//        if cell is BucketListCollectionCell {
//            guard let object = cellDict?[kCellObjectDataKey] as? BucketDetailModel else { return }
//            let destinationViewController = INIT_CONTROLLER_XIB(BucketDetailVC.self)
//            destinationViewController.bucketDetail = object
//            destinationViewController.bucketId = object.id
//            let navigationController = UINavigationController(rootViewController: destinationViewController)
//            navigationController.modalPresentationStyle = .overFullScreen
//            self.parentViewController?.present(navigationController, animated: true, completion: nil)
//        }
    }
}

extension MyBucketListTableCell: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return CustomBottomSheet(presentedViewController: presented, presenting: presenting)
    }
}
