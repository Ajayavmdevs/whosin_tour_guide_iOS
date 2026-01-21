import UIKit
import MapKit

class CustomMapView: UIView {
    
    public var mapView: MKMapView
    private var _userDetailModel: [UserDetailModel] = []
    
    override init(frame: CGRect) {
        mapView = MKMapView(frame: frame)
        super.init(frame: frame)
        
        mapView.mapType = .mutedStandard
        addSubview(mapView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(locationUpdate(_:)), name: .updateLocationState, object: nil)
        
        mapView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mapView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            mapView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            mapView.topAnchor.constraint(equalTo: topAnchor),
            mapView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        mapView.showsUserLocation = true
        mapView.isUserInteractionEnabled = true
        mapView.delegate = self
        mapView.isScrollEnabled = false
        
        DISPATCH_ASYNC_MAIN_AFTER(0.5) {
            
            if let location = APPSETTING.currentLocation {
                let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: kMapDefaultZoom, longitudinalMeters: kMapDefaultZoom)
                self.mapView.setRegion(region, animated: true)
            } else {
                let initialLocation = CLLocation(latitude: self.mapView.userLocation.coordinate.latitude, longitude: self.mapView.userLocation.coordinate.longitude)
                if initialLocation.coordinate.latitude > 0 {
                    let region = MKCoordinateRegion(center: initialLocation.coordinate, latitudinalMeters: kMapDefaultZoom, longitudinalMeters: kMapDefaultZoom)
                    self.mapView.setRegion(region, animated: true)
                }
            }
        }
        
    }
    
    @objc private func locationUpdate(_ notification: Notification) {
        if let location = APPSETTING.currentLocation {
            let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: kMapDefaultZoom, longitudinalMeters: kMapDefaultZoom)
            self.mapView.setRegion(region, animated: true)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        mapView = MKMapView()
        super.init(coder: aDecoder)
        mapView.showsUserLocation = true
        addSubview(mapView)

        mapView.delegate = self
        DISPATCH_ASYNC_MAIN_AFTER(1.5) {
            let initialLocation = CLLocation(latitude: self.mapView.userLocation.coordinate.latitude, longitude: self.mapView.userLocation.coordinate.longitude)
            let region = MKCoordinateRegion(center: initialLocation.coordinate, latitudinalMeters: kMapDefaultZoom, longitudinalMeters: kMapDefaultZoom)
            self.mapView.setRegion(region, animated: true)
        }
    }
    
    func removeAllAnnotations() {
        mapView.removeAnnotations(mapView.annotations)
    }
    
    func removeUserAnnotations() {
        mapView.removeAnnotations(mapView.annotations.filter{ $0 is UserAnnotation})
    }
    
    func removeVenueAnnotations() {
        mapView.removeAnnotations(mapView.annotations.filter{ $0 is VenueAnnotation})
    }
    
    func addUserAnnotation(_ userModel: [UserDetailModel]) {
        var annotations: [UserAnnotation] = []
        userModel.forEach { userModel in
            let coordinate = CLLocationCoordinate2D(latitude: userModel.lat, longitude: userModel.lng)
            let annotation = UserAnnotation(title: nil, subtitle: nil, coordinate: coordinate, userImageURL: userModel.image,user: userModel)
            annotations.append(annotation)
        }
        mapView.addAnnotations(annotations)
    }
    
    func addVenueAnnotation(_ venueModel: [VenueDetailModel]) {
        var annotations: [VenueAnnotation] = []
        venueModel.forEach { venue in
            let coordinate = CLLocationCoordinate2D(latitude: venue.lat, longitude: venue.lng)
            let annotation = VenueAnnotation(id: venue.id,title: venue.name, subtitle: "\(Int(venue.distance)) km", coordinate: coordinate, userImageURL: venue.logo, users: venue.checkIns.toArrayDetached(ofType: UserDetailModel.self))
            annotations.append(annotation)
        }
        mapView.addAnnotations(annotations)
    }
    
    func addEventAnnotation(_ eventList: [EventModel]) {
        var annotations: [EventAnnotation] = []
        eventList.forEach { event in
            if let venue = event.venueDetail {
                let coordinate = CLLocationCoordinate2D(latitude: venue.lat, longitude: venue.lng)
                let annotation = EventAnnotation(id: event.id, title: event.title, subtitle: event.descriptions, coordinate: coordinate, userImageURL: event.image, event: event)
                annotations.append(annotation)
            }
        }
        mapView.addAnnotations(annotations)
    }
    
    func setCenterRegionOnMap(latitude: Double, longitude: Double) {
        let initialLocation = CLLocation(latitude: latitude, longitude: longitude)
        let region = MKCoordinateRegion(center: initialLocation.coordinate, latitudinalMeters: kMapDefaultZoom, longitudinalMeters: kMapDefaultZoom)
        self.mapView.setRegion(region, animated: true)
    }

}

extension CustomMapView: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if let userAnnotation = annotation as? UserAnnotation {
            let pinView = MKAnnotationView(annotation: userAnnotation, reuseIdentifier: "CustomAnnotationView")
            pinView.canShowCallout = true
            pinView.image = UIImage(named: "img_round_border")?.resizedImage(size: CGSize(width: 44, height: 44))
            
            if let user = userAnnotation.user {
                configureUserCallOut(pinView, users: [user])
            }
            
