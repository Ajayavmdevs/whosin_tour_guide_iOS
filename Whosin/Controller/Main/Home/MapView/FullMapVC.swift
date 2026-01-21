import UIKit
import MapKit
import SnapKit
import Hero
import CollectionViewPagingLayout

class FullMapVC: ChildViewController {

    @IBOutlet private weak var _subtitleLabel: UILabel!
    @IBOutlet private weak var _titleLabel: UILabel!
    @IBOutlet public weak var _mapbgView: UIView!
    @IBOutlet private weak var _menuContainer: UIView!
    @IBOutlet private weak var _collectionView: UICollectionView!
    private var _selectedIndex: Int = 0
    public var homeBlock: HomeBlockModel?
    public var oldMapContainer: UIView?
    public var mapView: CustomMapView?
    public var _shoutoutModel: [ShoutoutListModel] = []
    public var _eventList: [EventModel] = []

    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUi()
        _requestShououtListData()
        _requestNearByEvents()
    }
    
    override func setupUi() {
        _titleLabel.text = homeBlock?.title
        _subtitleLabel.text = homeBlock?.descriptions
        mapView?.removeUserAnnotations()
        
        let headerView = ChatTableHeaderView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 40))
        headerView.delegate = self
        headerView.setupTabLabels(["Venues", "Matches", "events".localized()])
        headerView.setupData(self._selectedIndex)
        self._menuContainer.addSubview(headerView)
        DISPATCH_ASYNC_MAIN_AFTER(0.5) {
            headerView.frame = CGRect(x: 0, y: 0, width: self._menuContainer.frame.size.width, height: 40)
        }
        
        let layout = CollectionViewPagingLayout()
        layout.numberOfVisibleItems = 5
        layout.scrollDirection = .horizontal
        self._collectionView.delegate = self
        self._collectionView.dataSource = self
        self._collectionView.collectionViewLayout = layout
        self._collectionView.isPagingEnabled = true
        self._collectionView.register(UINib(nibName: "ShoutoutLargeCollectionCell", bundle: nil), forCellWithReuseIdentifier: "ShoutoutLargeCollectionCell")
        self._collectionView.register(UINib(nibName: "ShoutoutEventCollectionCell", bundle: nil), forCellWithReuseIdentifier: "ShoutoutEventCollectionCell")
        self._collectionView.register(UINib(nibName: "ShoutoutVenueCollectionCell", bundle: nil), forCellWithReuseIdentifier: "ShoutoutVenueCollectionCell")
        
        if let nearByVenue = homeBlock?.nearByVenues {
            self._collectionView.isHidden = nearByVenue.count == 0
        }
        self._collectionView.reloadData()
        
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func _loadData() {
        mapView?.removeAllAnnotations()
        
        self._collectionView.isHidden = true
        switch _selectedIndex {
            case 0:
                if let nearByVenue = homeBlock?.nearByVenues {
                    self._collectionView.isHidden = nearByVenue.count == 0
                }
                mapView?.addVenueAnnotation(homeBlock?.nearByVenues.toArrayDetached(ofType: VenueDetailModel.self) ?? [])
                break
            case 1:
                self._collectionView.isHidden = _shoutoutModel.count == 0
                mapView?.addUserAnnotation(homeBlock?.users.toArrayDetached(ofType: UserDetailModel.self) ?? [])
                break
            default:
                self._collectionView.isHidden = _eventList.count == 0
                mapView?.addEventAnnotation(_eventList)
                break
        }
    }
    
    // --------------------------------------
    // MARK: Service
    // --------------------------------------

    private func _requestNearByEvents() {
        WhosinServices.nearByEvents(distance: 100) { [weak self] container, error in
            guard let self = self else { return }
            guard let data = container?.data else { return }
            self._eventList = data.data ?? []
            
            let repo = UserRepository()
            repo.saveUsers(users: data.users ?? []) { model in
                if self._selectedIndex == 2 {
                    self._collectionView.reloadData()
                    self._loadData()
                }
            }
            
        }
    }
    
    private func _requestShououtListData() {
        WhosinServices.getShoutoutList { [weak self] container, error in
            guard let self = self else { return }
            guard let data = container?.data else { return }
            self._shoutoutModel = data
            self._collectionView.reloadData()
            if self._selectedIndex == 1 {
                self._collectionView.isHidden = self._shoutoutModel.count == 0
            }
        }
    }
    
    // --------------------------------------
    // MARK: Events
    // --------------------------------------

    @IBAction private func _handleCloseEvent(_ sender: UIButton) {

        if let mapview = mapView {
            if _selectedIndex == 0 {
                mapView?.addUserAnnotation(homeBlock?.users.toArrayDetached(ofType: UserDetailModel.self) ?? [])

            } else if _selectedIndex == 1 {
                mapView?.addVenueAnnotation(homeBlock?.nearByVenues.toArrayDetached(ofType: VenueDetailModel.self) ?? [])
            } else {
                mapView?.removeAllAnnotations()
                mapView?.addVenueAnnotation(homeBlock?.nearByVenues.toArrayDetached(ofType: VenueDetailModel.self) ?? [])
                mapView?.addUserAnnotation(homeBlock?.users.toArrayDetached(ofType: UserDetailModel.self) ?? [])
            }
            oldMapContainer?.addSubview(mapview)
            mapview.translatesAutoresizingMaskIntoConstraints = false
            if let superView = mapview.superview {
                NSLayoutConstraint.activate([
                    mapview.leadingAnchor.constraint(equalTo: superView.leadingAnchor, constant: 0),
                    mapview.trailingAnchor.constraint(equalTo: superView.trailingAnchor, constant: 0),
                    mapview.topAnchor.constraint(equalTo: superView.topAnchor),
                    mapview.bottomAnchor.constraint(equalTo: superView.bottomAnchor)
                ])
                mapview.layoutIfNeeded()
            }
            
        }
        dismiss(animated: true)
        mapView?.mapView.isScrollEnabled = false
    }
}

extension FullMapVC: ChatTableHeaderViewDelegate {
    func didSelectTab(at index: Int) {
        _selectedIndex = index
        _loadData()
        _collectionView.reloadData()
    }
}

extension FullMapVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if _selectedIndex == 2 {
            return _eventList.count
        }
        else if _selectedIndex == 0 {
            return homeBlock?.nearByVenues.count ?? 0
        }
        return _shoutoutModel.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ShoutoutVenueCollectionCell", for: indexPath) as! ShoutoutVenueCollectionCell
            if let venues = homeBlock?.nearByVenues {
                cell.setUpdata(venues[indexPath.row])
            }
            return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if _selectedIndex == 2  {
            let lat = _eventList[indexPath.row].venueDetail?.lat ?? 0
            let lng = _eventList[indexPath.row].venueDetail?.lng ?? 0
            mapView?.setCenterRegionOnMap(latitude: lat, longitude: lng)
        }
        else if _selectedIndex == 0 {
            if let venue = homeBlock?.nearByVenues[indexPath.row] {
                mapView?.setCenterRegionOnMap(latitude: venue.lat, longitude: venue.lng)
            }
        }
    }
}
