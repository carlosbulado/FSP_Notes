import Foundation
import MapKit

extension MKMapView
{
    func addPinToThisMap(latitude: Double, longitude: Double, title: String = "", focus: Bool = false)
    {
        let point = CGPoint(x: latitude, y: longitude)
        self.addPinToThisMap(point: point, title: title, focus: focus)
    }
    
    func addPinToThisMap(point : CGPoint, title : String = "", focus: Bool = false)
    {
        let coordinates = CLLocationCoordinate2D(latitude: CLLocationDegrees(point.x), longitude: CLLocationDegrees(point.y))
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinates
        annotation.title = title
        self.addAnnotation(annotation)
        if focus { self.focusMapView(latitude: coordinates.latitude, longitude: coordinates.longitude) }
    }
    
    func focusMapView(latitude: Double, longitude: Double)
    {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        let regionRadius: CLLocationDistance = 1000
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        self.setRegion(coordinateRegion, animated: true)
    }
    
    func removeAllPins()
    {
        self.removeAnnotations(self.annotations)
    }
}
