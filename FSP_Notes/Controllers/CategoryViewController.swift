import UIKit

class CategoryViewController: UIViewController
{
    @IBOutlet weak var categoryName: UITextField!
    var category : Category = Category()
    var categoryId : String = ""
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if(categoryId != "")
        {
            category = CategoriesRepository.getById(id: categoryId)
            categoryName.text = category.text
        }
    }
    
    @IBAction func btnCancel(_ sender: UIButton) { self.dismiss(animated: true, completion: nil) }
    
    @IBAction func btnSave(_ sender: UIBarButtonItem)
    {
        if(self.categoryName.text != "")
        {
            if(category.id == "") { category.id = UUID().uuidString }
            category.text = categoryName.text!
            category.created = Date()
            category.updated = Date()
            
            CategoriesRepository.save(category)
            
            self.dismiss(animated: true, completion: nil)
        }
        else
        {
            let alert = UIAlertController(title: "Seriously?", message: "Type something for your new category", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Ok... I got it!", style: .default, handler: nil))
            
            alert.addAction(UIAlertAction(title: "I don't want this anymore!", style: .destructive){
                (action) in
                self.dismiss(animated: true, completion: nil)
            })
            
            self.present(alert, animated: true)
        }
    }
    
    @IBAction func btnRemove(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Do you want to delete it?", message: "This action will remove completely your category!", preferredStyle: .alert)
        
        let yes = UIAlertAction(title: "Yes", style: .destructive)
        {
            (action) in
            
            CategoriesRepository.remove(self.categoryId)
            self.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(yes)
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        
        self.present(alert, animated: true)
    }
}
