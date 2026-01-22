import UIKit

class TicketFeaturesTableCell: UITableViewCell {

    @IBOutlet private weak var _cellTitleText: CustomLabel!
    @IBOutlet weak var _collectionView: UICollectionView!
    @IBOutlet private weak var _collectionViewHieghtConstraint: NSLayoutConstraint!
    private var _model: [CommonSettingsModel] = []

    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat { UITableView.automaticDimension }

    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
        disableSelectEffect()
        _setupUi()
    }

    // --------------------------------------
    // MARK: Private
    // --------------------------------------

    private func _setupUi() {
        _collectionView.register(UINib(nibName: "YachtFeatureCollectionCell", bundle: nil), forCellWithReuseIdentifier: "YachtFeatureCollectionCell")
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 5
        layout.sectionInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        
        _collectionView.collectionViewLayout = layout
        _collectionView.showsHorizontalScrollIndicator = false
        _collectionView.delegate = self
        _collectionView.dataSource = self
        _collectionView.reloadData()
        
    }
    
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setupData(model: [CommonSettingsModel], title: String = "Features") {
        _cellTitleText.text = title
            if model.count <= 4 {
                _collectionViewHieghtConstraint.constant = 30
            } else if model.count <= 8 {
                _collectionViewHieghtConstraint.constant = 70
            } else if model.count <= 12 {
                _collectionViewHieghtConstraint.constant = 110
            } else {
                _collectionViewHieghtConstraint.constant = 135
            }
        _model = model
        if !_model.isEmpty {
            _setupUi()
        }
    }

}


extension TicketFeaturesTableCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("Model Count: \(_model.count)") // Debugging purpose
        return _model.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "YachtFeatureCollectionCell", for: indexPath) as! YachtFeatureCollectionCell
        print("Setting up cell for item at index \(indexPath.row)")
        cell.setup(_model[indexPath.row])
        cell._bgView.cornerRadius = 9
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let item = _model[indexPath.item].feature
        let isIcon = Utils.stringIsNullOrEmpty(_model[indexPath.row].icon)
        let width = item.size(withAttributes: [NSAttributedString.Key.font: FontBrand.SFregularFont(size: 14)]).width + (isIcon ? 18 : 30)
        let size = CGSize(width: width < 40 ? 50 : width, height: 30)
        print("Cell Size for item \(indexPath.row): \(size)") // Debugging purpose
        return size
    }
}
