import DifferenceKit
import DZNEmptyDataSet
//import TPKeyboardAvoiding
import SkeletonView
import UIKit


@objc
public
protocol CustomNoKeyboardCollectionViewDelegate: AnyObject {
	@objc func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String: Any]?, indexPath: IndexPath)
	@objc optional func didSelectCell(_ cell: UICollectionViewCell, sectionTitle: String?, cellDict: [String: Any]?, indexPath: IndexPath)
	@objc optional func willDisplay(_ collectionView: UICollectionView, cell: UICollectionViewCell, cellDict: [String: Any]?, indexPath: IndexPath)
	@objc optional func didDropCell(sourceIndexPath: IndexPath, destinationIndexPath: IndexPath)
	@objc optional func didDragCell(_ collectionView: UICollectionView, cellDict: [String: Any]?, indexPath: IndexPath)
    @objc optional func setupCollectionHeader(_ header: UICollectionReusableView, indexPath: IndexPath)
	@objc optional func didEndDecelerating(_ scrollView: UIScrollView)
	@objc optional func refreshData()
	@objc optional func didTapToEmptyDataSet()
	@objc optional func cellSize(_ collectionView: UICollectionView, cellDict: [String: Any]?, indexPath: IndexPath) -> CGSize
}


public class CustomNoKeyboardCollectionView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDropDelegate, UICollectionViewDragDelegate {
	enum CollectionViewType {
		case list
		case grid
		case undefined
	}
	enum SectionOrientation {
		case horizontal, vertical
	}
	weak public var proxyDataSource: UICollectionViewDataSource?
	weak public var proxyDelegate: UICollectionViewDelegate?
    weak public var proxyLayout: UICollectionViewDelegateFlowLayout?
    public var isLoading: Bool = false

	private let kHeaderIdentifier = "header"
	private var _complexLayout: Bool? = false
	private var _gridSectionInfo: [Int: [String: Any]] = [:]
	private var _selectedIndexPath: IndexPath?
	private weak var _delegate: CustomNoKeyboardCollectionViewDelegate?
	private var _refreshView: RefreshView?
    private var _columns: Float = 0.0
	private var _hasHeaderSection: Bool = false
	private var _headerBackgroundColor: UIColor = ColorBrand.brandGray
	private var _headerFooterTextColor: UIColor = ColorBrand.white
	private var _rows: Int = 0
	private var _edgeInsets: UIEdgeInsets = UIEdgeInsets.zero
	private var _spacing: CGSize = CGSize.zero
	private var _emptyDataText: String?
	private var _emptyDataIconImage: UIImage?
	private var _emptyDataDescription: String?
	private var _scrollDirection: UICollectionView.ScrollDirection = .vertical
	private var _didLoad: Bool = false
    private var _isDummyLoad: Bool = false
	private var _cellSectionData: [[String: Any]] = []
	private var _canReorderLayout: Bool = false
	private var _useCustomheader: Bool = false
	private var _headerSectionData: [String: Any]? = [:]
	private var _allowTouchEmptyDataSet: Bool = false
    
    private var lastContentOffset: CGFloat = 0

