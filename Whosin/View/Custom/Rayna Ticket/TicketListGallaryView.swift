
import Foundation
import RealmSwift
import UIKit
import SnapKit
import Lightbox

class TicketListGallaryView: UIView {
    
    @IBOutlet weak var _colleciton: CustomNoKeyboardCollectionView!
    @IBOutlet weak var _inImagePageControll: CustomPageControll!
    @IBOutlet weak var _imageSliderView: UIView!
    private let kCellIdentifier = String(describing: ImageViewCell.self)
    private var _gallaryArray: [String] = []
    var currentPage = 0
    var timer: Timer?
    private var isAutoScroll: Bool = false
    private var isPreviewAvailble: Bool = true
    private var isDataLoaded: Bool = false
    private var shouldAutoScroll: Bool = false
    
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
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        if window != nil {
            if isDataLoaded && shouldAutoScroll && _gallaryArray.count > 1 {
                _startAutoScroll()
            }
        } else {
            pauseAutoScroll()
        }
    }
    
    deinit {
        pauseAutoScroll()
        NotificationCenter.default.removeObserver(self)
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func _setupUi() {
        if var view = Bundle.main.loadNibNamed("TicketListGallaryView", owner: self, options: nil)?.first as? UIView {
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleViewWillDisappear), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleViewWillAppear), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    @objc private func handleViewWillAppear() {
        if isDataLoaded && shouldAutoScroll && _gallaryArray.count > 1 {
            _startAutoScroll()
        }
    }
    
    @objc private func handleViewWillDisappear() {
        pauseAutoScroll()
    }
    
    private var _prototype: [[String: Any]]? {
        return [[kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: kCellIdentifier, kCellClassKey: ImageViewCell.self, kCellHeightKey: ImageViewCell.height]]
    }
    
    private func _loadData() {
        isDataLoaded = false
        pauseAutoScroll()
        
        guard !_gallaryArray.isEmpty else { return }

        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()

        for (id, image) in _gallaryArray.enumerated() {
            cellData.append([
                kCellIdentifierKey: kCellIdentifier,
                kCellTagKey: id,
                kCellObjectDataKey: image,
                kCellClassKey: ImageViewCell.self,
                kCellHeightKey: ImageViewCell.height
            ])
        }

        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])

        _colleciton.loadData(cellSectionData)
        _inImagePageControll.numberOfPages = _colleciton.numberOfItems(inSection: 0)
        _inImagePageControll.currentPage = 0
        currentPage = 0
        isDataLoaded = true

        if shouldAutoScroll && _gallaryArray.count > 1 {
            _startAutoScroll()
        }
    }
    
    private func _startAutoScroll() {
        guard shouldAutoScroll && _gallaryArray.count > 1 && isDataLoaded else {
            return
        }
        
        pauseAutoScroll()
        
        timer = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { [weak self] _ in
            DispatchQueue.main.async {
                self?.scrollToNextPage()
            }
        }
    }
    
    @objc private func scrollToNextPage() {
        guard isDataLoaded && _colleciton.numberOfItems(inSection: 0) > 1 else {
            return
        }
        
        currentPage += 1
        if currentPage >= _colleciton.numberOfItems(inSection: 0) {
            currentPage = 0
        }
        scrollToPage(currentPage)
        _inImagePageControll.currentPage = currentPage
    }
    
    private func pauseAutoScroll() {
        timer?.invalidate()
        timer = nil
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    public func setupHeader(_ images: [String], pageControl: Bool = false, isPreview: Bool = true) {
        guard images != _gallaryArray else { return }
        pauseAutoScroll()
        isPreviewAvailble = isPreview
        _imageSliderView.isHidden = !pageControl
        shouldAutoScroll = images.count > 1
        currentPage = 0
        isDataLoaded = false
        _gallaryArray = images
        _loadData()
    }
    
    public func prepareForReuse() {
        pauseAutoScroll()
        isDataLoaded = false
        shouldAutoScroll = false
        currentPage = 0
        _gallaryArray.removeAll()
    }
    
    public func startAutoScroll() {
        if shouldAutoScroll && _gallaryArray.count > 1 && isDataLoaded {
            _startAutoScroll()
        }
    }
    
    public func stopAutoScroll() {
        pauseAutoScroll()
    }
}

extension TicketListGallaryView: CustomNoKeyboardCollectionViewDelegate, UICollectionViewDelegate {
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let cell = cell as? ImageViewCell, let object = cellDict?[kCellObjectDataKey] as? String else { return }
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
        let pageWidth = _colleciton.bounds.size.width
        let fractionalPage = scrollView.contentOffset.x / pageWidth
        let page = Int(round(fractionalPage))
        
        currentPage = max(0, min(page, _colleciton.numberOfItems(inSection: 0) - 1))
        _inImagePageControll.currentPage = currentPage
        pauseAutoScroll()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if self.shouldAutoScroll && self._gallaryArray.count > 1 {
                self._startAutoScroll()
            }
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        pauseAutoScroll()
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let pageWidth = _colleciton.frame.size.width
        let targetX = targetContentOffset.pointee.x
        let newPage = Int((targetX + (pageWidth / 2)) / pageWidth)
        targetContentOffset.pointee = CGPoint(x: CGFloat(newPage) * pageWidth, y: 0)
        self.currentPage = newPage
        _inImagePageControll.currentPage = newPage
    }
    
    private func scrollToPage(_ page: Int) {
        guard _colleciton.numberOfItems(inSection: 0) > page else {
            return
        }
        
        let indexPath = IndexPath(item: page, section: 0)
        _colleciton.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height)
    }
}