            let profileImageView = UIImageView(frame: CGRect(x: 2, y: 2, width: 40, height: 40))
            profileImageView.layer.masksToBounds = true
            profileImageView.layer.cornerRadius = profileImageView.frame.width/2
            profileImageView.loadWebImage(userAnnotation.image, name: userAnnotation.user?.fullName ?? kEmptyString)
            pinView.addSubview(profileImageView)
            profileImageView.shadowColor = .black
            profileImageView.shadowOpacity = 1
            return pinView
        }
        else if let venueAnnotation = annotation as? VenueAnnotation {
            let pinView = MKAnnotationView(annotation: venueAnnotation, reuseIdentifier: "CustomAnnotationView")
            pinView.canShowCallout = true
            pinView.image = UIImage(named: "img_round_border")?.resizedImage(size: CGSize(width: 44, height: 44))
            configureDetailView(pinView, users: venueAnnotation.users, venueId: venueAnnotation.id ?? kEmptyString)
            let profileImageView = UIImageView(frame: CGRect(x: 2, y: 2, width: 40, height: 40))
            profileImageView.layer.masksToBounds = true
            profileImageView.layer.cornerRadius = profileImageView.frame.width/2
            profileImageView.loadWebImage(venueAnnotation.userImageURL, name: venueAnnotation.title ?? kEmptyString)
            pinView.addSubview(profileImageView)
            profileImageView.shadowColor = .black
            profileImageView.shadowOpacity = 1
            return pinView
        }
        else if let venueAnnotation = annotation as? EventAnnotation {
            let pinView = MKAnnotationView(annotation: venueAnnotation, reuseIdentifier: "CustomAnnotationView")
            pinView.canShowCallout = true
            pinView.image = UIImage(named: "img_round_border")?.resizedImage(size: CGSize(width: 44, height: 44))
            let profileImageView = UIImageView(frame: CGRect(x: 2, y: 2, width: 40, height: 40))
            profileImageView.layer.masksToBounds = true
            profileImageView.layer.cornerRadius = profileImageView.frame.width/2
            profileImageView.loadWebImage(venueAnnotation.userImageURL, name: venueAnnotation.title ?? kEmptyString)
            pinView.addSubview(profileImageView)
            profileImageView.shadowColor = .black
            profileImageView.shadowOpacity = 1
            return pinView
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if view.annotation!.isKind(of: MKUserLocation.self){
            return
        }
    }


    @objc func removeCustomCalloutView(sender: UITapGestureRecognizer) {
        if let calloutView = sender.view as? CustomVenueCalloutView {
            calloutView.removeFromSuperview()
        }
    }
    
    func configureUserCallOut(_ annotation: MKAnnotationView?, users:[UserDetailModel]){

        guard annotation?.annotation is UserAnnotation else { return }
        let customCalloutView = CustomVenueCalloutView.initFromNib()
        customCalloutView.translatesAutoresizingMaskIntoConstraints = false
        customCalloutView.setupData(users, venueId: kEmptyString)
        customCalloutView.hideCheckinButton()
        annotation?.detailCalloutAccessoryView = customCalloutView
        NSLayoutConstraint.activate([
            customCalloutView.widthAnchor.constraint(equalToConstant: customCalloutView.viewWidth),
            customCalloutView.heightAnchor.constraint(equalToConstant: customCalloutView.userHeight)
        ])
    }
    
    func configureDetailView(_ annotation: MKAnnotationView?, users:[UserDetailModel], venueId: String) {

        guard annotation?.annotation is VenueAnnotation else { return }
        let customCalloutView = CustomVenueCalloutView.initFromNib()
        customCalloutView.translatesAutoresizingMaskIntoConstraints = false
        customCalloutView.setupData(users, venueId: venueId)
        annotation?.detailCalloutAccessoryView = customCalloutView
        NSLayoutConstraint.activate([
            customCalloutView.widthAnchor.constraint(equalToConstant: customCalloutView.viewWidth),
            customCalloutView.heightAnchor.constraint(equalToConstant: customCalloutView.viewHeight)
        ])
    }

}

class UserAnnotation: NSObject, MKAnnotation {
    let title: String?
    let subtitle: String?
    let coordinate: CLLocationCoordinate2D
    let image: String
    let user: UserDetailModel?
    
    init(title: String?, subtitle: String?, coordinate: CLLocationCoordinate2D, userImageURL: String, user: UserDetailModel?) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
        self.image = userImageURL
        self.user = user
        super.init()
    }
}


class VenueAnnotation: NSObject, MKAnnotation {
    let id: String?
    let title: String?
    let subtitle: String?
    let coordinate: CLLocationCoordinate2D
    let userImageURL: String
    var users:[UserDetailModel] = []
    
    init(id:String?, title: String?, subtitle: String?, coordinate: CLLocationCoordinate2D, userImageURL: String, users:[UserDetailModel] = []) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
        self.userImageURL = userImageURL
        self.users = users
        super.init()
    }
}

class EventAnnotation: NSObject, MKAnnotation {
    let id: String?
    let title: String?
    let subtitle: String?
    let coordinate: CLLocationCoordinate2D
    let userImageURL: String
    var eventModel: EventModel?
    
    init(id:String?, title: String?, subtitle: String?, coordinate: CLLocationCoordinate2D, userImageURL: String, event: EventModel?) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
        self.userImageURL = userImageURL
        self.eventModel = event
        super.init()
    }
}

