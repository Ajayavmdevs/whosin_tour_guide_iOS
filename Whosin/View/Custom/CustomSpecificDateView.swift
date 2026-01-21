import UIKit
import SnapKit

class CustomSpecificDateView: UIView, SpecificDateTimeCollectionCellDelegate {
    
    @IBOutlet weak var _collectionHight: NSLayoutConstraint!
    @IBOutlet weak var _customCollectionView: CustomCollectionView!
    private let kCellIdentifier = String(describing: SpecificDateTimeCollectionCell.self)
    private var dateAndTimeList: [RepeatDateAndTimeModel] = []
    public var updateDataCallback: ((_ model: [RepeatDateAndTimeModel]) -> Void)?
    private var startTime: String = kEmptyString
    private var endTime: String = kEmptyString
    
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
                                    spacing: CGSize(width: 10.0, height: 10.0),
                                    scrollDirection: .vertical,
                                    emptyDataText: kEmptyString,
                                    emptyDataIconImage: nil,
                                    delegate: self)
        _customCollectionView.showsVerticalScrollIndicator = false
        _customCollectionView.showsHorizontalScrollIndicator = false
        _customCollectionView.isScrollEnabled = false
    }
    
    private func _loadData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        
        if dateAndTimeList.isEmpty {
            cellData.append([
                kCellIdentifierKey: kCellIdentifier,
                kCellTagKey: kCellIdentifier,
                kCellObjectDataKey: RepeatDateAndTimeModel(),
                kCellClassKey: SpecificDateTimeCollectionCell.self,
                kCellHeightKey: SpecificDateTimeCollectionCell.height
            ])
        } else {
            dateAndTimeList.forEach { model in
                cellData.append([
                    kCellIdentifierKey: kCellIdentifier,
                    kCellTagKey: kCellIdentifier,
                    kCellObjectDataKey: model,
                    kCellClassKey: SpecificDateTimeCollectionCell.self,
                    kCellHeightKey: SpecificDateTimeCollectionCell.height
                ])
            }
        }
        
        let cellHeight: CGFloat = 72
        let spacing: CGFloat = 10
        let totalHeight = CGFloat(cellData.count) * cellHeight + CGFloat(cellData.count - 1) * spacing
        _collectionHight.constant = totalHeight
        _customCollectionView.layoutIfNeeded()
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _customCollectionView.loadData(cellSectionData)
    }
    
    private var _prototype: [[String: Any]]? {
        return [[kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: kCellIdentifier, kCellClassKey: SpecificDateTimeCollectionCell.self, kCellHeightKey: SpecificDateTimeCollectionCell.height]]
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func _setupUi() {
        if var view = Bundle.main.loadNibNamed("CustomSocialView", owner: self, options: nil)?.first as? UIView {
            addSubview(view)
            view.snp.makeConstraints { make in
                make.leading.trailing.top.bottom.equalToSuperview()
            }
        }
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------

    
    public func setupData(_ model: [RepeatDateAndTimeModel], startTime: String, endTime: String) {
        self.startTime = startTime
        self.endTime = endTime
        dateAndTimeList = model
        _loadData()
    }
    
    @IBAction private func _handleAddmoreEvent(_ sender: UIButton) {
        var model = RepeatDateAndTimeModel()
        self.dateAndTimeList.append(model)
        self._loadData()
        self.updateDataCallback?(self.dateAndTimeList)
    }
    
}

extension CustomSpecificDateView: CustomCollectionViewDelegate, SocialCollectionViewCellDelegate {
    
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let cell = cell as? SpecificDateTimeCollectionCell, let object = cellDict?[kCellObjectDataKey] as? RepeatDateAndTimeModel else  { return }
        cell.setupData(model: object, startDate: startTime, endDate: endTime)
        cell.delegate = self
        cell.indexPath = indexPath
        cell.callback = { [weak self] model in
            guard let self = self else { return }
            guard indexPath.row < self.dateAndTimeList.count else { return }
            self.dateAndTimeList[indexPath.row] = model ?? RepeatDateAndTimeModel()
            self.updateDataCallback?(self.dateAndTimeList)
        }
    }
    
    func didTapDeleteButton(at indexPath: IndexPath) {
        if dateAndTimeList.count == 1 {
            for dateAndTime in dateAndTimeList {
                if Utils.stringIsNullOrEmpty(dateAndTime.date) || Utils.stringIsNullOrEmpty(dateAndTime.startTime) || Utils.stringIsNullOrEmpty(dateAndTime.endTime) {
                    self.parentBaseController?.alert(message: "removed_all_dates".localized())
                    return
                }
            }
        }
        self.parentBaseController?.showCustomAlert(title: kAppName, message: "are_you_sure_remove".localized(), yesButtonTitle: "yes".localized(), noButtonTitle: "no".localized(), okHandler: { UIAlertAction in
            guard self.dateAndTimeList[indexPath.row] != nil else { return }
            self.dateAndTimeList.remove(at: indexPath.row)
            self.updateDataCallback?(self.dateAndTimeList)
        }, noHandler:  { UIAlertAction in
        })

    }

    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - 28, height: 72)
    }
    
}


