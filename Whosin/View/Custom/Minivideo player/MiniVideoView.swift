import UIKit
import Lightbox
import AVKit
import SnapKit

class MiniVideoView: UIView {
    
    @IBOutlet weak var _collecitonView: CustomNoKeyboardCollectionView!
    private let kCellIdentifier = String(describing: VideoPlayerCell.self)
    private var _eventGallery: [AdListModel] = []
    var currentPage = 0
    var wasMiniPlayerManuallyClosed: Bool = false
    var onClose: ((_ model: AdListModel) -> Void)?
    var onClick: ((_ model: AdListModel) -> Void)?
    
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
    
    private var _prototype: [[String: Any]]? {
        return [[kCellIdentifierKey: String(describing: VideoPlayerCell.self), kCellNibNameKey: String(describing: VideoPlayerCell.self), kCellClassKey: VideoPlayerCell.self, kCellHeightKey: VideoPlayerCell.height]]
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func _setupUi() {
        if var view = Bundle.main.loadNibNamed("MiniVideoView", owner: self, options: nil)?.first as? UIView {
            addSubview(view)
            view.snp.makeConstraints { make in
                make.leading.trailing.top.bottom.equalToSuperview()
            }
        }
        _collecitonView.setup(cellPrototypes: _prototype,
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
        _collecitonView.isPagingEnabled = true
        _collecitonView.showsVerticalScrollIndicator = false
        _collecitonView.showsHorizontalScrollIndicator = false
    }
    
    private func _loadData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        
        var id = 0
        _eventGallery.forEach { model in
            cellData.append([
                kCellIdentifierKey: kCellIdentifier,
                kCellTagKey: id,
                kCellObjectDataKey: model,
                kCellClassKey: VideoPlayerCell.self,
                kCellHeightKey: VideoPlayerCell.height
            ])
            id += 1
        }
        
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _collecitonView.loadData(cellSectionData)
    }
    
    public func setupData(_ model: [AdListModel]) {
        _eventGallery = model
        _loadData()
    }
    
    public func pauseVideos() {
        _collecitonView.visibleCells.forEach { cell in
            if let videoCell = cell as? VideoPlayerCell {
                videoCell.pauseVideo()
            }
        }
    }
    
    public func resumeVideos() {
        _collecitonView.visibleCells.forEach { cell in
            if let videoCell = cell as? VideoPlayerCell {
                videoCell.resumeVideo()
            }
        }
    }
    
    @IBAction func _handleCloseEvent(_ sender: UIButton) {
        pauseVideos()
        onClose?(_eventGallery[currentPage])
    }
}

extension MiniVideoView: CustomNoKeyboardCollectionViewDelegate, UICollectionViewDelegate {
    
    
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let cell = cell as? VideoPlayerCell,let object = cellDict?[kCellObjectDataKey] as? AdListModel else { return }
        if object.video.hasSuffix(".mp4") {
            cell.setupVideo(videoUrl: object)
            if indexPath.row == currentPage {
                cell.resumeVideo()
            } else {
                cell.pauseVideo()
            }
        } else {
            cell._fullscreenBtn.isHidden = true
            cell._playerView.isHidden = true
        }
        cell.videoEnded = {
            self.handleVideoEnd()
        }
        
    }
    
