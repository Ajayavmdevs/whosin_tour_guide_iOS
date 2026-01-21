import UIKit
import GSPlayer
import Hero

class ChatStoryViewCell: UITableViewCell {
    
    @IBOutlet private weak var _storyCollectionView: CustomCollectionView!
    private let kCellIdentifierStory = String(describing: StoryUserCell.self)
    private var _venueDetailModel: [VenueDetailModel] = []

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUi()
        NotificationCenter.default.addObserver(self, selector: #selector(handleReload), name: kReloadStoryyNotification, object: nil)
    }
    
    class var height: CGFloat {
        150
    }

    private func setupUi() {
        _storyCollectionView.setup(cellPrototypes: _storyPrototype,
                                   hasHeaderSection: false,
                                   enableRefresh: false,
                                   columns: 5,
                                   rows: 1,
                                   edgeInsets: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0),
                                   scrollDirection: .horizontal,
                                   emptyDataText: nil,
                                   emptyDataIconImage: nil,
                                   delegate: self)
        _storyCollectionView.showsVerticalScrollIndicator = false
        _storyCollectionView.showsHorizontalScrollIndicator = false
        
    }
    
    private func _loadData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        
        _venueDetailModel.forEach { story in
            cellData.append([
                kCellIdentifierKey: kCellIdentifierStory,
                kCellTagKey: story.id,
                kCellObjectDataKey: story,
                kCellClassKey: StoryUserCell.self,
                kCellHeightKey: StoryUserCell.height,
                kCellClickEffectKey:true
            ])
        }
        
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _storyCollectionView.loadData(cellSectionData)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    public func setupData(_ data: [VenueDetailModel]) {
        _venueDetailModel = data
        _loadData()
    }
    
    @objc func handleReload() {
        _storyCollectionView.reload()
    }
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private var _storyPrototype: [[String: Any]]? {
        return [[kCellIdentifierKey: kCellIdentifierStory, kCellNibNameKey: String(describing: StoryUserCell.self), kCellClassKey: StoryUserCell.self, kCellHeightKey: StoryUserCell.height]]
    }
    
    private func _viewStoryAt(index: Int, heroId: String) {
        let controller = INIT_CONTROLLER_XIB(ContentViewVC.self)
        controller.modalPresentationStyle = .overFullScreen
        controller.pages = self._venueDetailModel
        controller.currentIndex = index
        controller.hero.isEnabled = true
        controller.hero.modalAnimationType = .none
        controller.view.hero.id = heroId
        controller.view.hero.modifiers = HeroAnimationModifier.stories
        
        parentViewController?.present(controller, animated: true)
    }
}

extension ChatStoryViewCell: CustomCollectionViewDelegate {

    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let cell = cell as? StoryUserCell,
              let object = cellDict?[kCellObjectDataKey] as? VenueDetailModel else { return }
        cell.setup(model: object, true)
        cell.prepareForReuse()
    }

    func didSelectCell(_ cell: UICollectionViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
            guard let cell = cell as? StoryUserCell,
            let object = cellDict?[kCellObjectDataKey] as? VenueDetailModel else { return }
            guard let storyModel = object.storie.first else {return}
            if storyModel.mediaType == "image" {
                cell._viewImageBg.removeGradientBorders()
                cell._viewImageBg.addRoundedRectGradientStrokeAnimationChat(strokeWidth: 6, duration: 10)
                DISPATCH_ASYNC_MAIN_AFTER(0.7) {
                    self._viewStoryAt(index: indexPath.row, heroId: object.id)
                }
            } else {
                guard let url = URL(string: storyModel.mediaUrl) else { return }
                if let configuration = try? VideoCacheManager.cachedConfiguration(for: url)  {
                    self._viewStoryAt(index: indexPath.row, heroId: object.id)
                    return
                }

                VideoPreloadManager.shared.preloadByteCount = 1024 * 1024 * 2
                VideoPreloadManager.shared.set(waiting: [url])
                cell._viewImageBg.removeGradientBorders()
                cell._viewImageBg.addRoundedRectGradientStrokeAnimationChat(strokeWidth: 6, duration: 10)
                VideoPreloadManager.shared.didFinish = { error in
                    VideoPreloadManager.shared.didFinish = nil
                    var newList = object.getVideoUrls()
                    VideoPreloadManager.shared.set(waiting: newList)
                    self._viewStoryAt(index: indexPath.row, heroId: object.id)
                }
            }
    }
    
    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        CGSize(width: 90, height: StoryUserCell.height)
    }
}
