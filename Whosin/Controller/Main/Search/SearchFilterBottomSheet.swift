import UIKit
import CoreLocation
import RangeSeekSlider

class SearchFilterBottomSheet: BaseViewController {

    @IBOutlet weak var _radiusLabel: CustomLabel!
    @IBOutlet weak var _priceRangeLabel: CustomLabel!
    @IBOutlet weak var _priceRangeSlider: RangeSeekSlider!
    @IBOutlet weak var _addressLabel: CustomLabel!
    @IBOutlet weak var _lcoationAddressVeiw: UIView!
    @IBOutlet weak var _lcoationPickerView: UIView!
    @IBOutlet weak var _radiousSlider: UISlider!
    @IBOutlet weak var _radiusRangeLabel: CustomLabel!
    @IBOutlet weak var _themesCollectionHeightConstaint: NSLayoutConstraint!
    @IBOutlet weak var _themesCollectionView: UICollectionView!
    @IBOutlet weak var _categoriesHeightConstarint: NSLayoutConstraint!
    @IBOutlet weak var _categoriesCollectionView: UICollectionView!
    @IBOutlet private weak var _cuisineCollectionView: UICollectionView!
    @IBOutlet private weak var _featureCollectionView: UICollectionView!
    @IBOutlet private weak var _musicCollectionView: UICollectionView!
    @IBOutlet private weak var _cuisineCollectionHieghtConstarint: NSLayoutConstraint!
    @IBOutlet private weak var _featureCollectionHieghtConstarint: NSLayoutConstraint!
    @IBOutlet private weak var _musicCollectionHieghtConstarint: NSLayoutConstraint!
    public var filters: [CommonSettingsModel] = []
    public var commanFilters: SettingsModel?
    public var selectedLocaiton: [String: Any] = [:]
    public var filterCallback: ((_ filters: [CommonSettingsModel], _ location: [String: Any]) -> Void)?
    let locationManager = CLLocationManager()

    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        updateLocationViews()
        setupUi()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setUpHeight()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setUpHeight()
    }
    
    private func setUpHeight() {
    }
    
    override func setupUi() {
        hideNavigationBar()
        setupCollectionView(_cuisineCollectionView)
        setupCollectionView(_featureCollectionView)
        setupCollectionView(_musicCollectionView)
        setupCollectionView(_categoriesCollectionView)
        setupCollectionView(_themesCollectionView)
        _priceRangeSlider.minValue = 0.0
        _priceRangeSlider.maxValue = 2000.0
        _priceRangeSlider.selectedMinValue = 0.0
        _priceRangeSlider.selectedMaxValue = 1000.0
        
        _priceRangeSlider.delegate = self
        if let radious = filters.first(where: { $0.type == "maxDistance" }) {
            _radiousSlider.value = Float(radious.price)
            _radiusRangeLabel.text = "\(Int(radious.price)) Km"
            _radiusLabel.text = "\(Int(radious.price)) Km"
        } else {
            _radiousSlider.value = 0.0
            _radiusRangeLabel.text = "0 Km"
            _radiusLabel.text = kEmptyString
        }
        
        if let price = filters.first(where: { $0.type == "price" }) {
            _priceRangeSlider.selectedMinValue = CGFloat(price.price)
            _priceRangeSlider.selectedMaxValue = CGFloat(price.endPrice)
            _priceRangeLabel.attributedText = "Price Range: D\(price.price)- D\(price.endPrice)".applyingDirhamFont(defaultFont: _priceRangeLabel.font)
        } else {
            _priceRangeLabel.text = kEmptyString
            _priceRangeSlider.selectedMinValue = 0.0
            _priceRangeSlider.selectedMaxValue = 2000.0
            
        }
        
        updateLocationViews()
        
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    func updateLocationViews() {
        let authorizationStatus: CLAuthorizationStatus
        if #available(iOS 14.0, *) {
            authorizationStatus = locationManager.authorizationStatus
        } else {
            authorizationStatus = CLLocationManager.authorizationStatus()
        }
        if !selectedLocaiton.isEmpty {
            self._addressLabel.text = selectedLocaiton["address"] as? String
        } else {
            self.selectedLocaiton["address"] = "Current location"
            self.selectedLocaiton["lat"] = APPSETTING.latitude
            self.selectedLocaiton["long"] = APPSETTING.longitude
            self._addressLabel.text = "Current location"
        }
        if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
            self._lcoationPickerView.isHidden = true
            self._lcoationAddressVeiw.isHidden = false
        } else {
            self._lcoationPickerView.isHidden = false
            self._lcoationAddressVeiw.isHidden = true
        }
    }

    private func setupCollectionView(_ collectionView: UICollectionView){
        let layout = HorizontalTagsFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.collectionViewLayout = layout
        collectionView.register(UINib(nibName: "TagViewCell", bundle: nil), forCellWithReuseIdentifier: "TagViewCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.reloadData()
    }
    
    // --------------------------------------
    // MARK: Service
    // --------------------------------------


    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    @IBAction func _handlePicklocationEvent(_ sender: CustomButton) {
        let vc = INIT_CONTROLLER_XIB(LocationPickerVC.self)
        vc.modalPresentationStyle = .overFullScreen
        vc.isRestricted = false
        vc.completion = { pickedLocationItem in
            self.selectedLocaiton["address"] = pickedLocationItem?.address ?? ""
            self._addressLabel.text = pickedLocationItem?.address ?? ""
            if !Utils.stringIsNullOrEmpty(pickedLocationItem?.address) {
                self._lcoationPickerView.isHidden = true
                self._lcoationAddressVeiw.isHidden = false
            }
            if let coordinate = pickedLocationItem?.coordinate {
                self.selectedLocaiton["lat"] = coordinate.latitude
                self.selectedLocaiton["long"] = coordinate.longitude
            }
        }
        present(vc, animated: true)
    }
    
    @IBAction func _handleBackEvent(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func _handleRadiusChangeEvent(_ sender: UISlider) {
        _radiusRangeLabel.text = "\(Int(sender.value)) Km"
        _radiusLabel.text = Int(sender.value) > 0 ? "\(Int(sender.value)) Km" : kEmptyString
    }
    
    @IBAction func _handleNextEvent(_ sender: CustomGradientBorderButton) {
        filters.removeAll(where: { $0.type == "maxDistance" })
        if _radiousSlider.value > 0 {
            let radiusModel = CommonSettingsModel()
            radiusModel.title = "Radius: \(Int(_radiousSlider.value)) Km"
            radiusModel.id = "maxDistance"
            radiusModel.type = "maxDistance"
            radiusModel.price = Int(_radiousSlider.value)
            filters.append(radiusModel)
        }
        dismiss(animated: true) {
            self.filterCallback?(self.filters, self.selectedLocaiton)
        }
    }
}

// ------------------------------
// MARK: TagListViewDelegate
// ------------------------------

extension SearchFilterBottomSheet: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case _musicCollectionView:
            return commanFilters?.music.count ?? 0
        case _featureCollectionView:
            return commanFilters?.features.count ?? 0
        case _categoriesCollectionView:
            return commanFilters?.categories.count ?? 0
        case _themesCollectionView:
            return commanFilters?.themes.count ?? 0
        case _cuisineCollectionView:
            return commanFilters?.cuisines.count ?? 0
        default:
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagViewCell", for: indexPath) as! TagViewCell
        let item: CommonSettingsModel
        switch collectionView {
        case _musicCollectionView:
            item = commanFilters?.music[indexPath.row] ?? CommonSettingsModel()
            item.type = "music"
        case _featureCollectionView:
            item = commanFilters?.features[indexPath.row] ?? CommonSettingsModel()
            item.type = "features"
        case _themesCollectionView:
            item = commanFilters?.themes[indexPath.row] ?? CommonSettingsModel()
            item.type = "themes"
        case _categoriesCollectionView:
            item = commanFilters?.categories[indexPath.row] ?? CommonSettingsModel()
            item.type = "categories"
        case _cuisineCollectionView:
            item = commanFilters?.cuisines[indexPath.row] ?? CommonSettingsModel()
            item.type = "cuisines"
        default:
            return UICollectionViewCell()
        }
        
        let isSelected = filters.contains(where: { $0.id == item.id })
        cell.setupData(item, isSelected: isSelected)
        return cell
    }

    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var selectedArray: [CommonSettingsModel]
        switch collectionView {
        case _musicCollectionView:
            selectedArray = commanFilters?.music ?? []
        case _featureCollectionView:
            selectedArray = commanFilters?.features ?? []
        case _themesCollectionView:
            selectedArray = commanFilters?.themes ?? []
        case _categoriesCollectionView:
            selectedArray = commanFilters?.categories ?? []
        case _cuisineCollectionView:
            selectedArray = commanFilters?.cuisines ?? []
        default:
            return
        }
        
        let selectedItem = selectedArray[indexPath.row]
        if let index = filters.firstIndex(where: { $0.id == selectedItem.id }) {
            filters.remove(at: index)
        } else {
            filters.append(selectedItem)
        }
        
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout
        collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemsArray: [CommonSettingsModel]
        switch collectionView {
        case _musicCollectionView:
            itemsArray = commanFilters?.music ?? []
        case _featureCollectionView:
            itemsArray = commanFilters?.features ?? []
        case _categoriesCollectionView:
            itemsArray = commanFilters?.categories ?? []
        case _themesCollectionView:
            itemsArray = commanFilters?.themes ?? []
        case _cuisineCollectionView:
            itemsArray = commanFilters?.cuisines ?? []
        default:
            return CGSize.zero
        }
        let item = itemsArray[indexPath.item].title
        let width = item.size(withAttributes: [NSAttributedString.Key.font: FontBrand.SFregularFont(size: 16)]).width + 12
        return CGSize(width: width < 40 ? 50 : width, height: 30.0)
    }
}

extension SearchFilterBottomSheet : RangeSeekSliderDelegate {
    func rangeSeekSlider(_ slider: RangeSeekSlider, didChange minValue: CGFloat, maxValue: CGFloat) {
        if slider === _priceRangeSlider {
            print("Standard slider updated. Min Value: \(minValue) Max Value: \(maxValue)")
            filters.removeAll(where: { $0.type == "price" })
            if maxValue > 0 {
                _priceRangeLabel.attributedText = "Price Range: D\(Int(minValue))- D\(Int(maxValue))".applyingDirhamFont(defaultFont: _priceRangeLabel.font)
                let radiusModel = CommonSettingsModel()
                radiusModel.title = "Price Range: \(Int(minValue)) - \(Int(maxValue))"
                radiusModel.id = "price"
                radiusModel.type = "price"
                radiusModel.price = Int(minValue)
                radiusModel.endPrice = Int(maxValue)
                filters.append(radiusModel)
            } else {
                _priceRangeLabel.text = kEmptyString
            }
        }
    }

    func didStartTouches(in slider: RangeSeekSlider) {
        print("did start touches")
    }

    func didEndTouches(in slider: RangeSeekSlider) {
        print("did end touches")
        
    }
}
