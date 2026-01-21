import UIKit

class ExploreFilterBottomSheet: PanBaseViewController {

    @IBOutlet private weak var _cuisineCollectionView: UICollectionView!
    @IBOutlet private weak var _featureCollectionView: UICollectionView!
    @IBOutlet private weak var _musicCollectionView: UICollectionView!
    @IBOutlet private weak var _cuisineCollectionHieghtConstarint: NSLayoutConstraint!
    @IBOutlet private weak var _featureCollectionHieghtConstarint: NSLayoutConstraint!
    @IBOutlet private weak var _musicCollectionHieghtConstarint: NSLayoutConstraint!
    public var selectedFilter : [CommonSettingsModel] = []
    private var params:[String:Any] = [:]
    private var cuisine : [CommonSettingsModel] = APPSETTING.cuisine
    private var music : [CommonSettingsModel] = APPSETTING.music
    private var feature : [CommonSettingsModel] = APPSETTING.feature
    public  var filterCallback: (([CommonSettingsModel]) -> Void)?

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
        _featureCollectionHieghtConstarint.constant = 120
        _musicCollectionHieghtConstarint.constant = 120
        _cuisineCollectionHieghtConstarint.constant = 120
        
        _featureCollectionView.reloadData()
        _musicCollectionView.reloadData()
        _cuisineCollectionView.reloadData()

