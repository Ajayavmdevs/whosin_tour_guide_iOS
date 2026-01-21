import UIKit
import SnapKit

class CustomEventBottomView: UIView {
    
    @IBOutlet weak var _collecitonView: CustomCollectionView!
    @IBOutlet weak var _pageControl: CustomPageControll!
    @IBOutlet weak var _sapratorView: UIView!
    private let kCellIdentifier = String(describing: CMConfirmedEventCell.self)
    var currentPage = 0
    
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
        _collecitonView.setup(cellPrototypes: _prototype,
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
        _collecitonView.showsVerticalScrollIndicator = false
        _collecitonView.showsHorizontalScrollIndicator = false
        _collecitonView.isPagingEnabled = true
    }
    
    private func _loadData(_ model: [PromoterEventsModel]) {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        
        let sortedEvents = model.sorted {
            guard let firstDate = $0.startingSoon, let secondDate = $1.startingSoon else {
                return false
            }
            return firstDate < secondDate
        }
        
        sortedEvents.forEach({ model in
            cellData.append([
                kCellIdentifierKey: kCellIdentifier,
                kCellTagKey: kCellIdentifier,
                kCellObjectDataKey: model,
                kCellClassKey: CMConfirmedEventCell.self,
                kCellHeightKey: CMConfirmedEventCell.height
            ])
        })
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _collecitonView.loadData(cellSectionData)
    }
    
    private var _prototype: [[String: Any]]? {
        return [[kCellIdentifierKey: String(describing: CMConfirmedEventCell.self), kCellNibNameKey: String(describing: CMConfirmedEventCell.self), kCellClassKey: CMConfirmedEventCell.self, kCellHeightKey: CMConfirmedEventCell.height]]
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func _setupUi() {
        if var view = Bundle.main.loadNibNamed("CustomEventBottomView", owner: self, options: nil)?.first as? UIView {
            addSubview(view)
            view.snp.makeConstraints { make in
                make.leading.trailing.top.bottom.equalToSuperview()
            }
        }
    }
    
    public func setupData(_ model: [PromoterEventsModel]) {
        _loadData(model)
        _pageControl.isHidden = model.count <= 1
        _sapratorView.isHidden = model.count == 0
        _pageControl.numberOfPages = min(model.count, 3)
        _setup()
    }
    
}

extension CustomEventBottomView: CustomCollectionViewDelegate {
    
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? CMConfirmedEventCell, let object = cellDict?[kCellObjectDataKey] as? PromoterEventsModel {
            cell.setupData(object)
        }
    }
    
    func didSelectCell(_ cell: UICollectionViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let object = cellDict?[kCellObjectDataKey] as? PromoterEventsModel else { return }
        let randomStr = Utils.randomString(length: 20, id: object.id)
        let _logoHeroId = object.id + "_story_" + randomStr
        _collecitonView.hero.id = object.id
        _collecitonView.hero.modifiers = HeroAnimationModifier.stories
        let vc = INIT_CONTROLLER_XIB(PromoterEventDetailVC.self)
        vc.eventModel = object
        vc.id = object.id
        vc.isComplementary = true
        vc.hero.isEnabled = true
        vc.hero.modalAnimationType = .none
        vc.view.hero.id = object.id
        vc.view.hero.modifiers = HeroAnimationModifier.stories
        vc.modalPresentationStyle = .overFullScreen
        vc.openViewTicket = {
            let vc = INIT_CONTROLLER_XIB(CMConfirmedEventVC.self)
            vc.eventModel = object
            vc.hidesBottomBarWhenPushed = true
            self.parentBaseController?.navigationController?.pushViewController(vc, animated: true)
        }
        parentViewController?.present(vc, animated: true)
    }
    
    func didEndDecelerating(_ scrollView: UIScrollView) {
        let pageWidth = _collecitonView.frame.size.width - 20
        let currentPage = Int((scrollView.contentOffset.x + pageWidth / 2) / pageWidth)
        print("Page ===", currentPage)
        self.currentPage = currentPage
        _pageControl.currentPage = currentPage == 0 ? 0 : currentPage == (_collecitonView.numberOfItems(inSection: 0) - 1) ? 2 : 1
        scrollToPage(currentPage)
    }
    
    func scrollToPage(_ page: Int) {
        let width = _collecitonView.bounds.width
        let contentOffset = CGPoint(x: CGFloat(page) * width, y: 0)
        _collecitonView.setContentOffset(contentOffset, animated: true)
    }
    
    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width , height: 80)
    }
    
}

