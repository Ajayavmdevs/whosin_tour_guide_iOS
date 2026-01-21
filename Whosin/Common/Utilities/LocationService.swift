import Foundation
import CoreLocation

let LOCATIONSERVICE = LocationManager.shared


class LocationManager {
    class var shared: LocationManager {
        struct Static {
            static let instance = LocationManager()
        }
        return Static.instance
    }

    
    private let session: URLSession
    
    private init() {
        session = URLSession(configuration: .default)
    }
    
    func getCurrentCityAndCountry(completion: @escaping (String?, String?) -> Void) {
        if let location = APPSETTING.currentLocation {
            self.getCityAndCountryFromLocation(location) { city, country in
                if let city = city, let country = country {
                    completion(city, country)
                } else {
                    self.getLocationFromIP(completion: completion)
                }
            }
        } else {
            self.getLocationFromIP(completion: completion)
        }
    }
    

    
    private func getCityAndCountryFromLocation(_ location: CLLocation, completion: @escaping (String?, String?) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            guard let placemark = placemarks?.first, error == nil else {
                completion(nil, nil)
                return
            }
            let city = placemark.locality ?? ""
            let country = placemark.country ?? ""
            completion(city, country)
        }
    }
    
    private func getLocationFromIP(completion: @escaping (String?, String?) -> Void) {
        let url = URL(string: "https://ipinfo.io/json")!
        
        let task = session.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil, nil)
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                let city = json?["city"] as? String ?? ""
                let country = json?["country"] as? String ?? ""
                completion(city, country)
            } catch {
                completion(nil, nil)
            }
        }
        
        task.resume()
    }
}
