import Foundation
import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {

    private let locationManager = CLLocationManager()
    @Published var locationStatus: CLAuthorizationStatus?
    @Published var lastLocation: CLLocation?
    @Published var lastCity: String?
    @Published var lastState: String?
    override init() {
        super.init()
        locationManager.delegate = self
//        locationManager.desiredAccuracy = kCLLocationAccuracyBest
//        locationManager.requestLocation()
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }

   
    
    var statusString: String {
        guard let status = locationStatus else {
            return "unknown"
        }
        
        switch status {
        case .notDetermined: return "notDetermined"
        case .authorizedWhenInUse: return "authorizedWhenInUse"
        case .authorizedAlways: return "authorizedAlways"
        case .restricted: return "restricted"
        case .denied: return "denied"
        default: return "unknown"
        }
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        locationStatus = status
        print(#function, statusString)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let location = locations.last else { return }
        lastLocation = location
        getPlace(for:location)
        print(#function, location)
    }
    
    func getPlace(for location: CLLocation) {
           
           let geocoder = CLGeocoder()
           geocoder.reverseGeocodeLocation(location) { placemarks, error in
               
               guard error == nil else {
                   print("*** Error in \(#function): \(error!.localizedDescription)")
                   
                   return
               }
               
               guard let placemark = placemarks?[0] else {
                   print("*** Error in \(#function): placemark is nil")
                   
                   return
               }
               self.lastCity = placemark.locality ?? ""
               self.lastState = placemark.administrativeArea ?? ""
               
           }
       }
}
