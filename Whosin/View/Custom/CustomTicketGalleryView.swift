import UIKit
import Lightbox
import SnapKit

class CustomTicketGalleryView: UIView {
    
    @IBOutlet weak var _collecitonView: UICollectionView!
    @IBOutlet weak var _pageControl: CustomPageControll!
    private let kCellIdentifier = String(describing: VenueGalleryCollectionCell.self)
    private var _gallery: [String] = []
    var currentPage = 0
    var isDisablePreview: Bool = false
    
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
        _setup()
    }
    
    private func _setup() {
        let layout = HorizontalPagingFlowLayout()
        layout.scrollDirection = .horizontal
        _collecitonView.isPagingEnabled = false
        _collecitonView.decelerationRate = .fast
        _collecitonView.showsHorizontalScrollIndicator = false
        _collecitonView.showsVerticalScrollIndicator = false
        _collecitonView.collectionViewLayout = layout
        _collecitonView.register(UINib(nibName: "VenueGalleryCollectionCell", bundle: nil), forCellWithReuseIdentifier: "VenueGalleryCollectionCell")
        _collecitonView.delegate = self
        _collecitonView.dataSource = self
        _collecitonView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        _collecitonView.reloadData()
    }
    
    private var _prototype: [[String: Any]]? {
        return [[kCellIdentifierKey: String(describing: VenueGalleryCollectionCell.self), kCellNibNameKey: String(describing: VenueGalleryCollectionCell.self), kCellClassKey: VenueGalleryCollectionCell.self, kCellHeightKey: VenueGalleryCollectionCell.height]]
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func _setupUi() {
        if var view = Bundle.main.loadNibNamed("CustomTicketGalleryView", owner: self, options: nil)?.first as? UIView {
            addSubview(view)
            view.snp.makeConstraints { make in
                make.leading.trailing.top.bottom.equalToSuperview()
            }
        }
    }
    
    public func setupData(_ model: [String], hidePageControl: Bool = false, hide: Bool = false, disablePreview: Bool = false) {
        isDisablePreview = disablePreview
        currentPage = 0
        _gallery.removeAll()
        _gallery = model
        _pageControl.isHidden = hide ? true : hidePageControl ? true : _gallery.count <= 1
        _collecitonView.reloadData()
        _collecitonView.isHidden = hide
        _setup()
    }
    
    public func pauseVideos() {
        _collecitonView.visibleCells.forEach { cell in
            if let videoCell = cell as? VenueGalleryCollectionCell {
                videoCell.pauseVideo()
            }
        }
    }
    
    public func resumeVideos() {
        DISPATCH_ASYNC_MAIN_AFTER(0.1) {
            print("current page======", self.currentPage)
            if let currentCell = self._collecitonView.cellForItem(at: IndexPath(item: self.currentPage, section: 0)) as? VenueGalleryCollectionCell {
                let isVideo = self._gallery[self.currentPage].hasSuffix(".mp4")
                if isVideo {
                    currentCell._fullScreenView.isHidden = false
                    currentCell.resumeVideo()
                } else {
                    currentCell._fullScreenView.isHidden = true
                    currentCell._playIcon.isHidden = true
                    currentCell.pauseVideo()
                }
            }
        }
    }
    
}

extension CustomTicketGalleryView: UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return _gallery.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VenueGalleryCollectionCell", for: indexPath) as! VenueGalleryCollectionCell
        let object = _gallery[indexPath.row]
        _pageControl.numberOfPages = min(collectionView.numberOfItems(inSection: 0), 3)
        if object.hasSuffix(".mp4") {
            cell._fullScreenView.isHidden = false
            cell.setupVideo(videoUrl: object)
            if indexPath.row == 0 {
                cell.resumeVideo()
            }
        } else {
            cell._imageView.isHidden = false
            cell._playerView.isHidden = true
            cell._playIcon.isHidden = true
            cell._volumeView.isHidden = true
            cell._fullScreenView.isHidden = true
            cell._imageView.loadWebImage(object)
            cell._imageView.cornerRadius = 0
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        pauseVideos()
        guard !isDisablePreview else { return }
        let vc = INIT_CONTROLLER_XIB(EventGalleryPreviewVC.self)
        vc.modalPresentationStyle = .overFullScreen
        vc.eventGallery = _gallery
        vc.selectedImage = _gallery[indexPath.row]
        parentViewController?.present(vc, animated: true)
    }
        
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? VenueGalleryCollectionCell {
            cell.pauseVideo()
            cell._playIcon.isHidden = true
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageWidth = _collecitonView.frame.size.width - _collecitonView.contentInset.left - _collecitonView.contentInset.right
        let currentPage = Int((scrollView.contentOffset.x + pageWidth / 2) / pageWidth)
        print("Page ===", currentPage)
        self.currentPage = currentPage
        
        let totalPages = _collecitonView.numberOfItems(inSection: 0)
        if totalPages == 1 {
            _pageControl.currentPage = 0
        } else if currentPage == 0 {
            _pageControl.currentPage = 0
        } else if currentPage == (totalPages - 1) {
            _pageControl.currentPage = 2
        } else {
            _pageControl.currentPage = 1
        }
        
        DISPATCH_ASYNC_MAIN_AFTER(0.1) {
            self._collecitonView.visibleCells.forEach { tmpCell in
                if let tmpCell = tmpCell as? VenueGalleryCollectionCell {
                    tmpCell.pauseVideo()
                }
            }
            
            if let currentCell = self._collecitonView.cellForItem(at: IndexPath(item: currentPage, section: 0)) as? VenueGalleryCollectionCell {
                let isVideo = self._gallery[currentPage].hasSuffix(".mp4")
                if isVideo {
                    currentCell._fullScreenView.isHidden = false
                    currentCell.resumeVideo()
                } else {
                    currentCell._fullScreenView.isHidden = true
                    currentCell._playIcon.isHidden = true
                }
            }
        }
    }

}
