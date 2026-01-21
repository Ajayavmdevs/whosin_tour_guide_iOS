import UIKit
import SnapKit

class CustomTimeAvailabilities: UIView {
    
    @IBOutlet weak var _collectionHight: NSLayoutConstraint!
    @IBOutlet weak var _customCollectionView: CustomCollectionView!
    private let kCellIdentifier = String(describing: AvailbleTimeSlotesCell.self)
    private var slots: [TimeSlot] = [TimeSlot(fromDate: kEmptyString, tillDate: kEmptyString)]
    public var callback: (() -> Void)?
    public var updateCallback: ((_ model: [TimeSlot]) -> Void)?

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
        _setupCollectionView()
    }

    private func _setupCollectionView() {
        _customCollectionView.setup(cellPrototypes: _prototype,
                              hasHeaderSection: false,
                              enableRefresh: false,
                              columns: 1,
                              rows: 1,
                              scrollDirection: .vertical,
                              emptyDataText: "There is no data available",
                              emptyDataIconImage: UIImage(named: "empty_following"),
                              delegate: self)
        _customCollectionView.showsVerticalScrollIndicator = false
        _customCollectionView.showsHorizontalScrollIndicator = false
    }
    
    private func _loadData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()

        if !slots.isEmpty {
            slots.forEach { img in
                cellData.append([
                    kCellIdentifierKey: kCellIdentifier,
                    kCellTagKey: kCellIdentifier,
                    kCellObjectDataKey: img,
                    kCellClassKey: AvailbleTimeSlotesCell.self,
                    kCellHeightKey: AvailbleTimeSlotesCell.height
                ])
            }
        }

        _collectionHight.constant = CGFloat(cellData.count * 32)
        _customCollectionView.layoutIfNeeded()
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _customCollectionView.loadData(cellSectionData)

    }
    
    private var _prototype: [[String: Any]]? {
        return [[kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: kCellIdentifier, kCellClassKey: AvailbleTimeSlotesCell.self, kCellHeightKey: AvailbleTimeSlotesCell.height]]
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------

    private func _setupUi() {
        if var view = Bundle.main.loadNibNamed("CustomTimeAvailabilities", owner: self, options: nil)?.first as? UIView {
            addSubview(view)
            view.snp.makeConstraints { make in
                make.leading.trailing.top.bottom.equalToSuperview()
            }
        }
    }
    
    public func setupData() {
        _loadData()
    }

    @IBAction private func _handleAddmoreEvent(_ sender: UIButton) {
        slots.append(TimeSlot(fromDate: kEmptyString, tillDate: kEmptyString))
        callback?()
    }
    
}

extension CustomTimeAvailabilities: CustomCollectionViewDelegate {
    
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? AvailbleTimeSlotesCell {
            cell.timeSlotCallback = { slot in
                self.slots[indexPath.row] = slot
                self.updateCallback?(self.slots)
                self._loadData()
            }
        }
    }
    
    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - 28, height: 30)
    }
    
}