	// --------------------------------------
	// MARK: Life Cycle
	// --------------------------------------

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		_customInit()
	}

	override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
		super.init(frame: frame, collectionViewLayout: layout)
		_customInit()
	}

	override public func awakeFromNib() {
		super.awakeFromNib()
		_customInit()
	}

	override public func draw(_ rect: CGRect) {
		super.draw(rect)
	}

	// --------------------------------------
	// MARK: Private
	// --------------------------------------

	private func _customInit() {
        isSkeletonable = true
		_cellSectionData = []
		dataSource = self
		delegate = self
		showsHorizontalScrollIndicator = true
		keyboardDismissMode = .onDrag
	}
    
    private func _loadDummyData(cellPrototypes: [[String: Any]]) {
        var cellData = [[String: Any]]()
        
        cellPrototypes.forEach { cellPrototype in
            guard let identifier = cellPrototype[kCellIdentifierKey] as? String,
                  let classKey = cellPrototype[kCellClassKey] as? NSObject.Type,
                  let cellHeight = cellPrototype[kCellHeightKey] as? CGFloat else { return }
            
            cellData.append([
                kCellIdentifierKey: identifier,
                kCellClassKey: classKey,
                kCellHeightKey: cellHeight])
            
            if cellPrototypes.count == 1 {
                for _ in 0...9 {
                    cellData.append([
                        kCellIdentifierKey: identifier,
                        kCellClassKey: classKey,
                        kCellHeightKey: cellHeight])
                }
            }
        }

        _isDummyLoad = true
        _cellSectionData = [[kSectionTitleKey: kEmptyString, kSectionDataKey: cellData]]
        reload()
    }

	@objc private func _refresh() {
		_refreshView?.showActivity()
		_delegate?.refreshData?()
	}

	/// This method moves a cell from source indexPath to destination indexPath within the same collection view. It works for only 1 item. If multiple items selected, no reordering happens.
	private func _reorderItems(coordinator: UICollectionViewDropCoordinator, destinationIndexPath: IndexPath) {
		let items = coordinator.items
		if items.count == 1, let item = items.first, let sourceIndexPath = item.sourceIndexPath {
			performBatchUpdates({
				guard var sourceData = _cellSectionData[sourceIndexPath.section][kSectionDataKey] as? [Any], var destinationData = _cellSectionData[destinationIndexPath.section][kSectionDataKey] as? [Any], let cellDict = item.dragItem.localObject as? [String: Any] else { return }

				if destinationIndexPath.row > destinationData.count { return }

				sourceData.remove(at: sourceIndexPath.row)
				_cellSectionData[sourceIndexPath.section][kSectionDataKey] = sourceData
				if sourceIndexPath.section == destinationIndexPath.section { destinationData.remove(at: sourceIndexPath.row) }

				destinationData.insert(cellDict, at: destinationIndexPath.row)
				_cellSectionData[destinationIndexPath.section][kSectionDataKey] = destinationData

				deleteItems(at: [sourceIndexPath])
				insertItems(at: [destinationIndexPath])
				_delegate?.didDropCell?(sourceIndexPath: sourceIndexPath, destinationIndexPath: destinationIndexPath)
			})
			coordinator.drop(items.first!.dragItem, toItemAt: destinationIndexPath)
		}
	}

	// --------------------------------------
	// MARK: <UICollectionViewDataSource>
	// --------------------------------------

    public func numberOfSections(in _: UICollectionView) -> Int {
		let numSection = _cellSectionData.count
		return numSection
	}

    public func collectionView(_: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		guard let sectionData = _cellSectionData[section][kSectionDataKey] as? [Any] else { return 0 }
		let numItems = sectionData.count
		return numItems
	}

    public func collectionView(_: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		switch kind {
			case UICollectionView.elementKindSectionHeader:
				if _useCustomheader {
					let headerView = dequeueReusableSupplementaryView(
						ofKind: kind,
						withReuseIdentifier: kHeaderIdentifier,
						for: indexPath)
                    _delegate?.setupCollectionHeader?(headerView, indexPath: indexPath)
					return headerView
				} else {
					let sectionTitle = _cellSectionData[indexPath.section][kSectionTitleKey] as? String ?? kEmptyString
					return buildHeaderFooterView(text: sectionTitle, indexpath: indexPath, kind: kind, backgroundColor: _headerBackgroundColor)
				}
			default:
				return UICollectionReusableView()
		}
	}

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let sectionData = _cellSectionData[indexPath.section][kSectionDataKey] as? [Any],
              let cellDict = sectionData[indexPath.row] as? [String: Any],
              let identifier = cellDict[kCellIdentifierKey] as? String else {
            return UICollectionViewCell()
        }

        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? UICollectionViewCell else {
            return UICollectionViewCell()
        }

        _delegate?.setupCollectionCell(cell, cellDict: cellDict, indexPath: indexPath)
        return cell
    }


    public func getCellData (indexPath: IndexPath) -> [String: Any]? {
		guard let sectionData = _cellSectionData[indexPath.section][kSectionDataKey] as? [Any] else { return nil }
		guard let cellDict = sectionData[indexPath.row] as? [String: Any] else { return nil }
		return cellDict
	}

	// --------------------------------------
	// MARK: <UICollectionViewDelegate>
	// --------------------------------------

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		collectionView.deselectItem(at: indexPath, animated: true)
		guard let sectionData = _cellSectionData[indexPath.section][kSectionDataKey] as? [Any] else { return }
		guard let sectionTitle = _cellSectionData[indexPath.section][kSectionTitleKey] as? String else { return }
		guard let cellDict = sectionData[indexPath.row] as? [String: Any] else { return }
		let cell = collectionView.cellForItem(at: indexPath)
		_selectedIndexPath = indexPath
        
        if let showEffect = cellDict[kCellClickEffectKey] as? Bool, showEffect {
            var transform = CGAffineTransform.identity
            transform = transform.scaledBy(x: 0.94, y: 0.94)
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [], animations: {
                cell?.transform = transform
            }) { _ in
                self._delegate?.didSelectCell?(cell!, sectionTitle: sectionTitle, cellDict: cellDict, indexPath: indexPath)
            }
        }
        else {
            self._delegate?.didSelectCell?(cell!, sectionTitle: sectionTitle, cellDict: cellDict, indexPath: indexPath)
        }
		
	}

    public func collectionView(_: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		proxyDelegate?.collectionView?(self, didEndDisplaying: cell, forItemAt: indexPath)
	}

    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		guard let sectionData = _cellSectionData[indexPath.section][kSectionDataKey] as? [Any] else { return }
		guard let cellDict = sectionData[indexPath.row] as? [String: Any] else { return }
		_delegate?.willDisplay?(collectionView, cell: cell, cellDict: cellDict, indexPath: indexPath)
	}

	// --------------------------------------
	// MARK: <UICollectionViewDragDelegate>
	// --------------------------------------

    public func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
		guard let sectionData = _cellSectionData[indexPath.section][kSectionDataKey] as? [Any], let cellDict = sectionData[indexPath.row] as? [String: Any] else { return [] }
		let item = String(cellDict[kCellDifferenceIdentifierKey] as? Int ?? 0)
		let itemProvider = NSItemProvider(object: item as NSString)
		let dragItem = UIDragItem(itemProvider: itemProvider)
		dragItem.localObject = cellDict
		_delegate?.didDragCell?(collectionView, cellDict: cellDict, indexPath: indexPath)
		return [dragItem]
	}

	// --------------------------------------
	// MARK: <UICollectionViewDropDelegate>
	// --------------------------------------

    public func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
		_canReorderLayout
	}

    public func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
		if collectionView.hasActiveDrag {
			return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
		} else {
			return UICollectionViewDropProposal(operation: .forbidden)
		}
	}

    public func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
		if coordinator.proposal.operation  == .move, let destinationIndexPath = coordinator.destinationIndexPath {
			_reorderItems(coordinator: coordinator, destinationIndexPath: destinationIndexPath)
		}
	}

	// --------------------------------------
	// MARK: <UICollectionViewDelegateFlowLayout>
	// --------------------------------------

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		if proxyLayout != nil {
			return proxyLayout?.collectionView?(self, layout: collectionViewLayout, sizeForItemAt: indexPath) ?? cellSize
		}
		guard let sectionData = _cellSectionData[indexPath.section][kSectionDataKey] as? [Any] else { return cellSize}
		guard let cellDict = sectionData[indexPath.row] as? [String: Any] else { return  cellSize}
        var _cellSize = cellSize
		return _delegate?.cellSize?(self, cellDict: cellDict, indexPath: indexPath) ?? _cellSize
	}

    public func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, insetForSectionAt _: Int) -> UIEdgeInsets {
		_edgeInsets
	}

    public func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, minimumInteritemSpacingForSectionAt _: Int) -> CGFloat {
		_spacing.width
	}

    public func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, minimumLineSpacingForSectionAt _: Int) -> CGFloat {
		_spacing.height
	}

    public func collectionView(_ collectionView: UICollectionView, layout _: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
		if _hasHeaderSection {
			if _useCustomheader {
				if let height = _headerSectionData?[kCellHeightKey] as? Float {
					return CGSize(width: collectionView.bounds.size.width, height: CGFloat(height))
				}
			}
            let sectionTitle = _cellSectionData[section][kSectionTitleKey] as? String ?? kEmptyString
            if sectionTitle.isEmpty {
                return CGSize(width: collectionView.bounds.size.width, height: 10.0)
            }
			return CGSize(width: collectionView.bounds.size.width, height: kHeaderFooterHeight)
		} else {
			return CGSize(width: 0, height: 0)
		}
	}

	// --------------------------------------
	// MARK: <UIScrollViewDelegate>
	// --------------------------------------
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        proxyDelegate?.scrollViewWillEndDragging?(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset )
        
