import UIKit
import ExpandableLabel

class YachtOfferListTableCell: UITableViewCell {

    @IBOutlet weak var _titleText: UILabel!
    @IBOutlet weak var _featuresView: CustomFeaturesView!
    @IBOutlet weak var _gallaryView: CustomGallaryView!
    @IBOutlet weak var _contactAgentView: UIView!
    @IBOutlet weak var _buyNowView: UIView!
    @IBOutlet weak var _discription: ExpandableLabel!
    private var features: [CommonSettingsModel] = []

    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    static var height: CGFloat { UITableView.automaticDimension }

    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
        disableSelectEffect()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // --------------------------------------
    // MARK: public
    // --------------------------------------

    public func setupData(_ model: YachtOfferDetailModel, yacht: YachtDetailModel) {
        _gallaryView.setupData(offer: model, yacht: yacht)
        if !yacht.features.isEmpty {
            _featuresView.setupData(model: yacht.features.toArrayDetached(ofType: CommonSettingsModel.self))
        }
        _featuresView.isHidden = yacht.features.isEmpty
        _discription.text = model.descriptions
        _titleText.text = model.title
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------

    @IBAction private func _handleBuyNowEvent(_ sender: UIButton) {
    }
    
    @IBAction private func _handleContactAgentEvent(_ sender: UIButton) {
    }
}

extension YachtOfferListTableCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return features.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "YachtFeatureCollectionCell", for: indexPath) as! YachtFeatureCollectionCell
        cell.setup(features[indexPath.row])
        cell._bgView.cornerRadius = 12
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout
        collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let item = features[indexPath.item].feature
        let isIcon = Utils.stringIsNullOrEmpty(features[indexPath.row].icon)
        let width = item.size(withAttributes: [NSAttributedString.Key.font: FontBrand.SFregularFont(size: 14)]).width + (isIcon ? 20 : 38)
        return CGSize(width: width < 40 ? 50 : width , height: 24)
    }

}