        self.view.layoutIfNeeded()

    }
    
    override func setupUi() {
        hideNavigationBar()
        setupCollectionView(_cuisineCollectionView)
        setupCollectionView(_featureCollectionView)
        setupCollectionView(_musicCollectionView)
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

extension ExploreFilterBottomSheet: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView ==  _musicCollectionView {
            return music.count
        }else if collectionView == _featureCollectionView {
            return feature.count
        } else {
            return cuisine.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagViewCell", for: indexPath) as! TagViewCell
        if collectionView ==  _musicCollectionView {
            let isSelected = selectedFilter.contains(where: { $0.id == music[indexPath.row].id })
            cell.setupData(music[indexPath.row], isSelected: isSelected)
            return cell
        }else if collectionView == _featureCollectionView {
            let isSelected = selectedFilter.contains(where: { $0.id == feature[indexPath.row].id })
            cell.setupData(feature[indexPath.row], isSelected: isSelected)
            return cell
        } else {
            let isSelected = selectedFilter.contains(where: { $0.id == cuisine[indexPath.row].id })
            cell.setupData(cuisine[indexPath.row] , isSelected: isSelected)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let index = indexPath.row
        if collectionView ==  _musicCollectionView {
            if let selectedIndex = selectedFilter.firstIndex(where: { $0.id == music[index].id }) {
                selectedFilter.remove(at: selectedIndex)
            } else {
                if let selectedMusicItem = music.first(where: { $0.title == music[index].title }) {
                    selectedFilter.append(selectedMusicItem)
                }
            }
            _musicCollectionView.reloadData()
        }else if collectionView == _featureCollectionView {
            if let selectedIndex = selectedFilter.firstIndex(where: { $0.id == feature[index].id }) {
                selectedFilter.remove(at: selectedIndex)
            } else {
                if let selectedFeatureItem = feature.first(where: { $0.title == feature[index].title }) {
                    selectedFilter.append(selectedFeatureItem)
                }
            }
            _featureCollectionView.reloadData()
        } else {
            if let selectedIndex = selectedFilter.firstIndex(where: { $0.id == cuisine[index].id }) {
                selectedFilter.remove(at: selectedIndex)
            } else {
                if let selectedCuisineItem = cuisine.first(where: { $0.title == cuisine[index].title }) {
                    selectedFilter.append(selectedCuisineItem)
                }
            }
            _cuisineCollectionView.reloadData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout
        collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView ==  _musicCollectionView {
            let item = music[indexPath.item].title
            let width = item.size(withAttributes: [NSAttributedString.Key.font: FontBrand.SFregularFont(size: 16)]).width + 12
            return CGSize(width: width < 40 ? 50 : width , height: 30.0)
        }else if collectionView == _featureCollectionView {
            let item = feature[indexPath.item].title
            let width = item.size(withAttributes: [NSAttributedString.Key.font: FontBrand.SFregularFont(size: 16)]).width + 12
            return CGSize(width: width < 40 ? 50 : width, height: 30.0)
        } else {
            let item = cuisine[indexPath.item].title
            let width = item.size(withAttributes: [NSAttributedString.Key.font: FontBrand.SFregularFont(size: 16)]).width + 12
            return CGSize(width: width < 40 ? 50 : width , height: 30.0)
        }
    }
}


class HorizontalTagsFlowLayout: UICollectionViewFlowLayout {

    // MARK: - Properties

    override var collectionViewContentSize: CGSize {
        return contentSize
    }

    // MARK: - Private properties

    private var layoutAttributesCache: [UICollectionViewLayoutAttributes] = []
    private var contentSize: CGSize = CGSize.zero

    // MARK: - Functions

    override func prepare() {
        super.prepare()

        guard let collectionView = collectionView else {
            return
        }

        layoutAttributesCache = layoutAttributes()

        let itemCount = collectionView.numberOfItems(inSection: 0)
        let rowsCount = min(3, max(1, (itemCount - 1) / 3 + 1))
        
        let itemHeight = layoutAttributesCache.first?.frame.height ?? 0.0
        var rowFrames = rowFrames(with: rowsCount, itemHeight: itemHeight)

        for attributes in layoutAttributesCache {
            var minimalRowFrame = rowFrames.first ?? .zero
            var minimalRowIndex = 0

            for (index, rowFrame) in rowFrames.enumerated() {
                if rowFrame.maxX < minimalRowFrame.maxX {
                    minimalRowFrame = rowFrame
                    minimalRowIndex = index
                }
            }

            attributes.frame.origin = CGPoint(x: minimalRowFrame.maxX, y: minimalRowFrame.minY)

            rowFrames[minimalRowIndex] = CGRect(x: minimalRowFrame.minX,
                                                y: minimalRowFrame.minY,
                                                width: minimalRowFrame.width + attributes.frame.width + minimumInteritemSpacing,
                                                height: minimalRowFrame.height)
        }

        var maximumContentWidth: CGFloat = 0.0
        for rowFrame in rowFrames {
            if rowFrame.maxX > maximumContentWidth {
                maximumContentWidth = rowFrame.maxX
            }
        }

        contentSize = CGSize(width: maximumContentWidth, height: collectionView.frame.size.height)
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return layoutAttributesCache.filter {
            return $0.frame.intersects(rect)
        }
    }

    override open func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return layoutAttributesCache[indexPath.item]
    }

    // MARK: - Private functions

    private func rowFrames(with count: Int, itemHeight: CGFloat) -> [CGRect] {
        var rowFrames: [CGRect] = []
        let rowCount = min(count, 3) // Ensure only 3 rows

        for index in 0..<rowCount {
            let rect = CGRect(x: sectionInset.left,
                              y: (itemHeight * CGFloat(index)) + (minimumLineSpacing * CGFloat(index)) + sectionInset.top,
                              width: 0.0,
                              height: itemHeight + minimumLineSpacing)
            rowFrames.append(rect)
        }

        return rowFrames
    }

    private func layoutAttributes() -> [UICollectionViewLayoutAttributes] {
        var allAttributes: [UICollectionViewLayoutAttributes] = []
        guard let collectionView = collectionView,
              let delegate = collectionView.delegate as? UICollectionViewDelegateFlowLayout,
              collectionView.numberOfSections > 0 else {
            return allAttributes
        }

        for item in 0..<collectionView.numberOfItems(inSection: 0) {
            let indexPath = IndexPath(item: item, section: 0)
            let itemSize = delegate.collectionView?(collectionView, layout: self, sizeForItemAt: indexPath) ?? .zero
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = CGRect(x: 0.0, y: 0.0, width: itemSize.width, height: itemSize.height)
            attributes.zIndex = item
            allAttributes.append(attributes)
        }

        return allAttributes
    }
}

