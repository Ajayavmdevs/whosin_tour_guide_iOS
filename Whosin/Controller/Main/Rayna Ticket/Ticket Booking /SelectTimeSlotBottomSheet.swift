import UIKit

class SelectTimeSlotBottomSheet: ChildViewController {
    
    @IBOutlet private weak var _timeSlotCollectionView: UICollectionView!
    @IBOutlet private weak var _timeSlotHight: NSLayoutConstraint!
    @IBOutlet private weak var _bottomView: UIView!
    @IBOutlet private weak var _bgView: UIView!
    @IBOutlet private weak var _emptyDataImage: UIImageView!
    @IBOutlet private weak var _emptyDataText: UILabel!
    @IBOutlet private weak var _selectedDate: CustomLabel!
    @IBOutlet private weak var _nextBtn: CustomActivityButton!
    
    private var _timeSlots : [TourTimeSlotModel] = []
    private let indicator = MLTontiatorView()

    public var selectedFilter : TourTimeSlotModel? = nil
    public var selectedTourOption: TourOptionsModel?
    public var callback: ((_ timeSlot: TourTimeSlotModel?) -> Void)?


    
    // --------------------------------------
    // MARK: Life cycle
    // --------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _requestTimeSlot()
        setupUi()
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    override func setupUi() {
        hideNavigationBar()
        indicator.spinnerSize = .MLSpinnerSizeSmall
        indicator.spinnerColor = ColorBrand.brandPink
        _bgView.addSubview(indicator)
        indicator.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        _timeSlotCollectionView.showsHorizontalScrollIndicator = false
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        _timeSlotCollectionView.collectionViewLayout = layout
        _timeSlotCollectionView.register(UINib(nibName: "AvailabelTimeSlotCollectionCell", bundle: nil), forCellWithReuseIdentifier: "AvailabelTimeSlotCollectionCell")
        
        _timeSlotCollectionView.delegate = self
        _timeSlotCollectionView.dataSource = self
        _timeSlotCollectionView.reloadData()
        let  option = BOOKINGMANAGER.bookingModel.tourDetails.first(where: { $0.optionId == "\(selectedTourOption?.tourOptionId ?? 0)" })
        _selectedDate.text = "Date: \(option?.tourDate ?? "")"
    }
    
    private func _requestTimeSlot() {
        indicator.startAnimating()
        let  option = BOOKINGMANAGER.bookingModel.tourDetails.first(where: { $0.optionId == "\(selectedTourOption?.tourOptionId ?? 0)" })
        let selected = Utils.dateToStringWithTimezone(Date(), format: kFormatDateLocal)
        let contractId = Utils.stringIsNullOrEmpty(BOOKINGMANAGER.ticketModel?.contractId) ? BOOKINGMANAGER.ticketModel?.tourData?.contractId ?? kEmptyString : BOOKINGMANAGER.ticketModel?.contractId ?? kEmptyString
        let dates = Utils.stringIsNullOrEmpty(option?.tourDate) ? Utils.dateToString(Utils.stringToDate(selected, format: kFormatDateLocal), format: kFormatDate) : option?.tourDate ?? kEmptyString

        let params: [String: Any] = [
            "tourId": selectedTourOption?.tourId ?? 0,
            "tourOptionId": selectedTourOption?.tourOptionId ?? kEmptyString,
            "contractId": contractId,
            "date": dates,
            "transferId": option?.transferId ?? selectedTourOption?.transferId ?? kEmptyString,
            "noOfAdult": option?.adult ?? "0",
            "noOfChild": option?.child ?? "0",
            "noOfInfant": option?.infant  ?? "0"
        ]
        WhosinServices.raynaTourTimeSlots(params: params) { [weak self] container, error in
            guard let self = self else {
                self?.showEmptyData(true)
                return
            }
            self.hideHUD(error: error)
            indicator.stopAnimating()
            indicator.removeFromSuperview()
            guard let data = container?.data else {
                showEmptyData(true)
                return
            }
            let filterdData = data.filter({ $0.available != 0 })
            self._nextBtn.isEnabled = !filterdData.isEmpty
            self._nextBtn.backgroundColor = filterdData.isEmpty ? ColorBrand.sectionTitleColor : ColorBrand.brandPink
            self.showEmptyData(filterdData.isEmpty)
            self._timeSlots = filterdData
            self._timeSlotCollectionView.reloadData()
        }
    }
    
    private func showEmptyData(_ isShow: Bool = false) {
        _emptyDataText.isHidden = !isShow
        _emptyDataImage.isHidden = !isShow
        _timeSlotCollectionView.isHidden = isShow
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    @IBAction private func _handleBackEvent(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction private func _handleNextEvent(_ sender: CustomActivityButton) {
        guard let selectedFilter = selectedFilter else {
            alert(message: "time_slot_alert".localized())
            return
        }
        
        dismiss(animated: true) {
            self.callback?(self.selectedFilter)
        }
    }
    
}

extension SelectTimeSlotBottomSheet: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return _timeSlots.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AvailabelTimeSlotCollectionCell", for: indexPath) as! AvailabelTimeSlotCollectionCell
        let isSelected = selectedFilter?.timeSlotId == _timeSlots[indexPath.row].timeSlotId
        cell.setupDataTime(_timeSlots[indexPath.row] , isSelected: isSelected)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let index = indexPath.row
        if selectedFilter?.timeSlotId == _timeSlots[indexPath.row].timeSlotId {
            selectedFilter = nil
        } else {
            selectedFilter = _timeSlots[index]
        }
        _timeSlotCollectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout
        collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        let totalSpacing = layout.sectionInset.left + layout.sectionInset.right + layout.minimumInteritemSpacing
        let availableWidth = collectionView.frame.width - totalSpacing
        let width = availableWidth / 2
        return CGSize(width: width, height: 40.0)
    }
}
