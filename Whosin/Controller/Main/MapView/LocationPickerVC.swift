import UIKit
import MapKit

class LocationPickerVC: BaseViewController {
    
    @IBOutlet weak var _mapView: MKMapView!
    @IBOutlet weak var _selectLocationButton: CustomButton!
    @IBOutlet weak var _locationAddressText: CustomLabel!
    @IBOutlet weak var _bottomView: UIView!
    @IBOutlet weak var _searchBar: UISearchBar!
    public var isRestricted: Bool = false
    private let locationManager = CLLocationManager()
    private var selectedCoordinate: CLLocationCoordinate2D?
    private var selectedAddress: String?
    private let searchCompleter = MKLocalSearchCompleter()
    private var searchResults: [MKLocalSearchCompletion] = []
    private var currentLocationButton: UIButton!
    private lazy var resultsTableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isHidden = true
        tableView.layer.cornerRadius = 10
        tableView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        tableView.clipsToBounds = true
        return tableView
    }()
    let allowedRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 23.4241, longitude: 53.8478),
        span: MKCoordinateSpan(latitudeDelta: 10.0, longitudeDelta: 10.0)
    )
    private var selectedPlaceTitle: String?
    
    struct Location {
        let coordinate: CLLocationCoordinate2D
        let address: String
    }
    
    public var completion: ((Location?) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setDubaiRegion(for: _mapView)
        setupMapView()
        setupLocationManager()
        setupSearch()
        setupCurrentLocationButton()
        setupResultsTableView()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleMapTap(_:)))
        _mapView.addGestureRecognizer(tapGesture)
    }
    
    func setupMapView() {
        _mapView.delegate = self
        _mapView.showsUserLocation = true
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
//        locationManager.startUpdatingLocation()
    }
    
    func setupSearch() {
        _searchBar.delegate = self
        searchCompleter.delegate = self
        _searchBar.searchTextField.backgroundColor = UIColor(white: 1, alpha: 0.08)
        _searchBar.searchTextField.layer.cornerRadius = 18
        _searchBar.searchTextField.layer.masksToBounds = true
        _searchBar.searchTextField.textColor = .white
        _searchBar.placeholder = "search_for_a_location".localized()
    }
    
    func isInsideAllowedRegion(_ coordinate: CLLocationCoordinate2D) -> Bool {
        let latRange = allowedRegion.center.latitude - allowedRegion.span.latitudeDelta/2 ... allowedRegion.center.latitude + allowedRegion.span.latitudeDelta/2
        let lonRange = allowedRegion.center.longitude - allowedRegion.span.longitudeDelta/2 ... allowedRegion.center.longitude + allowedRegion.span.longitudeDelta/2
        return latRange.contains(coordinate.latitude) && lonRange.contains(coordinate.longitude)
    }
    
    func setupResultsTableView() {
        view.addSubview(resultsTableView)
        resultsTableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            resultsTableView.topAnchor.constraint(equalTo: _searchBar.bottomAnchor),
            resultsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            resultsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            resultsTableView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    func setupCurrentLocationButton() {
        currentLocationButton = UIButton(type: .custom)
        currentLocationButton.setImage(UIImage(systemName: "location.fill"), for: .normal)
        currentLocationButton.tintColor = .systemBlue
        currentLocationButton.backgroundColor = .white
        currentLocationButton.layer.cornerRadius = 25
        currentLocationButton.addTarget(self, action: #selector(centerToCurrentLocation), for: .touchUpInside)
        
        view.addSubview(currentLocationButton)
        currentLocationButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            currentLocationButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            currentLocationButton.bottomAnchor.constraint(equalTo: _bottomView.topAnchor, constant: -30),
            currentLocationButton.widthAnchor.constraint(equalToConstant: 50),
            currentLocationButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc func centerToCurrentLocation() {
        locationManager.startUpdatingLocation()
    }
    
    @objc func handleMapTap(_ sender: UITapGestureRecognizer) {
        let locationInView = sender.location(in: _mapView)
        let coordinate = _mapView.convert(locationInView, toCoordinateFrom: _mapView)
        setPinAt(location: coordinate)
        fetchAddress(for: coordinate)
        resultsTableView.isHidden = true
        _searchBar.resignFirstResponder()
    }
    
    func setDubaiRegion(for mapView: MKMapView) {
        let dubaiCoordinates = CLLocationCoordinate2D(latitude: 25.276987, longitude: 55.296249) // Dubai Coordinates
        let region = MKCoordinateRegion(
            center: dubaiCoordinates,
            span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2) // Zoom level
        )
        mapView.setRegion(region, animated: true)
    }
    
    func setPinAt(location: CLLocationCoordinate2D) {
        _mapView.removeAnnotations(_mapView.annotations)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        _mapView.addAnnotation(annotation)
        
        selectedCoordinate = location
        _mapView.setCenter(location, animated: true)
    }
    
    func fetchAddress(for coordinate: CLLocationCoordinate2D) {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self = self, let placemark = placemarks?.first, error == nil else { return }
            
            let address = [
                self.selectedPlaceTitle,
                placemark.name,
                placemark.locality,
                placemark.subLocality,
                placemark.administrativeArea,
                placemark.country
            ].compactMap { $0 }.joined(separator: ", ")
            
            self.selectedAddress = address
            self._locationAddressText.text = address
        }
    }
    
    @IBAction func _handleSelectLocation(_ sender: CustomButton) {
        guard let coordinate = selectedCoordinate, let address = selectedAddress else {
            completion?(nil)
            alert(title: kAppName, message: "please_select_a_location".localized())
            return
        }
        
        let selectedLocation = Location(coordinate: coordinate, address: address)
        if isRestricted {
            if self.isInsideAllowedRegion(selectedLocation.coordinate) {
                completion?(selectedLocation)
                dismissOrBack(true)
            } else {
                alert(title: kAppName, message: "select_location_within_dubai".localized())
                return
            }
        } else {
            completion?(selectedLocation)
            dismissOrBack(true)
        }
        
    }
    
    @IBAction func _handleBackEvent(_ sender: UIButton) {
        completion?(nil)
        dismissOrBack(true)
    }
}

