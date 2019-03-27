import UIKit
import CoreLocation
import UserNotifications
import MapKit

class NewNoteViewController: UIViewController, CLLocationManagerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate
{
    @IBOutlet weak var noteText : UITextView!
    var locationManager: CLLocationManager!
    var longitude = 0.0
    var latitude = 0.0
    @IBOutlet weak var toolbarCamera: UIBarButtonItem!
    
    private var note = Note()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        //noteText.attributedText
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem)
    {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func done(_ sender: UIBarButtonItem)
    {
        if(self.noteText.text != "")
        {
            self.saveItNow()
            
            performSegue(withIdentifier: "unwindToViewController", sender: self)
        }
        else
        {
            let alert = UIAlertController(title: "Seriously?", message: "Type something for your new note", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Ok... I got it!", style: .default, handler: nil))
            
            alert.addAction(UIAlertAction(title: "I don't want this anymore!", style: .destructive){
                (action) in
                self.dismiss(animated: true, completion: nil)
            })
            
            self.present(alert, animated: true)
        }
    }
    
    func setLatitudeLongitude()
    {
        if(CLLocationManager.authorizationStatus() ==  .authorizedWhenInUse || CLLocationManager.authorizationStatus() ==  .authorizedAlways)
        {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            let currentLocation = locationManager.location
            if(currentLocation != nil)
            {
                self.longitude = Double((currentLocation?.coordinate.longitude)!)
                self.latitude = Double((currentLocation?.coordinate.latitude)!)
            }
        }
    }
    
    var imagePicker = UIImagePickerController()
    
    @IBAction func btnToolbarCamera(_ sender: UIBarButtonItem) {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum)
        {
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = false
            
            self.saveItNow()
            self.noteText.attributedText = self.note.text.replaceImgTagsWithImages()
            self.removeItNow()
            
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.dismiss(animated: true, completion: { () -> Void in
            let fullString = NSMutableAttributedString(attributedString: self.noteText.attributedText)
            let image1Attachment = NSTextAttachment()
            let image = info[.originalImage] as? UIImage
            let oldWidth = image!.size.width
            image1Attachment.image = image!.resizeImage(scale: (UIScreen.main.bounds.width - 10)/oldWidth)
            let image1String = NSAttributedString(attachment: image1Attachment)
            fullString.append(image1String)
            self.noteText.attributedText = fullString
        })
    }
    
    private func saveItNow()
    {
        self.note = Note()
        self.setLatitudeLongitude()
        self.note.id = UUID().uuidString
        APP.createNoteDirectory(noteId: self.note.id)
        self.note.text = self.noteText.getText(for: note.id)
        self.note.title = String(self.noteText.text.split(separator: "\n")[0])
        self.note.latitude = self.latitude
        self.note.longitude = self.longitude
        self.note.created = Date()
        
        NotesRepository.save(note)
    }
    
    private func removeItNow()
    {
        APP.clearFolderForNote(noteId: self.note.id)
        NotesRepository.remove(self.note.id)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.first != nil {
            locationManager.stopUpdatingLocation()
            self.latitude = locations[0].coordinate.latitude
            self.longitude = locations[0].coordinate.longitude
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        APP.printError(className: "NewNoteViewController", method: #function, message: "Error getting location")
    }
}
