import DifferenceKit
import DZNEmptyDataSet
//import TPKeyboardAvoiding
import SkeletonView
import UIKit

@objc
public
protocol CustomNoKeyboardTableViewDelegate: AnyObject {
	@objc func setupCell(_ cell: UITableViewCell, cellDict: [String: Any]?, indexPath: IndexPath)
	@objc optional func didSelectTableCell(_ cell: UITableViewCell, sectionTitle: String?, cellDict: [String: Any]?, indexPath: IndexPath)
	@objc optional func refreshData()
	@objc optional func tableView(_ tableView: UITableView, sectionTitle: String?, cellDict: [String: Any]?, commitEditingStyle: UITableViewCell.EditingStyle, indexPath: IndexPath)
	@objc optional func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
	@objc optional func handleSearchEvent(searchContent: String)
	@objc optional func tableView(_ tableView: UITableView, cellDict: [String: Any]?, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
	@objc optional func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>)
    @objc optional func scrollViewDidScroll(_ scrollView: UIScrollView)
	@objc optional func handleHeaderActionEvent(section: Int, identifier: Int)
}


public class CustomNoKeyboardTableView: UITableView, UITableViewDataSource, UITableViewDelegate {
	weak public var proxyDataSource: UITableViewDataSource?
	weak public var proxyDelegate: UITableViewDelegate?
    public var isLoading: Bool = false

	private let kHeaderIdentifier = "header"

	private var _hasHeaderSection: Bool = false
	private var _hasFooterSection: Bool = false
	private var _isHeaderCollapsible: Bool = false
	private var _shouldReloadHeader: Bool = false
	private var _headerFooterBackgroundColor: UIColor = ColorBrand.clear
	private var _headerFooterTextColor: UIColor = ColorBrand.white
	public var _cellSectionData: [[String: Any]] = []
	private var _selectedIndexPath: IndexPath?
	private weak var _delegate: CustomNoKeyboardTableViewDelegate?
	private var _refreshView: RefreshView?
	private var _emptyDataText: String?
	private var _emptyDataIconImage: UIImage?
	private var _emptyDataDescription: String?
	private var _didLoad: Bool = false
    private var _isDummyLoad: Bool = false
	private var _reloadDataCompletionBlock: (() -> Void)?
    private var _cachedCell: [[String : Any]] = []