extension LocationPickerVC: MKMapViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate, MKLocalSearchCompleterDelegate, UITableViewDelegate, UITableViewDataSource {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last?.coordinate else { return }
        
        _mapView.setRegion(MKCoordinateRegion(
            center: location,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        ), animated: true)
        
        setPinAt(location: location)
        fetchAddress(for: location)
        
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get location: \(error.localizedDescription)")
    }
    
    // MARK: - UISearchBarDelegate
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            searchResults = []
            resultsTableView.isHidden = true
            return
        }
        searchCompleter.queryFragment = searchText
        resultsTableView.isHidden = false
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if !searchResults.isEmpty {
            resultsTableView.isHidden = false
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchResults = []
        resultsTableView.isHidden = true
        searchBar.resignFirstResponder()
    }
    
    // MARK: - MKLocalSearchCompleterDelegate
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
        resultsTableView.reloadData()
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Search completer error: \(error.localizedDescription)")
    }
    
    // MARK: - UITableView DataSource & Delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        let result = searchResults[indexPath.row]
        cell.textLabel?.text = result.title
        cell.detailTextLabel?.text = result.subtitle
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedResult = searchResults[indexPath.row]
        selectedPlaceTitle = selectedResult.title
        let searchRequest = MKLocalSearch.Request(completion: selectedResult)
        let search = MKLocalSearch(request: searchRequest)
        
        search.start { [weak self] response, error in
            guard let self = self,
                  let mapItem = response?.mapItems.first,
                  let coordinate = mapItem.placemark.coordinate as CLLocationCoordinate2D?
            else { return }
            
            self.setPinAt(location: coordinate)
            self.fetchAddress(for: coordinate)
            self._searchBar.text = selectedResult.title
            self.resultsTableView.isHidden = true
            self._searchBar.resignFirstResponder()
        }
    }
}