//        let currentPageHorizontal = ceil(targetContentOffset.pointee.x / 346.0)
//        let newX = cellSize.width * CGFloat(currentPageHorizontal)
//        DISPATCH_ASYNC_MAIN_AFTER(0.01) {
//            self.setContentOffset(CGPoint(x: newX, y: targetContentOffset.pointee.y), animated: true)
//        }
    }

	public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		_delegate?.didEndDecelerating?(scrollView)
	}
    
    

	// --------------------------------------
	// MARK: Public
	// --------------------------------------
    
    public var isDummyLoad: Bool {
        _isDummyLoad
    }

    public var isDataEmpty: Bool {
		_cellSectionData.count == 0
	}

    public var isRefreshing: Bool {
		refreshControl != nil && refreshControl!.isRefreshing
	}

    public var cellSize: CGSize {
		var size = frame.size
		var itemsCount = 0
		let columns = CGFloat(_columns)
		for section in _cellSectionData {
			let sectionData = section[kSectionDataKey] as? [Any]
			itemsCount += sectionData!.count
		}
		let numberOfRows = Int(ceil(CGFloat(itemsCount) / columns))
		let totalRowsCount = max(_rows, numberOfRows)
		let visibleRowsCount = min(totalRowsCount, _rows)
		var width = floor((size.width - _edgeInsets.left - _edgeInsets.right - _spacing.width * (columns - 1.0)) / columns)
		var height = CGFloat(size.height - _edgeInsets.top - _edgeInsets.bottom - _spacing.height) / CGFloat(visibleRowsCount)
		width = width < 0 ? 0 : width
		height = height < 0 ? 0 : height
		size = CGSize(width: width, height: height)
		return size
	}

    public func setup(
		cellPrototypes: [[String: Any]]?, hasHeaderSection: Bool = false,
		headerBackgroundColor: UIColor = ColorBrand.brandGray,
		headerFooterTextColor: UIColor = ColorBrand.white,
		enableRefresh: Bool = false, columns: Float = kCollectionViewDefaultColumns, rows: Int = kCollectionViewDefaultRows,
		edgeInsets: UIEdgeInsets = UIEdgeInsets.zero, spacing: CGSize = CGSize.zero,
		scrollDirection: UICollectionView.ScrollDirection = .vertical,
		canReorderLayout: Bool = false, customHeader: Bool = false, isDummyLoad: Bool = false, headerPrototypes: [String: Any]? = [:],
		emptyDataText: String? = nil, emptyDataIconImage: UIImage? = nil, emptyDataDescription: String? = nil, allowTouchEmptyDataSet: Bool = false,
		delegate: CustomNoKeyboardCollectionViewDelegate?, complexLayout: Bool? = false, gridSectionInfo: [Int: [String: Any]] = [:]) {
            
		// Assign values
		_hasHeaderSection = hasHeaderSection
		_headerBackgroundColor = headerBackgroundColor
		_headerFooterTextColor = headerFooterTextColor
		_delegate = delegate
		_columns = columns > 0 ? columns : kCollectionViewDefaultColumns
		_rows = rows > 0 ? rows : kCollectionViewDefaultRows
		_edgeInsets = edgeInsets
		_spacing = spacing
		_canReorderLayout = canReorderLayout
		_emptyDataText = emptyDataText
		_emptyDataIconImage = emptyDataIconImage
		_emptyDataDescription = emptyDataDescription
		_scrollDirection = scrollDirection
		_complexLayout = complexLayout
		_gridSectionInfo = gridSectionInfo
		_useCustomheader = customHeader
		_headerSectionData = headerPrototypes
		_allowTouchEmptyDataSet = allowTouchEmptyDataSet

		if _useCustomheader {
			guard let nibName = _headerSectionData?[kCellNibNameKey] as? String else { return }
			register(UINib(nibName: nibName, bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: kHeaderIdentifier)
		} else {
			register(CustomCollectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: kHeaderIdentifier)
		}

		// Register all the prototype UITableViewCell for the current UICollection
		for cellPrototype in cellPrototypes ?? [] {
			guard let nibName = cellPrototype[kCellNibNameKey] as? String else { return }
			guard let identifier = cellPrototype[kCellIdentifierKey] as? String else { return }
			register(UINib(nibName: nibName, bundle: nil), forCellWithReuseIdentifier: identifier)
		}

		if scrollDirection == .horizontal {
			let horizontalLayout = UICollectionViewFlowLayout()
			horizontalLayout.scrollDirection = .horizontal
			setCollectionViewLayout(horizontalLayout, animated: false)
		}
		// Add the refresh control only if the layout is .vertical
		// Currently we don't support refresh with .horizontal -> it create layout scroll issues
		else if enableRefresh {
			let refreshControl = UIRefreshControl()
			refreshControl.backgroundColor = ColorBrand.clear
			refreshControl.tintColor = ColorBrand.clear
			refreshControl.addTarget(self, action: #selector(_refresh), for: .valueChanged)
			refreshControl.autoresizesSubviews = true
			self.refreshControl = refreshControl
			_refreshView = RefreshView(frame: self.refreshControl!.frame)
			self.refreshControl?.addSubview(_refreshView!)
		}

		// Placeholder
		emptyDataSetSource = self
		emptyDataSetDelegate = self

		if canReorderLayout {
			dragDelegate = self
			dropDelegate = self
		}
            
        if isDummyLoad { _loadDummyData(cellPrototypes: cellPrototypes ?? []) }
	}

    public func buildHeaderFooterView(
		text: String?, indexpath: IndexPath, kind: String = UICollectionView.elementKindSectionHeader,
		alignment: NSTextAlignment = .left, backgroundColor: UIColor = ColorBrand.brandGray) -> UICollectionReusableView {
		guard let view = dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: kHeaderIdentifier, for: indexpath)
			as? CustomCollectionHeaderView else { return UICollectionReusableView() }
		view.backgroundColor = backgroundColor
		view.titleLbl.text = text
		view.titleLbl.textAlignment = alignment
		view.titleLbl.textColor = _headerFooterTextColor
        if Utils.stringIsNullOrEmpty(text) { view.frame = .zero }
		return view
	}

    public func loadData(_ data: [[String: Any]]?) {
		_didLoad = true
        _isDummyLoad = false
		_cellSectionData = data ?? []
		reload()
	}

	/*
	 * Update data by finding difference between source and destination, then perform update by IndexSet
	 * dataInput must conform to Differentiable
	 * REQUIRE: kCellDifferenceIdentifierKey for the DifferenceKit to compare if 2 rows are different
	 * EX: kCellDifferenceIdentifierKey: account.accountId
	 * REQUIRE: kCellDifferenceContentKey for the DifferenceKit to compare if the same row should update UI
	 * EX: kCellDifferenceContentKey: account.hash
	 * Of course, we need to override variable hash in the loading model (in the example is account)
	 * EX:
	 * override var hash: Int {
	 *     var hasher = Hasher()
	 *     hasher.combine(accountId)
	 *     hasher.combine(accountNo)
	 *     ...
	 *     return hasher.finalize()
	 * }
	 */
    
    public func updateData(_ dataInput: [[String: Any]]?) {
		_didLoad = true
        _isDummyLoad = false
		let data = dataInput ?? []

		var sourceDataSection: [ArraySection<SectionDifferenceModel, [String: Any]>] = []
		for (idx, section) in _cellSectionData.enumerated() {
			sourceDataSection.append(ArraySection(model: .section(idx), elements: section[kSectionDataKey] as? [[String: Any]] ?? []))
		}
		var destinationDataSection: [ArraySection<SectionDifferenceModel, [String: Any]>] = []
		var destinationHeaders: [String?] = []
		for (idx, section) in data.enumerated() {
			destinationDataSection.append(ArraySection(model: .section(idx), elements: section[kSectionDataKey] as? [[String: Any]] ?? []))
			destinationHeaders.append(section[kSectionTitleKey] as? String)
		}
		let changes = StagedChangeset(source: sourceDataSection, target: destinationDataSection)
		reload(using: changes, interrupt: { $0.changeCount > kMaxDifferenceData }, setData: { updatingSections in
			var sections: [[String: Any]] = []
			for (idx, updatingSection) in updatingSections.enumerated() {
				let section = [
					kSectionTitleKey: destinationHeaders.count > idx ? destinationHeaders[idx]
						?? kEmptyString : kEmptyString,
					kSectionDataKey: updatingSection.elements
				] as [String: Any]
				sections.append(section)
			}
			self._cellSectionData = sections
			self.reloadEmptyDataSet()
		})
		reloadEmptyDataSet()
	}

    public func clear() {
		_cellSectionData.removeAll()
	}

    public func clearAndReload() {
		_cellSectionData.removeAll()
		reload()
	}

    public func reload() {
		reloadData()
	}

    public func endRefreshing() {
		refreshControl?.endRefreshing()
		_refreshView?.hideActivity()
	}

    public func updateEmptyPlaceholder(emptyDataText: String? = nil, emptyDataIconImage: UIImage? = nil, emptyDataDescription: String? = nil) {
		_emptyDataText = emptyDataText
		_emptyDataIconImage = emptyDataIconImage
		_emptyDataDescription = emptyDataDescription
	}
    
    
	@available(iOS 13.0, *)
	private func createLayout() -> UICollectionViewLayout {
		let config = UICollectionViewCompositionalLayoutConfiguration()
		config.interSectionSpacing = 16
		let compos =  UICollectionViewCompositionalLayout { [self] sectionNumber, _ -> NSCollectionLayoutSection? in
			let _gridViewType = (_gridSectionInfo[sectionNumber]?[kSectionViewType]) as! CustomNoKeyboardCollectionView.CollectionViewType
			let layoutType = ((_gridSectionInfo[sectionNumber]?[kSectionOrientationType] ?? SectionOrientation.horizontal) as! CustomNoKeyboardCollectionView.SectionOrientation)
			let cellHeight = ((_gridSectionInfo[sectionNumber]?[kCellHeightKey] ?? cellSize.height) as! Float)
			switch _gridViewType {
				case .list:
					return self.listSection(itemSize: .estimated(CGFloat(cellHeight)), layoutType: layoutType)
				case .grid:
					_ = ((_gridSectionInfo[sectionNumber]?[kCellWidthKey] ?? cellSize.width) as! Float)
					return self.gridSection(itemsizeWidth: .estimated(CGFloat(cellHeight)), itemsizeHeight: .estimated(CGFloat(cellHeight)))
				default:
					return nil
			}
		}
		compos.configuration = config
		return compos
	}
    
	@available(iOS 13.0, *)
	private func listSection( itemSize: NSCollectionLayoutDimension, layoutType: SectionOrientation ) -> NSCollectionLayoutSection {
		let itemSize = NSCollectionLayoutSize(
			widthDimension: .fractionalWidth(1.0),
			heightDimension: itemSize)
		let item = NSCollectionLayoutItem(layoutSize: itemSize)
		item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
		let groupSize = NSCollectionLayoutSize(
			widthDimension: .fractionalWidth(1.0),
			heightDimension: .estimated(0.5))
		let group = layoutType == .horizontal ? NSCollectionLayoutGroup.horizontal(
			layoutSize: groupSize,
			subitems: [item]) : NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
		let footerHeaderSize = NSCollectionLayoutSize(
			widthDimension: .fractionalWidth(1.0),
			heightDimension: .estimated(kHeaderFooterHeight))
		let header = NSCollectionLayoutBoundarySupplementaryItem(
			layoutSize: footerHeaderSize,
			elementKind: UICollectionView.elementKindSectionHeader,
			alignment: .top)
		let section = NSCollectionLayoutSection(group: group)
		section.boundarySupplementaryItems = [header]
		return section
	}
	@available(iOS 13.0, *)
	private func gridSection(itemsizeWidth: NSCollectionLayoutDimension, itemsizeHeight: NSCollectionLayoutDimension) -> NSCollectionLayoutSection {
		let itemSize = NSCollectionLayoutSize(
			widthDimension: itemsizeWidth,
			heightDimension: itemsizeHeight)
		let item = NSCollectionLayoutItem(layoutSize: itemSize)
		item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
		let groupSize = NSCollectionLayoutSize(
			widthDimension: .fractionalWidth(1.2),
			heightDimension: .fractionalHeight(0.3))
		let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
		let footerHeaderSize = NSCollectionLayoutSize(
			widthDimension: .fractionalWidth(1.0),
			heightDimension: .estimated(kHeaderFooterHeight))
		let header = NSCollectionLayoutBoundarySupplementaryItem(
			layoutSize: footerHeaderSize,
			elementKind: UICollectionView.elementKindSectionHeader,
			alignment: .top)
		let section = NSCollectionLayoutSection(group: group)
		section.boundarySupplementaryItems = [header]
		section.orthogonalScrollingBehavior = .continuous

		return section
	}
}

