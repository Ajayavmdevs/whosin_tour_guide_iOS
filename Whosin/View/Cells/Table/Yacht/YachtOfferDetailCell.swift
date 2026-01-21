import UIKit

class YachtOfferDetailCell: UITableViewCell {

    
//    @IBOutlet weak var _customGallryView: CustomGallaryView!
    @IBOutlet weak var _priceview: GradientView!
    @IBOutlet weak var _priceText: UILabel!
    @IBOutlet weak var _colleciton: CustomNoKeyboardCollectionView!
    @IBOutlet weak var _pageControl: CustomPageControll!
    private let kCellIdentifier = String(describing: ImageViewCell.self)
    private var _gallaryArray: [String] = []
    var currentPage = 0


    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    static var height: CGFloat { UITableView.automaticDimension }

    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
        _setupUi()
        DISPATCH_ASYNC_MAIN_AFTER(0.02) {
            self._priceview.roundCorners(corners: [.bottomLeft, .topRight], radius: 15)
        }
    }
    
    private func _setupUi() {
        _colleciton.setup(cellPrototypes: _prototype,
                              hasHeaderSection: false,
                              enableRefresh: false,
                              columns: 1,
                              rows: 1,
                              edgeInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0),
                              spacing: CGSize(width: 0, height: 0),
                              scrollDirection: .horizontal,
                              emptyDataText: nil,
                              emptyDataIconImage: nil,
                              delegate: self)
        _colleciton.isPagingEnabled = true
        _colleciton.showsVerticalScrollIndicator = false
        _colleciton.showsHorizontalScrollIndicator = false

    }

    private var _prototype: [[String: Any]]? {
        return [[kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: kCellIdentifier, kCellClassKey: ImageViewCell.self, kCellHeightKey: ImageViewCell.height]]
    }

    private func _loadData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()

        var id = 0
        _gallaryArray.forEach { image in
            cellData.append([
                kCellIdentifierKey: kCellIdentifier,
                kCellTagKey: id,
                kCellObjectDataKey: image,
                kCellClassKey: ImageViewCell.self,
                kCellHeightKey: ImageViewCell.height
            ])
            id += 1
        }

        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _colleciton.loadData(cellSectionData)
        _pageControl.numberOfPages = _colleciton.numberOfItems(inSection: 0)
    }

    // --------------------------------------
    // MARK: public
    // --------------------------------------

    public func setup(model: YachtOfferDetailModel) {
        _gallaryArray = model.images.toArray(ofType: String.self)
        _priceText.text = "D\(model.startingAmount)/HR"
        _loadData()
        }
    
}


extension YachtOfferDetailCell: CustomNoKeyboardCollectionViewDelegate, UICollectionViewDelegate {
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let cell = cell as? ImageViewCell,let object = cellDict?[kCellObjectDataKey] as? String else { return }
        cell.setupData(imageUrl: object)
        cell._imageView.cornerRadius = 0
    }
    
    func didEndDecelerating(_ scrollView: UIScrollView) {
        let pageWidth = _colleciton.frame.size.width - 20
        let currentPage = Int((scrollView.contentOffset.x + pageWidth / 2) / pageWidth)
        self.currentPage = currentPage
        _pageControl.currentPage = currentPage
        scrollToPage(currentPage)
    }
    
    func scrollToPage(_ page: Int) {
        let width = _colleciton.bounds.width
        let contentOffset = CGPoint(x: CGFloat(page) * width, y: 0)
        _colleciton.setContentOffset(contentOffset, animated: true)
    }

    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width, height: collectionView.frame.size.height)
    }
}
