import Foundation
import RealmSwift
import UIKit
import SnapKit


class CustomFeaturesView: UIView {
    
    @IBOutlet weak var _collectionView: UICollectionView!
    @IBOutlet private weak var _collectionViewHieghtConstraint: NSLayoutConstraint!
    private var _features: [CommonSettingsModel] = []

    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
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
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------

    private func _setupUi() {
        if var view = Bundle.main.loadNibNamed("CustomFeaturesView", owner: self, options: nil)?.first as? UIView {
            addSubview(view)
            view.snp.makeConstraints { make in
                make.leading.trailing.top.bottom.equalToSuperview()
            }
        }
    }

    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    public func setupData(model: [CommonSettingsModel], isOffer: Bool = false) {
        if isOffer {
            if model.count <= 4 {
                _collectionViewHieghtConstraint.constant = 30
            } else if model.count <= 8 {
                _collectionViewHieghtConstraint.constant = 60
            } else if model.count <= 12 {
                _collectionViewHieghtConstraint.constant = 90
            } else {
                _collectionViewHieghtConstraint.constant = 115
            }
        } else {
            _collectionViewHieghtConstraint.constant = model.isEmpty ? 0 : model.count > 4 ? 60 : 30
        }
        _features = model
        _loadData(model)
    }
    
    
    private func _loadData(_ data: [CommonSettingsModel]) {
        let layout = HorizontalTagsFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 5
        layout.sectionInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        _collectionView.showsHorizontalScrollIndicator = false
        _collectionView.showsVerticalScrollIndicator = false
        _collectionView.collectionViewLayout = layout
        _collectionView.register(UINib(nibName: "YachtFeatureCollectionCell", bundle: nil), forCellWithReuseIdentifier: "YachtFeatureCollectionCell")
        _collectionView.delegate = self
        _collectionView.dataSource = self
        _collectionView.reloadData()

    }
}


extension CustomFeaturesView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return _features.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "YachtFeatureCollectionCell", for: indexPath) as! YachtFeatureCollectionCell
        cell.setup(_features[indexPath.row])
        cell._bgView.cornerRadius = 9
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout
        collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let item = _features[indexPath.item].feature
        let isIcon = Utils.stringIsNullOrEmpty(_features[indexPath.row].icon)
        let width = item.size(withAttributes: [NSAttributedString.Key.font: FontBrand.SFregularFont(size: 14)]).width + (isIcon ? 18 : 30)
        return CGSize(width: width < 40 ? 50 : width , height: 24)
    }

}
