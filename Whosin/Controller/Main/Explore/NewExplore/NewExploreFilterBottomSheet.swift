import UIKit

class NewExploreFilterBottomSheet: PanBaseViewController {

    @IBOutlet private weak var _cityCollectionView: UICollectionView!
    @IBOutlet private weak var _categoryCollectionView: UICollectionView!
    @IBOutlet private weak var _cityCollectionHieghtConstarint: NSLayoutConstraint!
    @IBOutlet private weak var _categoryCollectionHieghtConstarint: NSLayoutConstraint!
    @IBOutlet private weak var _citiesBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var _citiesTitle: UILabel!
    @IBOutlet private weak var _categoryTitle: UILabel!
    public var selectedFilter : [CategoryDetailModel] = []
    private var params:[String:Any] = [:]
    public  var filterCallback: (([CategoryDetailModel]) -> Void)?
    private var cities : [CategoryDetailModel] = APPSETTING.cityList ?? []
    private var categories : [CategoryDetailModel] = APPSETTING.exploreCategories ?? []

    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
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
        let cityCount = cities.count
        let cityLines = min(3, max(1, (cityCount - 1) / 3 + 1))
        _cityCollectionHieghtConstarint.constant = cityCount == 0 ? 0 : CGFloat(cityLines * 40)
        _citiesTitle.isHidden = cityCount == 0
        _citiesBottomConstraint.constant = cityCount == 0 ? 0 : 20
        
        let categoryCount = categories.count
        let categoryLines = min(3, max(1, (categoryCount - 1) / 3 + 1))
        _categoryCollectionHieghtConstarint.constant = categoryCount == 0 ? 0 : CGFloat(categoryLines * 40)
        _categoryTitle.isHidden = categoryCount == 0
        
        _cityCollectionView.reloadData()
        _categoryCollectionView.reloadData()

        self.view.layoutIfNeeded()

    }
    
    override func setupUi() {
        hideNavigationBar()
        setupCollectionView(_cityCollectionView)
        setupCollectionView(_categoryCollectionView)
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
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

    @IBAction func _handleBackEvent(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func _handleNextEvent(_ sender: CustomGradientBorderButton) {
        dismiss(animated: true) {
            self.filterCallback?(self.selectedFilter)
        }
    }
}

// ------------------------------
// MARK: TagListViewDelegate
// ------------------------------

extension NewExploreFilterBottomSheet: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView ==  _cityCollectionView {
            return cities.count
        } else {
            return categories.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagViewCell", for: indexPath) as! TagViewCell
        if collectionView ==  _cityCollectionView {
            let isSelected = selectedFilter.contains(where: { $0.id == cities[indexPath.row].id })
            cell.setupExploreFilter(cities[indexPath.row], isSelected: isSelected, isFromCity: true)
            return cell
        } else {
            let isSelected = selectedFilter.contains(where: { $0.id == categories[indexPath.row].id })
            cell.setupExploreFilter(categories[indexPath.row] , isSelected: isSelected)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let index = indexPath.row
        if collectionView ==  _cityCollectionView {
            if let selectedIndex = selectedFilter.firstIndex(where: { $0.id == cities[index].id }) {
                selectedFilter.remove(at: selectedIndex)
            } else {
                if let selectedMusicItem = cities.first(where: { $0.name == cities[index].name }) {
                    selectedFilter.append(selectedMusicItem)
                }
            }
            _cityCollectionView.reloadData()
        } else {
            if let selectedIndex = selectedFilter.firstIndex(where: { $0.id == categories[index].id }) {
                selectedFilter.remove(at: selectedIndex)
            } else {
                if let selectedCuisineItem = categories.first(where: { $0.title == categories[index].title }) {
                    selectedFilter.append(selectedCuisineItem)
                }
            }
            _categoryCollectionView.reloadData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout
        collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView ==  _cityCollectionView {
            let item = cities[indexPath.item].name
            let width = item.size(withAttributes: [NSAttributedString.Key.font: FontBrand.SFregularFont(size: 16)]).width + 12
            return CGSize(width: width < 40 ? 50 : width , height: 30.0)
        } else {
            let item = categories[indexPath.item].title
            let width = item.size(withAttributes: [NSAttributedString.Key.font: FontBrand.SFregularFont(size: 16)]).width + 12
            return CGSize(width: width < 40 ? 50 : width , height: 30.0)
        }
    }
}