	// --------------------------------------
	// MARK: Life Cycle
	// --------------------------------------

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		_customInit()
	}

	override init(frame: CGRect, style: UITableView.Style) {
		super.init(frame: frame, style: style)
		_customInit()
	}

	override public func awakeFromNib() {
		super.awakeFromNib()
		_customInit()
	}

	override public func draw(_ rect: CGRect) {
		super.draw(rect)
	}

	override public func layoutSubviews() {
		super.layoutSubviews()
        guard let completion = _reloadDataCompletionBlock else { return }
        _reloadDataCompletionBlock = nil
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            completion()
        }
	}

	// --------------------------------------
	// MARK: Private
	// --------------------------------------

	private func _customInit() {
        isSkeletonable = true
		_cellSectionData = []
		dataSource = self
		delegate = self
		showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
		keyboardDismissMode = .onDrag
		if #available(iOS 15.0, *) {
			sectionHeaderTopPadding = 10
		}
	}
    
    public func _loadDummyData(cellPrototypes: [[String: Any]], dummyLoadCount: Int) {
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
            } else if dummyLoadCount > 0 {
                for _ in 0...dummyLoadCount {
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

	// --------------------------------------
	// MARK: <UITableViewDataSource>
	// --------------------------------------

    public func numberOfSections(in _: UITableView) -> Int {
		let numSection = _cellSectionData.count
		return numSection
	}

    public func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let sectionData = _cellSectionData[section][kSectionDataKey] as? [Any] else { return 0 }
		let numRows = sectionData.count
		if !_isHeaderCollapsible {
			return numRows
		} else {
			let sectionTitle = _cellSectionData[section][kSectionTitleKey] as? String ?? kEmptyString
			let collapsed = _cellSectionData[section][kSectionCollapsedKey] as? Bool ?? false
			return !Utils.stringIsNullOrEmpty(sectionTitle) ? collapsed ? numRows : 0 : numRows
		}
	}

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
		let sectionData = _cellSectionData[indexPath.section][kSectionDataKey] as? [Any]
		let cellDict = sectionData![indexPath.row] as? [String: Any]
        let cellIdentifier = cellDict![kCellIdentifierKey] as? String
        let isStoreInCache = cellDict![kCellAllowCacheKey] as? Bool ?? false
        let catchKey = cellDict![kCellCacheKey] as? UITableViewCell
        var cell: UITableViewCell
        if isStoreInCache {

            if let cacheKey = catchKey {
                cell = cacheKey
                _delegate?.setupCell(cacheKey, cellDict: cellDict, indexPath: indexPath)
            } else {
                let cacheKey = "\(indexPath.section)-\(indexPath.row)"
                let cachedData = _cachedCell.first{ $0.keys.contains{ $0 == cacheKey }}
                if let _cachedData = cachedData {
                    cell = _cachedData[cacheKey] as! UITableViewCell
                } else {
                    cell = Bundle.main.loadNibNamed(cellIdentifier ?? kEmptyString, owner: self, options: nil)?.first as! UITableViewCell
                    _cachedCell.append(["\(indexPath.section)-\(indexPath.row)" : cell])
                    _delegate?.setupCell(cell, cellDict: cellDict, indexPath: indexPath)
                }
            }
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: (cellIdentifier)!, for: indexPath)
            _delegate?.setupCell(cell, cellDict: cellDict, indexPath: indexPath)
        }
		return cell
	}

    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		if proxyDataSource != nil {
			return proxyDataSource?.tableView?(self, canEditRowAt: indexPath) ?? false
		}
		return ((_delegate?.tableView?(tableView, canEditRowAt: indexPath)) != nil)
	}

    public func tableView(_ tableView: UITableView, commit commitEditingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		guard let sectionData = _cellSectionData[indexPath.section][kSectionDataKey] as? [Any] else { return }
		let sectionTitle = _cellSectionData[indexPath.section][kSectionTitleKey] as? String ?? kEmptyString
		let cellDict = sectionData[indexPath.row] as? [String: Any]
		_delegate?.tableView?(tableView, sectionTitle: sectionTitle, cellDict: cellDict, commitEditingStyle: commitEditingStyle, indexPath: indexPath)
	}

    public func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		if proxyDelegate != nil {
			return proxyDelegate?.tableView?(tableView, trailingSwipeActionsConfigurationForRowAt: indexPath)
		} else {
			let sectionData = _cellSectionData[indexPath.section][kSectionDataKey] as? [Any]
			let cellDict = sectionData![indexPath.row] as? [String: Any]
			return _delegate?.tableView?(tableView, cellDict: cellDict, trailingSwipeActionsConfigurationForRowAt: indexPath)
		}
	}

	// --------------------------------------
	// MARK: <UITableViewDelegate>
	// --------------------------------------

    public func tableView(_: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		if _hasHeaderSection {
			if proxyDelegate != nil {
                return (proxyDelegate?.tableView?(self, heightForHeaderInSection: section)) ?? 0.0
			}
			let sectionTitle = _cellSectionData[section][kSectionTitleKey] as? String ?? kEmptyString
			let sectionSearchable = _cellSectionData[section][kSectionSearchInputKey] as? Bool ?? false
			let sectionHeaderheightConfig = _cellSectionData[section][kSectionHeightKey] as? CGFloat ?? kHeaderFooterHeight
			let height = sectionSearchable ? kHeaderSearchInnputLayoutHeight : sectionHeaderheightConfig
			return Utils.stringIsNullOrEmpty(sectionTitle) ? .zero : height
		}
		if proxyDelegate != nil {
            return proxyDelegate?.tableView?(self, heightForHeaderInSection: section) ?? .zero
		}
		return .zero
	}

    public func tableView(_: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		if proxyDelegate != nil {
			return proxyDelegate?.tableView?(self, heightForFooterInSection: section) ?? .zero
		}
		return .zero
	}

    public func tableView(_: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		if _hasHeaderSection {
			if proxyDelegate != nil {
				return (proxyDelegate?.tableView?(self, viewForHeaderInSection: section))
			}
			let sectionTitle = _cellSectionData[section][kSectionTitleKey] as? String ?? kEmptyString
			let collapsed = _cellSectionData[section][kSectionCollapsedKey] as? Bool ?? false
			let textAlignment = _cellSectionData[section][kSectionTextAlignmentKey] as? NSTextAlignment ?? .left
			let isBarView = _cellSectionData[section][kSectionbarViewKey] as? Bool ?? true
			let sectionSearchable = _cellSectionData[section][kSectionSearchInputKey] as? Bool ?? false
			let sectionShowRightInfo = _cellSectionData[section][kSectionShowRightInforAsActionButtonKey] as? Bool ?? false
			let sectionNeumorphismMode = _cellSectionData[section][kSectionNeumorphismKey] as? Bool ?? false
			let sectionRightTextInfo = _cellSectionData[section][kSectionRightInfoKey] as? String ?? kEmptyString
			let sectionRightTextColor = _cellSectionData[section][kSectionRightTextColorKey] as? UIColor ?? .white
            let sectionRightTextBgColor = _cellSectionData[section][kSectionRightTextBgColor] as? UIColor ?? .white
            let rightBtnAction = _cellSectionData[section][kSectionGestureKey] as? UIGestureRecognizer ?? UIGestureRecognizer()
			if sectionSearchable {
				let placeholder = _cellSectionData[section][kSectionSearchInputPlaceholderKey] as? String ?? kEmptyString
				let btnLbl = _cellSectionData[section][kSectionSearchInputButtonLblKey] as? String ?? kEmptyString
				return buildHeaderSearchInputView(text: sectionTitle, section: section, placeholder: placeholder, buttonLbl: btnLbl)
			}
            return Utils.stringIsNullOrEmpty(sectionTitle) ? nil : buildHeaderFooterView(text: sectionTitle, section: section, alignment: textAlignment, collapsed: collapsed, barView: isBarView, rightTitleText: sectionRightTextInfo, rightTitleColor: sectionRightTextColor, rightButtonBackgroundColor: sectionRightTextBgColor, isNeumorphismView: sectionNeumorphismMode, showRightButton: sectionShowRightInfo,rightBtnAction: rightBtnAction)
		}
		if proxyDelegate != nil {
			return proxyDelegate?.tableView?(self, viewForHeaderInSection: section)
		}
		return UIView.init(frame: .zero)
        
	}

    public func tableView(_: UITableView, viewForFooterInSection _: Int) -> UIView? {
		UIView.init(frame: .zero)
	}

    public func tableView(_: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		let sectionData = _cellSectionData[indexPath.section][kSectionDataKey] as? [Any]
		let cellDict = sectionData?[indexPath.row] as? [String: Any]
		let height = cellDict![kCellHeightKey] as! CGFloat
		return height
	}

    public func tableView(_: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		if proxyDelegate != nil {
			proxyDelegate?.tableView?(self, didEndDisplaying: cell, forRowAt: indexPath)
		}
	}

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		guard let sectionData = _cellSectionData[indexPath.section][kSectionDataKey] as? [Any] else { return }
		let sectionTitle = _cellSectionData[indexPath.section][kSectionTitleKey] as? String ?? kEmptyString
        guard let cellDict = sectionData[indexPath.row] as? [String: Any] else { return }
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
		_selectedIndexPath = indexPath
        _delegate?.didSelectTableCell?(cell, sectionTitle: sectionTitle, cellDict: cellDict, indexPath: indexPath)
	}
    

	// --------------------------------------
	// MARK: <ScrollViewDelegate>
	// --------------------------------------
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        _delegate?.scrollViewDidScroll?(scrollView)
    }

	// --------------------------------------
	// MARK: Public
	// --------------------------------------
    
    public var isDummyLoad: Bool {
        _isDummyLoad
    }

    public var isDataEmpty: Bool {
		if _cellSectionData.count == 0 {
			return true
		} else {
			if let sectionData = _cellSectionData.first?[kSectionDataKey] as? [Any],
			   sectionData.count == 0 {
				return true
			} else {
				return false
			}
		}
	}

    public var isRefreshing: Bool {
		refreshControl != nil && refreshControl!.isRefreshing
	}

    public var rowCount: Int {
		var count = 0
		_cellSectionData.forEach { sectionData in
			let values: [Any] = sectionData[kSectionDataKey] as! [Any]
			count += values.count
		}
		return count
	}

    public func setup(
		cellPrototypes: [[String: Any]]?, hasHeaderSection: Bool = false, hasFooterSection: Bool = false,
		isHeaderCollapsible: Bool = false, headerFooterBackgroundColor: UIColor = ColorBrand.brandGray,
		headerFooterTextColor: UIColor = ColorBrand.white,
        shouldUpdateHeader: Bool = false,
        isDummyLoad: Bool = true,
        dummyLoadCount: Int = 0,
		enableRefresh: Bool = false, isShowRefreshing: Bool = true, emptyDataText: String? = nil, emptyDataIconImage: UIImage? = nil,
        emptyDataDescription: String? = nil, delegate: CustomNoKeyboardTableViewDelegate) {
		// Assign values
		_delegate = delegate
		_hasHeaderSection = hasHeaderSection
		_hasFooterSection = hasFooterSection
		_headerFooterBackgroundColor = headerFooterBackgroundColor
		_headerFooterTextColor = headerFooterTextColor
		_isHeaderCollapsible = isHeaderCollapsible
		_emptyDataText = emptyDataText
		_emptyDataIconImage = emptyDataIconImage
		_emptyDataDescription = emptyDataDescription
		_shouldReloadHeader = shouldUpdateHeader
		if !_hasFooterSection { tableFooterView = UIView(frame: CGRect.zero) }

		// Register all the prototype UITableViewCell for the current UITableView
		for cellPrototype in cellPrototypes ?? [] {
            guard let nibName = cellPrototype[kCellNibNameKey] as? String else { return }
            guard let identifier = cellPrototype[kCellIdentifierKey] as? String else { return }
            register(UINib(nibName: nibName, bundle: nil), forCellReuseIdentifier: identifier)
		}

		// Add the refresh control
		if enableRefresh {
			let refreshControl = UIRefreshControl()
			refreshControl.backgroundColor = ColorBrand.clear
			refreshControl.tintColor = ColorBrand.clear
			refreshControl.addTarget(self, action: #selector(_refresh), for: .valueChanged)
			refreshControl.autoresizesSubviews = true
			self.refreshControl = refreshControl
            if isShowRefreshing {
                _refreshView = RefreshView(frame: self.refreshControl!.frame)
                self.refreshControl?.addSubview(_refreshView!)
            }
		}

		// Placeholder
		emptyDataSetSource = self
		emptyDataSetDelegate = self
            
            if isDummyLoad { _loadDummyData(cellPrototypes: cellPrototypes ?? [], dummyLoadCount: dummyLoadCount) }
	}

    public func buildHeaderSearchInputView(
		text: String?, section: Int, placeholder: String = kEmptyString,
		buttonLbl: String = kEmptyString) -> SearchInputTableViewHeader {
		let header = dequeueReusableHeaderFooterView(withIdentifier: kHeaderIdentifier) as? SearchInputTableViewHeader
			?? SearchInputTableViewHeader(reuseIdentifier: kHeaderIdentifier, placeholder: placeholder, backgroundColor: _headerFooterBackgroundColor)
		header.titleLbl.text = text
		header.searchBtn.setTitle(buttonLbl, for: .normal)
		header.section = section
		header.delegate = self
		return header
	}

    public func buildHeaderFooterView(
		text: String?, section: Int, alignment: NSTextAlignment = .left,
        collapsed: Bool = false, barView: Bool = true, rightTitleText: String?, rightTitleColor: UIColor = .white, rightButtonBackgroundColor: UIColor = .white, isNeumorphismView: Bool = false, showRightButton: Bool = false,rightBtnAction: UIGestureRecognizer) -> CollapsibleTableViewHeader {
		let header =  CollapsibleTableViewHeader(
				reuseIdentifier: kHeaderIdentifier,
				collapsible: _isHeaderCollapsible,
				collapsed: collapsed,
                backgroundColor: .clear, rightButtonColor: rightButtonBackgroundColor, showRightButton: showRightButton)

        header.headerTitleLbl.text = text
		header.headerTitleLbl.textAlignment = alignment
		header.headerTitleLbl.textColor = _headerFooterTextColor
		header.section = section
		header.delegate = self
		header.rightTitleLbl.isHidden = barView
		header.rightTitleLbl.text = rightTitleText
		header.barView.isHidden = barView
		if !collapsed {
			header.arrowImgView.image = UIImage(named: "icon_arrow_down")
		} else {
			header.arrowImgView.image = UIImage(named: "icon_arrow_up")
		}
		header.rightBtn.isHidden = !showRightButton
		if showRightButton {
			header.rightBtn.setTitle(rightTitleText, for: .normal)
			header.rightBtn.setTitleColor(rightTitleColor, for: .normal)
           // header.rightBtn.addGestureRecognizer(rightBtnAction)
		}

		return header
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
    
    public func updateData(_ dataInput: [[String: Any]]?, animation: RowAnimation = UITableView.RowAnimation.fade) {

		_didLoad = true
        _isDummyLoad = false
		let data = dataInput ?? []

		var source: [ArraySection<SectionDifferenceModel, [String: Any]>] = []
		for (idx, section) in _cellSectionData.enumerated() {
			source.append(ArraySection(model: .section(idx), elements: section[kSectionDataKey] as? [[String: Any]] ?? []))
		}

		var target: [ArraySection<SectionDifferenceModel, [String: Any]>] = []
		for (idx, section) in data.enumerated() {
			target.append(ArraySection(model: .section(idx), elements: section[kSectionDataKey] as? [[String: Any]] ?? []))
		}

		let changes = StagedChangeset(source: source, target: target)
		reload(using: changes, with: animation, interrupt: { $0.changeCount > kMaxDifferenceData }, setData: { [weak self] updatingSections in
            guard let self = self else { return }
			var sections: [[String: Any]] = []
			for (idx, updatingSection) in updatingSections.enumerated() {
				var section = data.count > idx ? data[idx] : [:]
				section[kSectionDataKey] = updatingSection.elements
                if self._shouldReloadHeader {
					if section[kSectionReloadKey] as? Bool ?? false {
						reloadSections(NSIndexSet(index: idx) as IndexSet, with: .none)
					}
				}
				sections.append(section)

			}
			self._cellSectionData = sections
			self.reloadEmptyDataSet()
		})
	}
    
    public func update() {
        beginUpdates()
        endUpdates()
    }
    
    public func fetchAndInsertBanner(isMainView: Bool = true) {
        ADSETTING.requestPromotionBanner { [weak self] bannerCells in
            guard let self = self else { return }

            guard !bannerCells.isEmpty else { return }

            var cellSectionData = self._cellSectionData
            if cellSectionData.isEmpty {
                cellSectionData = [[kSectionTitleKey: kEmptyString, kSectionDataKey: []]]
                return
            }
            
            guard var cellData = cellSectionData[0][kSectionDataKey] as? [[String: Any]],
                  !cellData.allSatisfy({
                      let identifier = $0[kCellIdentifierKey] as? String
                      return identifier == "EmptyDataCell" || identifier == "LoadingCell"
                  }) else {
                return
            }
            
            if var cellData = cellSectionData[0][kSectionDataKey] as? [[String: Any]] {
                cellData.removeAll { $0[kCellTagKey] as? String == "promotionBanner" }

                if cellData.count < 5 {
                    if let firstBanner = bannerCells.first {
                        cellData.append(firstBanner)
                    }
                } else {
                    var insertOffset = 0
                    for (index, banner) in bannerCells.enumerated() {
                        let insertIndex = (index + 1) * 5 + insertOffset
                        if insertIndex <= cellData.count {
                            cellData.insert(banner, at: insertIndex)
                            insertOffset += 1
                        } else {
                            break
                        }
                    }
                }

                cellSectionData[0][kSectionDataKey] = cellData
                DISPATCH_ASYNC_MAIN {
                    self.updateData(cellSectionData)
                }
            }
        }
    }

    
    func updateCellAt(indexPath: IndexPath?) {
        guard let indexPath = indexPath else { return }
        reloadRows(at: [indexPath], with: .none)
    }
    
    func updateFooterSpinner(didShow: Bool = true) {
        guard didShow else {
            (self.tableFooterView as? RefreshView)?.hideActivity()
            self.tableFooterView = UIView(frame: .zero)
            sectionFooterHeight = .zero
            return
        }
        
        let refreshView = RefreshView(frame: CGRect(origin: .zero, size: CGSize(width: bounds.width, height: kTableFooterSpinnerDefaultHeight)))
        refreshView.showActivity()
        tableFooterView = refreshView
        sectionFooterHeight = kTableFooterSpinnerDefaultHeight
    }

    public func clear() {
		_cellSectionData.removeAll()
		reload()
	}

    public func clearAndReload() {
		_cellSectionData.removeAll()
		reload()
	}

    public func reload() {
		reloadData()
	}

    public func reload(completion: @escaping () -> Void) {
		_reloadDataCompletionBlock = completion
		reloadData()
	}
    
    public func startRefreshing() {
        _refreshView?.showActivity()
    }

    public func endRefreshing() {
		refreshControl?.endRefreshing()
		_refreshView?.hideActivity()
	}
    
    public func updateEmptyDataText (title: String?, description: String? , image:UIImage? = nil) {
		_emptyDataText = title
		_emptyDataDescription = description
        _emptyDataIconImage = image
	}
    
    public func scrollToBottom(isAnimated:Bool = true) {
        guard rowCount != 0 else { return }
        DISPATCH_ASYNC_MAIN {
            let indexPath = IndexPath(row: self.numberOfRows(inSection:  self.numberOfSections-1) - 1, section: self.numberOfSections - 1)
            if self.hasRowAtIndexPath(indexPath: indexPath) { self.scrollToRow(at: indexPath, at: .bottom, animated: isAnimated) }
        }
    }

    public func scrollToTop(isAnimated:Bool = true) {
        guard rowCount != 0 else { return }
        DISPATCH_ASYNC_MAIN {
            let indexPath = IndexPath(row: 0, section: 0)
            if self.hasRowAtIndexPath(indexPath: indexPath) { self.scrollToRow(at: indexPath, at: .top, animated: isAnimated) }
        }
    }

    public func hasRowAtIndexPath(indexPath: IndexPath) -> Bool {
        return indexPath.section < self.numberOfSections && indexPath.row < self.numberOfRows(inSection: indexPath.section)
    }
}

extension CustomNoKeyboardTableView: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {

	// --------------------------------------
	// MARK: <DZNEmptyDataSetSource>
	// --------------------------------------

    public func offset(forEmptyDataSet scrollView: UIScrollView!) -> CGPoint {
        CGPoint(x: UIScreen.main.bounds.width/2, y: 50)
    }
    
    public func title(forEmptyDataSet _: UIScrollView!) -> NSAttributedString! {
		if !_didLoad || isLoading {
			return nil
		}
		return NSAttributedString(string: _emptyDataText ?? "There is no data available", attributes: [
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
		isDataEmpty
	}

    public func emptyDataSetShouldAllowTouch(_: UIScrollView!) -> Bool {
		false
	}

    public func emptyDataSetShouldAllowScroll(_: UIScrollView!) -> Bool {
		true
	}

    public func emptyDataSetShouldAnimateImageView(_: UIScrollView!) -> Bool {
		false
	}
}

extension CustomNoKeyboardTableView: CollapsibleTableViewHeaderDelegate {
    
    public func actionBtnCallBack(_ header: CollapsibleTableViewHeader, section: Int) {
		guard let id = _cellSectionData[section][kSectionIdentifierKey] as? Int else {return}
		_delegate?.handleHeaderActionEvent?(section: section, identifier: id)
	}

    public func toggleSection(_ header: CollapsibleTableViewHeader, section: Int) {
		guard var collapsed = _cellSectionData[section][kSectionCollapsedKey] as? Bool else { return }
		collapsed = !collapsed
		_cellSectionData[section][kSectionCollapsedKey] = collapsed
		header.setCollapsed(collapsed)
		beginUpdates()
		reloadSections(NSIndexSet(index: section) as IndexSet, with: .none)
		if collapsed {
			DISPATCH_ASYNC_MAIN_AFTER(0.15) {[weak self] in
				let indexPath = IndexPath(row: 0, section: section)
				self?.scrollToRow(at: indexPath, at: .top, animated: true)
			}
		}
		endUpdates()
	}
}

extension CustomNoKeyboardTableView: SearchInputTableViewHeaderDelegate {
	@objc public func handleSearchBtnEvent(_: SearchInputTableViewHeader, section _: Int, searchContent: String) {
		_delegate?.handleSearchEvent?(searchContent: searchContent)
	}
}
