import UIKit

class YachHourlyPackageCell: UITableViewCell {
    
    @IBOutlet weak var _selectDateBtn: UIButton!
    @IBOutlet weak var _titleView: UILabel!
    @IBOutlet private weak var _collectionView: CustomCollectionView!
    @IBOutlet private weak var _collectionViewHieghtConstraint: NSLayoutConstraint!
    private let kCellIdentifier = String(describing: YachHourlyCollectionCell.self)
    private static var _selectedPackage: YachtPackgeModel?
    private static var _selectedDuration: Int?

    static var selectedPackage: YachtPackgeModel? {
        get {
            return _selectedPackage
        }
        set(newValue) {
            _selectedPackage = newValue
        }
    }
    
    static var selectedDuration: Int? {
        get {
            return _selectedDuration
        }
        set(newValue) {
            _selectedDuration = newValue
        }
    }
    // --------------------------------------
    // MARK: Life - Cycle
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
        disableSelectEffect()
        setupUI()
    }
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    static var height: CGFloat { UITableView.automaticDimension }

    // --------------------------------------
    // MARK: Private
    // --------------------------------------

    private func setupUI() {
        _selectDateBtn.titleLabel?.font = FontBrand.SFboldFont(size: 15)
        _collectionView.setup(cellPrototypes: _prototypes,
                              hasHeaderSection: false,
                              enableRefresh: false,
                              columns: 1,
                              rows: 5,
                              scrollDirection: .horizontal,
                              emptyDataText: nil,
                              emptyDataIconImage: nil,
                              delegate: self)
        _collectionView.showsVerticalScrollIndicator = false
        _collectionView.showsHorizontalScrollIndicator = false
    }
    
    private var _prototypes: [[String: Any]]? {
        return [ [kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: kCellIdentifier, kCellClassKey: YachHourlyCollectionCell.self, kCellHeightKey: YachHourlyCollectionCell.height]]
    }

    private func _loadDataPackage(_ model: [YachtPackgeModel]) {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        
        model.forEach { packages in
            cellData.append([
                kCellIdentifierKey: self.kCellIdentifier,
                kCellTagKey: packages.id,
                kCellObjectDataKey: packages.detached(),
                kCellClassKey: YachHourlyCollectionCell.self,
                kCellHeightKey: YachHourlyCollectionCell.height
            ])
        }
        self._collectionViewHieghtConstraint.constant = CGFloat(cellData.count) * YachHourlyCollectionCell.height
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        self._collectionView.loadData(cellSectionData)
    }
    
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setupPackage(_ model: [YachtPackgeModel], type: String) {
        _titleView.text = "available_packages".localized()
        _loadDataPackage(model)
    }
    
    private func _updateDate(date: Date?, time: TimePeriod) {
        let dates = Utils.dateToStringWithTimezone(date, format: kFormatDateLocal)
        let apiDate = Utils.dateToStringWithTimezone(date, format: kFormatDate)
        _selectDateBtn.setTitle("\(dates) (\(time.startTime) - \(time.endTime))", for: .normal)
        _selectDateBtn.borderColor = ColorBrand.brandSky
        _selectDateBtn.borderWidth = 1
        _selectDateBtn.backgroundColor = .clear
    }
    
    @IBAction func _handleSelectDateTimeEvent(_ sender: UIButton) {
        let controller = INIT_CONTROLLER_XIB(DateTimePickerVC.self)
        controller.date = nil
        controller.didUpdateCallback = { [weak self] date, time in
            guard let self = self else { return }
            self._updateDate(date: date, time: time)
        }
        self.parentViewController?.presentAsPanModal(controller: controller)
    }
    
}

extension YachHourlyPackageCell: CustomCollectionViewDelegate {
    
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let cell = cell as? YachHourlyCollectionCell else { return }
        if let object = cellDict?[kCellObjectDataKey] as? YachtPackgeModel {
            cell.setupPackage(model: object, isHourly: true)
            cell.updateDataCallback = { model, duration in
                guard let model = model else { return }
                YachHourlyPackageCell._selectedPackage = model
                YachHourlyPackageCell._selectedDuration = duration
            }
        }
    }
    
    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: YachHourlyCollectionCell.height)
    }
    
}