extension CustomNoKeyboardCollectionView: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {

	// --------------------------------------
	// MARK: <DZNEmptyDataSetSource>
	// --------------------------------------

    public func title(forEmptyDataSet _: UIScrollView!) -> NSAttributedString! {
		if !_didLoad || isLoading {
			return nil
		}
		return NSAttributedString(string: _emptyDataText ?? "", attributes: [
			NSAttributedString.Key.font: FontBrand.navBarTitleFont,
			NSAttributedString.Key.foregroundColor: ColorBrand.brandGray
		])
	}

    public func description(forEmptyDataSet _: UIScrollView!) -> NSAttributedString! {
		if !_didLoad || isLoading {
			return nil
		}
		return NSAttributedString(string: _emptyDataDescription ?? kEmptyString, attributes: [
			NSAttributedString.Key.font: FontBrand.labelFont,
			NSAttributedString.Key.foregroundColor: ColorBrand.brandGray
		])
	}

    public func image(forEmptyDataSet _: UIScrollView!) -> UIImage! {
		if !_didLoad || isLoading {
			return nil
		}
		return _emptyDataIconImage ?? UIImage()
	}

    public func backgroundColor(forEmptyDataSet _: UIScrollView!) -> UIColor! {
        ColorBrand.clear
	}

    public func spaceHeight(forEmptyDataSet _: UIScrollView!) -> CGFloat {
		16.0
	}

	// --------------------------------------
	// MARK: <DZNEmptyDataSetDelegate>
	// --------------------------------------

    public func emptyDataSetShouldDisplay(_: UIScrollView!) -> Bool {
		true
	}

    public func emptyDataSetShouldAllowTouch(_: UIScrollView!) -> Bool {
		_allowTouchEmptyDataSet
	}

    public func emptyDataSetShouldAllowScroll(_: UIScrollView!) -> Bool {
		true
	}
    
    public func emptyDataSet(_ scrollView: UIScrollView!, didTap view: UIView!) {
		_delegate?.didTapToEmptyDataSet?()
	}

    public func emptyDataSetShouldAnimateImageView(_: UIScrollView!) -> Bool {
		false
	}

}
