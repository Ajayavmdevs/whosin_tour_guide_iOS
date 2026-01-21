import UIKit

class SelectPrefrenceCell: UITableViewCell {
    
    @IBOutlet weak var _collectionView: UICollectionView!
    private var _prefrences: [CommonSettingsModel] = APPSETTING.cuisine + APPSETTING.music + APPSETTING.feature
    public var selectedFilter : [CommonSettingsModel] = []
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat { UITableView.automaticDimension }
    
    // --------------------------------------
    // MARK: Life-Cycle
    // --------------------------------------
    
    override func awakeFromNib() {
        super.awakeFromNib()
        disableSelectEffect()
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
    
    public func setupData() {
        setupCollectionView(_collectionView)
    }
}


extension SelectPrefrenceCell : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        _prefrences.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagViewCell", for: indexPath) as! TagViewCell
        let isSelected = selectedFilter.contains(where: { $0.id == _prefrences[indexPath.row].id })
        cell.setupPrefrenceData(_prefrences[indexPath.row] , isSelected: isSelected)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let index = indexPath.row
        if let selectedIndex = selectedFilter.firstIndex(where: { $0.id == _prefrences[index].id }) {
            selectedFilter.remove(at: selectedIndex)
        } else {
            if let selectedCuisineItem = _prefrences.first(where: { $0.title == _prefrences[index].title }) {
                selectedFilter.append(selectedCuisineItem)
            }
        }
        _collectionView.reloadData()
        CompletePromoterProfileVC.params["preferences"] = selectedFilter.map({ $0.id })
    }
    
    func collectionView(_ collectionView: UICollectionView, layout
                        collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let item = _prefrences[indexPath.item].title
        let width = item.size(withAttributes: [NSAttributedString.Key.font: FontBrand.SFregularFont(size: 16)]).width + 12
        return CGSize(width: width < 40 ? 50 : width , height: 30.0)
    }
}

