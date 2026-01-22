import Foundation
import RealmSwift
import UIKit
import SnapKit
import Lightbox


class CustomGallaryView: UIView {
    
    @IBOutlet weak var _startingTxt: UILabel!
    @IBOutlet weak var _priceview: GradientView!
    @IBOutlet weak var _priceText: UILabel!
    @IBOutlet weak var _discriptionText: UILabel!
    @IBOutlet weak var _titleText: UILabel!
    @IBOutlet weak var _colleciton: CustomNoKeyboardCollectionView!
    @IBOutlet weak var _pageControl: CustomPageControll!
    @IBOutlet weak var _topView: GradientView!
    @IBOutlet weak var _pageControlView: UIView!
    @IBOutlet weak var _inImagePageControll: CustomPageControll!
    @IBOutlet weak var _imageSliderView: UIView!
    private let kCellIdentifier = String(describing: ImageViewCell.self)
    private var _gallaryArray: [String] = []
    var currentPage = 0
    var timer: Timer?
    private var isAutoScroll: Bool = false
    private var isPreviewAvailble: Bool = true
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    
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
        DISPATCH_ASYNC_MAIN_AFTER(0.02) {
            self._priceview.roundCorners(corners: [.bottomLeft, .topRight], radius: 15)
        }
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func _setupUi() {
        if var view = Bundle.main.loadNibNamed("CustomGallaryView", owner: self, options: nil)?.first as? UIView {
            addSubview(view)
            view.snp.makeConstraints { make in
                make.leading.trailing.top.bottom.equalToSuperview()
            }
        }
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
        _inImagePageControll.numberOfPages = _colleciton.numberOfItems(inSection: 0)
        _startAutoScroll()
    }
    
    public func _startAutoScroll() {
        if isAutoScroll {
            if timer?.isValid ?? false {
                timer?.invalidate()
                timer = nil
            }
            timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(scrollToNextPage), userInfo: nil, repeats: true)
        }
    }
    
    @objc func scrollToNextPage() {
        currentPage += 1
        if currentPage >= _colleciton.numberOfItems(inSection: 0) {
            currentPage = 0
        }
        //        let width = currentPage == 0 ? _colleciton.bounds.width : _colleciton.bounds.width - 20
        let contentOffset = CGPoint(x: CGFloat(currentPage) * _colleciton.bounds.width, y: 0)
        _colleciton.setContentOffset(contentOffset, animated: true)
        _pageControl.currentPage = currentPage
        _inImagePageControll.currentPage = currentPage
    }
    
    func pauseAutoScroll() {
        if timer?.isValid ?? false {
            timer?.invalidate()
            timer = nil
        }
    }
    
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    public func setupHeader(_ images: [String], pageControl: Bool = true, imagePageControl: Bool = false, isPreview: Bool = true) {
        isPreviewAvailble = isPreview
        _imageSliderView.isHidden = !imagePageControl
        isAutoScroll = true
        _pageControlView.isHidden = pageControl
        _priceview.isHidden = true
        _topView.isHidden = true
        DISPATCH_ASYNC_MAIN {
            self._gallaryArray = images
            self._loadData()
        }

    }
    
}

extension CustomGallaryView: CustomNoKeyboardCollectionViewDelegate, UICollectionViewDelegate {
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let cell = cell as? ImageViewCell,let object = cellDict?[kCellObjectDataKey] as? String else { return }
        cell.setupData(imageUrl: object)
        cell._imageView.cornerRadius = 0
    }
    
    func didSelectCell(_ cell: UICollectionViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let cell = cell as? ImageViewCell, let object = cellDict?[kCellObjectDataKey] as? String else { return }
        if isPreviewAvailble {
            var images: [LightboxImage] = []
            for urlString in _gallaryArray {
                if let url = URL(string: urlString) {
                    if urlString == object {
                        images.insert(LightboxImage(imageURL: url), at: 0)
                    } else {
                        images.append(LightboxImage(imageURL: url))
                    }
                }
            }
            let controller = LightboxController(images: images)
            controller.dynamicBackground = true
            parentBaseController?.present(controller, animated: true, completion: nil)
        }
    }
    
    func didEndDecelerating(_ scrollView: UIScrollView) {
        let pageWidth = _colleciton.frame.size.width - 20
        let currentPage = Int((scrollView.contentOffset.x + pageWidth / 2) / pageWidth)
        self.currentPage = currentPage
        _pageControl.currentPage = currentPage
        _inImagePageControll.currentPage = currentPage
        scrollToPage(currentPage)
        pauseAutoScroll()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self._startAutoScroll()
        }
        
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
