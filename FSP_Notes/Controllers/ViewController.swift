import UIKit
import SQLite3

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate
{
    var notesList : [Note] = []
    var selectedNoteId : String = ""
    @IBOutlet weak var allNotes: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.notesList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = self.notesList[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoteTableViewCell", for: indexPath)
        cell.textLabel?.text = item.title
        cell.detailTextLabel?.text = (item.categoryText != "") ? item.categoryText : ""

        //cell.imageView?.image = UIImage(named: headline.image)
        //let image = UIImage(named: "yosemite-meadows")
        //cell.img = UIImageView(image: image)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "editNote", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.notesList = NotesRepository.getAll()
        
        let longPressGesture:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.longPress(_:)))
        longPressGesture.minimumPressDuration = 1.0
        longPressGesture.delegate = self as? UIGestureRecognizerDelegate
        self.view.addGestureRecognizer(longPressGesture)
        
        self.searchBar.delegate = self
    }
    
    @objc func longPress(_ longPressGestureRecognizer: UILongPressGestureRecognizer) {
        if longPressGestureRecognizer.state == UIGestureRecognizer.State.began {
            let touchPoint = longPressGestureRecognizer.location(in: self.allNotes)
            if let indexPath = self.allNotes.indexPathForRow(at: touchPoint) {
                selectedNoteId = self.notesList[indexPath.row].id
                //pressedShare()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editNote" {
            if let destination = segue.destination as? EditNoteInfoViewController {
                let selectedItem = self.allNotes.indexPathForSelectedRow!.row
                destination.selectedNoteId = self.notesList[selectedItem].id
            }
        }
    }
    
    @IBAction func unwindToViewController(segue:UIStoryboardSegue)
    {
        self.notesList = NotesRepository.getAll()
        self.allNotes.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        self.notesList = NotesRepository.getAll(searchFor: searchText)
        self.allNotes.reloadData()
    }

    @IBAction func sortAction(_ sender: UIBarButtonItem)
    {
        let alertController = UIAlertController(title: "Sort", message: "", preferredStyle: .actionSheet)
        
        let titleASC = UIAlertAction(title: "Title Ascending", style: .default)
        {
            (action) in
            
            self.notesList = NotesRepository.getAll(searchFor: self.searchBar.text!, orderBy: APP.NOTE.TITLE, asc: true)
            self.allNotes.reloadData()
        }
        
        let titleDESC = UIAlertAction(title: "Title Descending", style: .default)
        {
            (action) in
            
            self.notesList = NotesRepository.getAll(searchFor: self.searchBar.text!, orderBy: APP.NOTE.TITLE, asc: false)
            self.allNotes.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        
        alertController.addAction(titleASC)
        alertController.addAction(titleDESC)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        self.searchBar.text = ""
        self.notesList = NotesRepository.getAll()
        self.allNotes.reloadData()
    }
}
