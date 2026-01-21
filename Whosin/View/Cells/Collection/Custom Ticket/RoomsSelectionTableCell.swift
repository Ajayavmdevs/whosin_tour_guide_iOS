import UIKit

class RoomsSelectionTableCell: UITableViewCell {

    @IBOutlet private weak var _collectionView: CustomNoKeyboardCollectionView!
    @IBOutlet private weak var _roomTitle: CustomLabel!
    @IBOutlet private weak var _adultAge: CustomLabel!
    @IBOutlet private weak var _adultStepper: UILabel!
    @IBOutlet private weak var _adultView: UIView!
    @IBOutlet private weak var _childView: UIView!
    @IBOutlet private weak var _childAge: CustomLabel!
    @IBOutlet private weak var _childStepper: UILabel!
    @IBOutlet private weak var _removeBtn: UIButton!
    @IBOutlet private weak var _collectionHeight: NSLayoutConstraint!

    class var height: CGFloat { UITableView.automaticDimension }
    
    // MARK: - State
    private var adultCount: Int = 1
    private var childCount: Int = 0

    private let minAdults: Int = 1
    private let maxAdults: Int = 1000
    private let minChildren: Int = 0
    private let maxChildren: Int = 1000
    private var childAges: [Int] = []

    // MARK: - Callbacks

    var onCountsChanged: ((Int, Int) -> Void)?
    var onRemoveItem: (() -> Void)?
    var onCollectionHeightChanged: ((CGFloat) -> Void)?
    var onChildAgeChanged: ((Int, Int) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        disableSelectEffect()
        configureCollectionView()
        applyCountsToUI()
        recalcCollectionHeight(animated: false)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        adultCount = max(minAdults, min(maxAdults, adultCount))
        childCount = max(minChildren, min(maxChildren, childCount))
        applyCountsToUI()
        _collectionView.loadData(_buildChildSectionsData())
        recalcCollectionHeight(animated: false)
    }

    // MARK: - Public API
    func configure(roomTitle: String?, adults: Int, children: Int, childAges: [Int]) {
        _roomTitle.text = roomTitle
        _removeBtn.isHidden = roomTitle == LANGMANAGER.localizedString(forKey: "room", arguments: ["value": "1"])
        adultCount = max(minAdults, min(maxAdults, adults))
        childCount = max(minChildren, min(maxChildren, children))
        self.childAges = childAges
        applyCountsToUI()
        _collectionView.loadData(_buildChildSectionsData())
        recalcCollectionHeight(animated: false)
//        notifyCountsChanged()
    }