    func didSelectCell(_ cell: UICollectionViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let object = cellDict?[kCellObjectDataKey] as? AdListModel else { return }
        Utils.addLog(screen: "ad_click", object: object)
        onClick?(_eventGallery[indexPath.row])
        if object.type == "venue" {
            let vc = INIT_CONTROLLER_XIB(VenueDetailsVC.self)
            vc.venueId = object.typeId
            vc.venueDetailModel = Utils.getModelFromId(model: APPSETTING.venueModel, id: object.typeId)
            Utils.pushViewController(vc)
        } else if object.type == "offer" {
            let controller = INIT_CONTROLLER_XIB(OfferPackageDetailVC.self)
            controller.offerId = object.typeId
            controller.vanueOpenCallBack = { venueId, venueModel in
                let vc = INIT_CONTROLLER_XIB(VenueDetailsVC.self)
                vc.venueId = venueId
                vc.venueDetailModel = venueModel
                Utils.getCurrentVC()?.navigationController?.pushViewController(vc, animated: true)
            }
            controller.buyNowOpenCallBack = { offer, venue, timing in
                let vc = INIT_CONTROLLER_XIB(BuyPackgeVC.self)
                vc.isFromActivity = false
                vc.type = "offers"
                vc.timingModel = timing
                vc.offerModel = offer
                vc.venue = venue
                vc.setCallback {
                    let controller = INIT_CONTROLLER_XIB(MyCartVC.self)
                    controller.modalPresentationStyle = .overFullScreen
                    Utils.getCurrentVC()?.navigationController?.pushViewController(controller, animated: true)
                }
                Utils.getCurrentVC()?.navigationController?.pushViewController(vc, animated: true)
            }
            Utils.getCurrentVC()?.presentAsPanModal(controller: controller)
        } else if object.type == "ticket" {
            let vc = INIT_CONTROLLER_XIB(CustomTicketDetailVC.self)
            vc.ticketID = object.typeId
            vc.hidesBottomBarWhenPushed = true
            Utils.pushViewController(vc)
        } else if object.type == "event" {
            let vc = INIT_CONTROLLER_XIB(EventDetailVC.self)
            vc.eventId = object.typeId
            Utils.pushViewController(vc)
        } else if object.type == "activity" {
            let vc = INIT_CONTROLLER_XIB(ActivityInfoVC.self)
            vc.activityId = object.typeId
            vc.modalPresentationStyle = .overFullScreen
            Utils.openViewController(vc)
        } else if object.type == "category" {
            let vc = INIT_CONTROLLER_XIB(CategoryDetailVC.self)
            vc.categoryId = object.typeId
            vc.modalPresentationStyle = .overFullScreen
            Utils.openViewController(vc)
        } else if object.type == "promoter-event" {
            let vc = INIT_CONTROLLER_XIB(PromoterEventDetailVC.self)
            vc.id = object.typeId
            vc.isComplementary = APPSESSION.userDetail?.isRingMember == true
            vc.modalPresentationStyle = .overFullScreen
            Utils.openViewController(vc)
        }
    }
    
    func didEndDecelerating(_ scrollView: UIScrollView) {
        let pageWidth = _collecitonView.frame.size.width - _collecitonView.contentInset.left - _collecitonView.contentInset.right
        let currentPage = Int((scrollView.contentOffset.x + pageWidth / 2) / pageWidth)
        if currentPage >= _eventGallery.count {
            self.currentPage = 0
            _collecitonView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .centeredHorizontally, animated: false)
        }
        self.currentPage = currentPage
        let currentModel = self._eventGallery[currentPage]
        Utils.addLog(screen: "ad_swipe", object: currentModel)
        if let currentCell = self._collecitonView.cellForItem(at: IndexPath(item: currentPage, section: 0)) as? VideoPlayerCell {
            let isVideo = self._eventGallery[currentPage].video.hasSuffix(".mp4")
            if isVideo {
                currentCell._playerView.seek(to: .zero)
                currentCell.resumeVideo()
            }
        }
        
        
    }
    
    private func handleVideoEnd() {
        currentPage = (currentPage < _eventGallery.count - 1) ? currentPage + 1 : 0
        let nextIndexPath = IndexPath(item: currentPage, section: 0)
        self._collecitonView.scrollToItem(at: nextIndexPath, at: .centeredHorizontally, animated: true)
        pauseVideos()
        DISPATCH_ASYNC_MAIN_AFTER(0.01) {
            if let currentCell = self._collecitonView.cellForItem(at: nextIndexPath) as? VideoPlayerCell,
               self._eventGallery[self.currentPage].video.hasSuffix(".mp4") {
                currentCell._playerView.seek(to: .zero)
                currentCell.resumeVideo()
            }
        }
    }
    
}
