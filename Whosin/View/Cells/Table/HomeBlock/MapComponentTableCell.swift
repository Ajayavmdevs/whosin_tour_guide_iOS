import UIKit
import MapKit
import CollectionViewPagingLayout
import StripePaymentSheet

class MapComponentTableCell: UITableViewCell {
        
    @IBOutlet weak var _shout: UIView!
    @IBOutlet weak var _collectionView: UICollectionView!
    @IBOutlet weak var _mapviewBg: UIView!
    @IBOutlet weak var _titleTextLabel: UILabel!
    @IBOutlet weak var _subTitleTextLabel: UILabel!
    @IBOutlet weak var _bgView: UIView!
    @IBOutlet weak var _visibilityIcon: UIImageView!
    @IBOutlet weak var _visibilityText: UILabel!
    @IBOutlet weak var _visibilitySwitch: UISwitch!
    @IBOutlet weak var _marginConstraint: NSLayoutConstraint!
    private var mapview = CustomMapView()
    private var _userModel: [UserDetailModel] = []
    private var _homeBlock: HomeBlockModel?
    private var _venueList: [VenueDetailModel] = []
    private var _shoutoutModel: [ShoutoutListModel] = []
    private let kCellIdentifier = String(describing: ShoutoutCollectionCell.self)

    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
        disableSelectEffect()
        setupUi()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        guard let _homeBlock = _homeBlock else { return }
        _titleTextLabel.text = _homeBlock.title
        _subTitleTextLabel.text = _homeBlock.descriptions
        _venueList = _homeBlock.nearByVenues.toArrayDetached(ofType: VenueDetailModel.self)
        _userModel = _homeBlock.users.toArrayDetached(ofType: UserDetailModel.self)
        _updateVisibilityStatus( _homeBlock.visibilityStatus ?? false)
        mapview.addUserAnnotation(_userModel)
        mapview.addVenueAnnotation(_venueList)
        _requestShououtListData()
    }
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------

    class var height: CGFloat {
        400
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func setupUi() {
        DISPATCH_ASYNC_MAIN_AFTER(0.02) {
            self._shout.cornerRadius = self._shout.frame.size.height / 2
            self._mapviewBg.roundCorners(corners: [.allCorners], radius: 10) }
        _mapviewBg.hero.id = "_open_full_map"
        _mapviewBg.hero.modifiers = HeroAnimationModifier.sourceView
        mapview = CustomMapView(frame: CGRect(x: 0, y: 0, width: _mapviewBg.frame.width, height: _mapviewBg.frame.height))
        mapview.translatesAutoresizingMaskIntoConstraints = false
        _mapviewBg.addSubview(mapview)
        
        NSLayoutConstraint.activate([
            mapview.leadingAnchor.constraint(equalTo: _mapviewBg.leadingAnchor, constant: 0),
            mapview.trailingAnchor.constraint(equalTo: _mapviewBg.trailingAnchor, constant: 0),
            mapview.topAnchor.constraint(equalTo: _mapviewBg.topAnchor),
            mapview.bottomAnchor.constraint(equalTo: _mapviewBg.bottomAnchor)
        ])
        
        mapview.layoutIfNeeded()
        mapview.layoutSubviews()
        
        disableSelectEffect()
        
        let layout = CollectionViewPagingLayout()
        layout.numberOfVisibleItems = 3
        layout.scrollDirection = .horizontal
        _collectionView.delegate = self
        _collectionView.dataSource = self
        _collectionView.collectionViewLayout = layout
        _collectionView.isPagingEnabled = true
        _collectionView.register(UINib(nibName: "ShoutoutCollectionCell", bundle: nil), forCellWithReuseIdentifier: "ShoutoutCollectionCell")
        _collectionView.reloadData()
    }
    
    private func _updateVisibilityStatus(_ isVisible: Bool) {
        _visibilitySwitch.onTintColor = UIColor(hexString: "#F048FF")
        _visibilityIcon.tintColor = isVisible ? ColorBrand.brandLightGreen : .red
        _visibilityText.text = isVisible ? "Turn off visibility to appear offline" : "Turn on visibility to appear online"
        _visibilitySwitch.isOn = isVisible
    }
    
    // --------------------------------------
    // MARK: Service
    // --------------------------------------
    
    private func _requestShououtListData() {
        WhosinServices.getShoutoutList { [weak self] container, error in
            guard let self = self else { return }
            guard let data = container?.data else { return }
            self._shoutoutModel = data
            if data.isEmpty {
                self._marginConstraint.constant = 10
            } else {
                self._marginConstraint.constant = 50
            }
            self._collectionView.reloadData()
        }
    }
    
    private func _requestChangeVisibility(isVisible: Bool) {
        WhosinServices.changeVisibility(isVisible: isVisible) { [weak self] container, error in
            guard let self = self else { return }
            guard let data = container else { return }
            self.parentViewController?.view.makeToast(data.message)
        }
    }

    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------

    public func setupData(_ data: HomeBlockModel) {
        _titleTextLabel.text = data.title
        _subTitleTextLabel.text = data.descriptions
        _homeBlock = data
        _venueList = data.nearByVenues.toArrayDetached(ofType: VenueDetailModel.self)
        _userModel = data.users.toArrayDetached(ofType: UserDetailModel.self)
        _updateVisibilityStatus( _homeBlock?.visibilityStatus ?? false)
        mapview.addUserAnnotation(_userModel)
        mapview.addVenueAnnotation(_venueList)
        _requestShououtListData()  
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------

    @IBAction private func _handleZoomEvent(_ sender: UIButton) {
        mapview.mapView.isScrollEnabled = true
        let controller = INIT_CONTROLLER_XIB(FullMapVC.self)
        controller.modalPresentationStyle = .overFullScreen
        controller._shoutoutModel = _shoutoutModel
        controller.homeBlock = _homeBlock
        controller.mapView = mapview
        controller.hero.isEnabled = true
        controller.hero.modalAnimationType = .none
        controller.view.hero.id = "_open_full_map"
        controller.view.hero.modifiers = HeroAnimationModifier.stories
        controller.oldMapContainer = mapview.superview
        
        
        controller._mapbgView.addSubview(self.mapview)
        if let superView = self.mapview.superview {
            NSLayoutConstraint.activate([
                self.mapview.leadingAnchor.constraint(equalTo: superView.leadingAnchor, constant: 0),
                self.mapview.trailingAnchor.constraint(equalTo: superView.trailingAnchor, constant: 0),
                self.mapview.topAnchor.constraint(equalTo: superView.topAnchor),
                self.mapview.bottomAnchor.constraint(equalTo: superView.bottomAnchor)
            ])
            self.mapview.layoutIfNeeded()
            superView.layoutIfNeeded()
            superView.layoutSubviews()
        }
        
        parentViewController?.present(controller, animated: true)

    }
    
    @IBAction private func _handleInviteEvent(_ sender: UIButton) {
        let presentedViewController = INIT_CONTROLLER_XIB(ShoutoutBottomSheet.self)
//        presentedViewController.modalPresentationStyle = .custom
//        presentedViewController.transitioningDelegate = self
        presentedViewController.homeblockModel = _homeBlock
        presentedViewController.venues = _venueList
        presentedViewController.shoutoutModel = _shoutoutModel
        parentViewController?.presentAsPanModal(controller: presentedViewController)
    }
    
    @IBAction private func _handleVisibilitySwitch(_ sender: UISwitch) {
        let isVisible = sender.isOn
        _updateVisibilityStatus(isVisible)
        _requestChangeVisibility(isVisible: isVisible)
    }
}

extension MapComponentTableCell: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return CustomBottomSheet(presentedViewController: presented, presenting: presenting)
    }
}

extension MapComponentTableCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return _shoutoutModel.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ShoutoutCollectionCell", for: indexPath) as! ShoutoutCollectionCell
        cell.setupShoutoutData(_shoutoutModel[indexPath.row])
        return cell
    }
    
}
