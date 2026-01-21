import UIKit

class EventGalleryPreviewVC: ChildViewController {

    @IBOutlet weak var _collectionView: CustomNoKeyboardCollectionView!
    private let kCellIdentifier = String(describing: VenueGalleryCollectionCell.self)
    public var eventGallery: [String] = []
    public var selectedImage: String = kEmptyString
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let index = eventGallery.firstIndex(of: selectedImage) {
            let indexPath = IndexPath(item: index, section: 0)
            _collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self._collectionView == nil { return }
        self._collectionView.setContentOffset(_collectionView.contentOffset, animated: false)
        DISPATCH_ASYNC_MAIN {
            self._collectionView.visibleCells.forEach { cell in
                if cell is VenueGalleryCollectionCell {
                    (cell as? VenueGalleryCollectionCell)?.pauseVideo()
                }
            }
        }
    }
    
    private func _setup() {
        _collectionView.setup(cellPrototypes: _prototype,
                              hasHeaderSection: false,
                              enableRefresh: false,
                              columns: 1,
                              rows: 1,
                              edgeInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0),
                              spacing: CGSize(width: 0, height: 0),
                              scrollDirection: .horizontal,
                              emptyDataText: "",
                              emptyDataIconImage: UIImage(named: ""),
                              delegate: self)
        _collectionView.proxyDelegate = self
        _collectionView.showsVerticalScrollIndicator = false
        _collectionView.showsHorizontalScrollIndicator = false
        _collectionView.isPagingEnabled = true
        _loadData()
    }
    
    private func _loadData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        
        DISPATCH_ASYNC_MAIN {
            self.eventGallery.forEach({ model in
                cellData.append([
                    kCellIdentifierKey: self.kCellIdentifier,
                    kCellTagKey: self.kCellIdentifier,
                    kCellObjectDataKey: model,
                    kCellClassKey: VenueGalleryCollectionCell.self,
                    kCellHeightKey: VenueGalleryCollectionCell.height
                ])
            })
            cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
            self._collectionView.loadData(cellSectionData)
        }
    }
    
    private var _prototype: [[String: Any]]? {
        return [[kCellIdentifierKey: String(describing: VenueGalleryCollectionCell.self), kCellNibNameKey: String(describing: VenueGalleryCollectionCell.self), kCellClassKey: VenueGalleryCollectionCell.self, kCellHeightKey: VenueGalleryCollectionCell.height]]
    }

    @IBAction func _handleCloseEvent(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
}

extension EventGalleryPreviewVC: CustomNoKeyboardCollectionViewDelegate, UICollectionViewDelegate {
    
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? VenueGalleryCollectionCell {
            if let object = cellDict?[kCellObjectDataKey] as? String {
                if object.hasSuffix(".mp4") {
                    cell.setupVideo(videoUrl: object)
                    cell._fullscreenBtn.isHidden = true
                    cell._playerView.cornerRadius = 0
                    cell._playerView.contentMode = .scaleAspectFit
                    if object == selectedImage {
                        cell.resumeVideo()
                    }
                } else if !object.hasSuffix(".mp4") {
                    cell._playerView.isHidden = true
                    cell._imageView.isHidden = false
                    cell._volumeView.isHidden = true
                    cell._imageView.loadWebImage(object)
                    cell._fullscreenBtn.isHidden = true
                    cell._imageView.contentMode = .scaleAspectFit
                    cell._imageView.backgroundColor = .clear
                    cell._imageView.cornerRadius = 10
                }
            }
        }
    }
    
    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width , height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? VenueGalleryCollectionCell {
            cell.pauseVideo()
        }
    }
    
    func didEndDecelerating(_ scrollView: UIScrollView) {
        DISPATCH_ASYNC_MAIN_AFTER(0.5) {
            self._collectionView.visibleCells.forEach { tmpCell in
                if let tmpCell = tmpCell as? VenueGalleryCollectionCell {
                    tmpCell.pauseVideo()
                }
            }
            self._collectionView.visibleCells.forEach { tmpCell in
                if let tmpCell = tmpCell as? VenueGalleryCollectionCell,
                   let indexPath = self._collectionView.indexPath(for: tmpCell) {
                    let isVideo = self.eventGallery[indexPath.row].hasSuffix(".mp4")
                    let isFullyVisible = self._collectionView.isCellFullyVisible(cell: tmpCell)
                    if isVideo && isFullyVisible {
                        tmpCell.resumeVideo()
                        tmpCell._playerView.isHidden = false
                    } else {
                        tmpCell.pauseVideo()
                        tmpCell._playerView.isHidden = true
                    }
                }
            }
        }
    }
    
}

