import UIKit


class YachtCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var _collecitonHeight: NSLayoutConstraint!
    @IBOutlet weak var _collectionView: UICollectionView!
    @IBOutlet weak var _priceText: UILabel!
    @IBOutlet weak var _priceView: GradientView!
    @IBOutlet weak var _contactAgent: UIView!
    @IBOutlet weak var _buyNowView: UIView!
    @IBOutlet weak var _yachtAbout: UILabel!
    @IBOutlet weak var _yachtName: UILabel!
    @IBOutlet private weak var _coverImage: UIImageView!
    @IBOutlet weak var _mainContainerView: GradientView!
    @IBOutlet weak var _venueInfoView: CustomVenueInfoView!
    private var _yachtDetail: YachtDetailModel?
    private var features: [CommonSettingsModel] = []
    public var callBack: ((_ height: CGFloat) -> Void)?

    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat { 400 }

    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUi()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
      super.touchesBegan(touches, with: event)
      isTouched = true
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
      super.touchesEnded(touches, with: event)
      isTouched = false
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
      super.touchesCancelled(touches, with: event)
      isTouched = false
    }
    
    public var isTouched: Bool = false {
      didSet {
        var transform = CGAffineTransform.identity
        if isTouched { transform = transform.scaledBy(x: 0.96, y: 0.96) }
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: {
          self.transform = transform
        }, completion: nil)
      }
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func setupUi() {
        DISPATCH_ASYNC_MAIN_AFTER(0.02) {
            self._mainContainerView.cornerRadius = 10
            self._priceView.roundCorners(corners: [.topRight, .bottomLeft], radius: 15)
        }
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setUpdata(_ data: YachtDetailModel) {
        _venueInfoView.setupYachtData(yacht: data.yachtClub ?? YachtClubModel())
        features = data.features.toArrayDetached(ofType: CommonSettingsModel.self)
        _yachtDetail = data
        _yachtName.text = data.name
        _yachtAbout.text = data.about
        _priceText.text = "D\(200)/HR"
        _coverImage.loadWebImage(data.images.first ?? kEmptyString)
        _collecitonHeight.constant = features.isEmpty ? 0 : features.count > 4 ? 60 : 30
        if !features.isEmpty {
            _collectionSetup()
        }
//        callBack?(features.isEmpty ? 330 : features.count > 3 ? 400.0 : 365.0)
    }
    
    public func setUpOfferdata(_ data: YachtOfferDetailModel) {
        _venueInfoView.setupYachtData(yacht: data.yacht?.yachtClub ?? YachtClubModel())
        features = data.yacht?.features.toArrayDetached(ofType: CommonSettingsModel.self) ?? []
        _yachtDetail = data.yacht
        _yachtName.text = data.title
        _yachtAbout.text = data.descriptions
        _priceText.text = "D\(data.startingAmount)/HR"
        _coverImage.loadWebImage(data.images.first ?? kEmptyString)
        _collecitonHeight.constant = features.isEmpty ? 0 : features.count > 4 ? 60 : 30
        if !features.isEmpty {
            _collectionSetup()
        }
        callBack?(features.isEmpty ? 300 : features.count > 4 ? 470.0 : 325.0)
    }
    
    private func _collectionSetup() {
        let layout = HorizontalTagsFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        layout.minimumLineSpacing = 5
        _collectionView.showsHorizontalScrollIndicator = false
        _collectionView.showsVerticalScrollIndicator = false
        _collectionView.collectionViewLayout = layout
        _collectionView.register(UINib(nibName: "YachtFeatureCollectionCell", bundle: nil), forCellWithReuseIdentifier: "YachtFeatureCollectionCell")
        _collectionView.delegate = self
        _collectionView.dataSource = self
        _collectionView.reloadData()
    }
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    @IBAction func _handleClickEvent(_ sender: UIButton) {

    }
    
    @IBAction func _handleMenuEvent(_ sender: UIButton) {
    }
    
    @IBAction func _handleBuyNowEvent(_ sender: UIButton) {
    }
    
    @IBAction func _handleContactAgentEvent(_ sender: UIButton) {
    }

}


extension YachtCollectionCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return _yachtDetail?.features.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "YachtFeatureCollectionCell", for: indexPath) as! YachtFeatureCollectionCell
        cell.setup(features[indexPath.row])
        cell._bgView.cornerRadius = 9
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout
        collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let item = features[indexPath.item].feature
        let isIcon = Utils.stringIsNullOrEmpty(features[indexPath.row].icon)
        let width = item.size(withAttributes: [NSAttributedString.Key.font: FontBrand.SFregularFont(size: 14)]).width + (isIcon ? 18 : 30)
        return CGSize(width: width < 40 ? 50 : width , height: 24)
    }

}