    // MARK: - Setup
    private func configureCollectionView() {
        _collectionView.setup(
            cellPrototypes: [[
                kCellNibNameKey: "ChildAgeCollectionCell",
                kCellIdentifierKey: "ChildAgeCollectionCell",
                kCellClassKey: ChildAgeCollectionCell.self,
                kCellHeightKey: ChildAgeCollectionCell.height
            ]],
            hasHeaderSection: false,
            headerBackgroundColor: ColorBrand.brandGray,
            headerFooterTextColor: ColorBrand.white,
            enableRefresh: false,
            columns: 2,
            rows: 1,
            edgeInsets: UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0),
            spacing: CGSize(width: 8, height: 8),
            scrollDirection: .vertical,
            canReorderLayout: false,
            customHeader: false,
            isDummyLoad: false,
            headerPrototypes: [:],
            emptyDataText: nil,
            emptyDataIconImage: nil,
            emptyDataDescription: nil,
            allowTouchEmptyDataSet: false,
            delegate: self,
            complexLayout: false,
            gridSectionInfo: [:]
        )
        _collectionView.loadData(_buildChildSectionsData())
    }

    private func _buildChildSectionsData() -> [[String: Any]] {
        var cells: [[String: Any]] = []
        if childCount > 0 {
            for i in 0..<childCount {
                let age = i < childAges.count ? childAges[i] : -1
                let ageStr: String = (age >= 0) ? "\(age)" : "-1"
                cells.append([
                    kCellIdentifierKey: "ChildAgeCollectionCell",
                    kCellClassKey: ChildAgeCollectionCell.self,
                    kCellHeightKey: ChildAgeCollectionCell.height,
                    "childIndex": i,
                    "yrs": ageStr
                ])
            }
        }
        return [[
            kSectionTitleKey: "",
            kSectionDataKey: cells
        ]]
    }

    // MARK: - UI Updates
    private func applyCountsToUI() {
        _adultStepper.text = "\(adultCount)"
        _childStepper.text = "\(childCount)"
        _childView.isHidden = BOOKINGMANAGER.ticketModel?.allowChild == false
        _collectionView.isHidden = BOOKINGMANAGER.ticketModel?.allowChild == false
    }

    private func notifyCountsChanged() {
        onCountsChanged?(adultCount, childCount)
    }

    private func recalcCollectionHeight(animated: Bool) {
        let targetHeight: CGFloat
        if childCount == 0 {
            targetHeight = 0
        } else {
            let width = _collectionView.bounds.width
            var columns = 2
            if width < 320 { columns = 1 }

            let insets: CGFloat = 8 + 8
            let lineSpacing: CGFloat = 8

            let rows = Int(ceil(Double(max(childCount, 1)) / Double(max(columns, 1))))
            let itemHeight: CGFloat = ChildAgeCollectionCell.height
            targetHeight = insets + CGFloat(rows) * itemHeight + CGFloat(max(0, rows - 1)) * lineSpacing
        }

        _collectionHeight.constant = targetHeight
        if animated {
            UIView.animate(withDuration: 0.25) {
                self.contentView.layoutIfNeeded()
            }
        } else {
            self.contentView.layoutIfNeeded()
        }
        if animated {
            onCollectionHeightChanged?(targetHeight)
        }
    }

    // MARK: - Actions
    @IBAction private func _handleDeleteRoom(_ sender: UIButton) {
        onRemoveItem?()
    }
    
    
    @IBAction private func _childCounterMinusEvent(_ sender: UIButton) {
        guard childCount > minChildren else { return }
        childCount -= 1
        applyCountsToUI()
        _collectionView.loadData(_buildChildSectionsData())
        recalcCollectionHeight(animated: true)
        notifyCountsChanged()
    }

    @IBAction private func _childCounterPlusEvent(_ sender: UIButton) {
        guard childCount < maxChildren else { return }
        childCount += 1
        applyCountsToUI()
        _collectionView.loadData(_buildChildSectionsData())
        recalcCollectionHeight(animated: true)
        notifyCountsChanged()
    }

    @IBAction private func _adultCounterPlusEvent(_ sender: UIButton) {
        guard adultCount < maxAdults else { return }
        adultCount += 1
        applyCountsToUI()
        notifyCountsChanged()
    }

    @IBAction private func _adultCounterMinusEvent(_ sender: UIButton) {
        guard adultCount > minAdults else { return }
        adultCount -= 1
        applyCountsToUI()
        notifyCountsChanged()
    }
}

// Removed extension RoomsSelectionTableCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout as instructed

extension RoomsSelectionTableCell: CustomNoKeyboardCollectionViewDelegate {
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? ChildAgeCollectionCell {
            let idx = (cellDict?["childIndex"] as? Int) ?? indexPath.item
            cell.setup(" \("childTitle".localized()) \(idx + 1)", yrs: cellDict?["yrs"] as? String ?? "select_age".localized())
            cell.onAgePicked = { [weak self] age in
                self?.onChildAgeChanged?(idx, age)
            }
        }
    }

    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        var columns = 2
        if width < 320 { columns = 1 }
        let totalInsets: CGFloat = 8 + 8
        let interitem: CGFloat = 8 * CGFloat(max(columns - 1, 0))
        let available = max(0, width - totalInsets - interitem)
        let itemWidth = floor(available / CGFloat(max(columns, 1)))
        return CGSize(width: itemWidth, height: ChildAgeCollectionCell.height)
    }
}
