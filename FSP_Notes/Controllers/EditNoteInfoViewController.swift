import UIKit
import Social

class EditNoteInfoViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    var selectedNoteId = ""
    static var note : Note = Note()
    @IBOutlet weak var editNoteText: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        EditNoteInfoViewController.note = NotesRepository.getById(id: self.selectedNoteId)
        
        self.editNoteText.attributedText = EditNoteInfoViewController.note.text.replaceImgTagsWithImages()
    }
    
    @IBAction func btnShare(_ sender: UIBarButtonItem) {
        let textToShare = [ EditNoteInfoViewController.note.text ]
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        
        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook ]
        
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    /*
    // image to share
    let image = UIImage(named: "Image")

    // set up activity view controller
    let imageToShare = [ image! ]
    let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
    activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash

    // exclude some activity types from the list (optional)
    activityViewController.excludedActivityTypes = [ UIActivityType.airDrop, UIActivityType.postToFacebook ]

    // present the view controller
    self.present(activityViewController, animated: true, completion: nil)
    */
    
    @IBAction func btnEditDetails(_ sender: UIBarButtonItem) {
        saveItNow()
        performSegue(withIdentifier: "editNoteDetails", sender: self)
    }
    
    @IBAction func btnCancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveNote(_ sender: UIBarButtonItem) {
        saveItNow()
        performSegue(withIdentifier: "unwindToViewController", sender: self)
    }
    
    private func saveItNow()
    {
        APP.clearFolderForNote(noteId: EditNoteInfoViewController.note.id)
        EditNoteInfoViewController.note.updated = Date()
        EditNoteInfoViewController.note.text = self.editNoteText.getText(for: EditNoteInfoViewController.note.id)

        NotesRepository.save(EditNoteInfoViewController.note)
    }
    
    var imagePicker = UIImagePickerController()
    
    @IBAction func btnToolbarCamera(_ sender: UIBarButtonItem) {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum)
        {
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = false
            
            self.saveItNow()
            self.editNoteText.attributedText = EditNoteInfoViewController.note.text.replaceImgTagsWithImages()
            
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.dismiss(animated: true, completion: { () -> Void in
            let fullString = NSMutableAttributedString(attributedString: self.editNoteText.attributedText)
            let image1Attachment = NSTextAttachment()
            let image = info[.originalImage] as? UIImage
            let oldWidth = image!.size.width
            image1Attachment.image = image!.resizeImage(scale: (UIScreen.main.bounds.width - 10)/oldWidth)
            let image1String = NSAttributedString(attachment: image1Attachment)
            print("before := \(fullString)\n\n")
            fullString.append(image1String)
            print("after := \(fullString)\n\n")
            self.editNoteText.attributedText = fullString
        })
    }
    
    /*
     var image = info[.originalImage] as? UIImage
     let oldWidth = image!.size.width
     
     
     var text = self.editNoteText.getText(for: EditNoteInfoViewController.note.id)
     print("1 := \(text)")
     
     image = image!.resizeImage(scale: (UIScreen.main.bounds.width - 10)/oldWidth)
     guard let imageURL = image!.saveImage(noteId: EditNoteInfoViewController.note.id) else {
     return
     }
     let imageURLWrappedInTags = imageURL.inImgTag
     
     text += imageURLWrappedInTags
     
     print("2 := \(text)")
     self.editNoteText.attributedText = text.replaceImgTagsWithImages()
 */
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editNoteDetails" {
            if let destination = segue.destination as? EditNoteDetailsViewController {
                destination.selectedNoteId = EditNoteInfoViewController.note.id
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        EditNoteInfoViewController.note = NotesRepository.getById(id: self.selectedNoteId)
        self.editNoteText.attributedText = EditNoteInfoViewController.note.text.replaceImgTagsWithImages()
    }
    
    @IBAction func btnRemoveNote(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "Do you want to delete it?", message: "This action will remove completely your note!", preferredStyle: .alert)
        
        let yes = UIAlertAction(title: "Yes", style: .destructive)
        {
            (action) in
            
            NotesRepository.remove(EditNoteInfoViewController.note.id)
            APP.clearFolderForNote(noteId: EditNoteInfoViewController.note.id)
            self.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(yes)
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        
        self.present(alert, animated: true)
    }
}
