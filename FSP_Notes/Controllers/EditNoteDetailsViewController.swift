import UIKit
import CoreLocation
import MapKit

class EditNoteDetailsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIGestureRecognizerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var titleText: UITextField!
    @IBOutlet weak var txtCategory: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var categoryPicker: UIPickerView!
    var categories : [Category] = []
    var selectedNoteId : String = ""
    static var note : Note = Note()
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        categoryPicker.delegate = self
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        self.mapView.delegate = self
        
        if(selectedNoteId == "")
        {
            self.dismiss(animated: true, completion: nil)
        }
        
        EditNoteDetailsViewController.note = NotesRepository.getById(id: self.selectedNoteId)
        
        self.categories = CategoriesRepository.getAll()
        let emptyCategory = Category()
        emptyCategory.id = ""
        emptyCategory.text = "Select Category"
        self.categories.insert(Category(), at: 0)
        
        self.titleText.text = EditNoteDetailsViewController.note.title
        self.txtCategory.text = EditNoteDetailsViewController.note.categoryText
        
        self.mapView.addPinToThisMap(latitude: EditNoteDetailsViewController.note.latitude, longitude: EditNoteDetailsViewController.note.longitude, focus: true)
    }
    
    @IBAction func brnCancel(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnSave(_ sender: UIBarButtonItem) {
        saveItNow()
        self.dismiss(animated: true, completion: nil)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.categories.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.categories[row].text
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        txtCategory.text = self.categories[row].text
        EditNoteDetailsViewController.note.category = self.categories[row].id
    }
    
    @IBAction func clickChooseCategory(_ sender: UITextField)
    {
        
    }
    
    private func saveItNow()
    {
        EditNoteDetailsViewController.note.title = self.titleText.text!
        EditNoteDetailsViewController.note.updated = Date()
        
        NotesRepository.save(EditNoteDetailsViewController.note)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            if (touch.tapCount > 2)
            {
                let position = touch.location(in: mapView)
                
                self.mapView.removeAllPins()
                self.mapView.addPinToThisMap(point: position, title: "My Location")
                
                let coordinates = mapView.convert(position, toCoordinateFrom: mapView)
                
                EditNoteDetailsViewController.note.latitude = coordinates.latitude
                EditNoteDetailsViewController.note.longitude = coordinates.longitude
                
                self.mapView.addPinToThisMap(latitude: EditNoteDetailsViewController.note.latitude, longitude: EditNoteDetailsViewController.note.longitude, title: "My Location")
            }
        }
    }
}

extension EditNoteDetailsViewController : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.first != nil {
            //print("location:: (location)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        //print("[MapViewController] \(#function) Error: \(error.localizedDescription)")
    }
}
