//
//  AllCategoriesViewController.swift
//  FSP_Notes
//
//  Created by Carlos José Bulado on 2019-03-27.
//  Copyright © 2019 Carlos José Bulado. All rights reserved.
//

import UIKit

class AllCategoriesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    var categories : [Category] = []
    var selectedCategoryId : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.categories = CategoriesRepository.getAll()
        
        let longPressGesture:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(AllCategoriesViewController.longPress(_:)))
        longPressGesture.minimumPressDuration = 1.0
        longPressGesture.delegate = self as? UIGestureRecognizerDelegate
        self.view.addGestureRecognizer(longPressGesture)
    }
    
    @objc func longPress(_ longPressGestureRecognizer: UILongPressGestureRecognizer) {
        if longPressGestureRecognizer.state == UIGestureRecognizer.State.began {
            let touchPoint = longPressGestureRecognizer.location(in: self.tableView)
            if let indexPath = self.tableView.indexPathForRow(at: touchPoint) {
                selectedCategoryId = self.categories[indexPath.row].id
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.categories.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "editCategory", sender: self)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = self.categories[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryTableViewCell", for: indexPath)
        cell.textLabel?.text = item.text
        return cell
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        self.categories = CategoriesRepository.getAll()
        self.tableView.reloadData()
    }

    @IBAction func btnCancel(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editCategory" {
            if let destination = segue.destination as? CategoryViewController {
                let selectedItem = self.tableView.indexPathForSelectedRow!.row
                destination.categoryId = self.categories[selectedItem].id
            }
        }
    }

}
