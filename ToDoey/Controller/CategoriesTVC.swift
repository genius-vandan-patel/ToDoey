//
//  CategoriesTVC.swift
//  ToDoey
//
//  Created by Vandan Patel on 12/31/17.
//  Copyright © 2017 Vandan Patel. All rights reserved.
//

import UIKit
import CoreData

class CategoriesTVC: UITableViewController {
    
    let reuseIdentifier = "categoryCell"
    var categoriesArray = [Category]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = UIColor.white
        tableView.tableFooterView = UIView()
        fetch()
    }
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoriesArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        let category = categoriesArray[indexPath.row]
        cell.textLabel?.text = category.name
        return cell
    }

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let category = categoriesArray[indexPath.row]
            context.delete(category)
            self.saveItems()
            categoriesArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    // MARK: - Tableview Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToItems" {
            let destVC = segue.destination as! ItemsTVC
            if let indexPath = tableView.indexPathForSelectedRow {
                destVC.selectedCategory = categoriesArray[indexPath.row]
            }
        }
    }
    
    // MARK: - Add Category
    @IBAction func didTapAdd(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        alert.addTextField { (alertTextField) in
            textField.placeholder = "Create New Category"
            textField = alertTextField
        }
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            let indexPath = IndexPath(row: self.categoriesArray.count, section: 0)
            let newCategory = Category(context: context)
            newCategory.name = textField.text
            self.categoriesArray.append(newCategory)
            self.saveItems()
            self.tableView.insertRows(at: [indexPath], with: .automatic)
        }
        alert.addAction(action)
        present(alert, animated: true)
    }
    
    
    func fetch(_ request: NSFetchRequest<Category> = Category.fetchRequest()) {
        do {
            categoriesArray = try context.fetch(request)
            tableView.reloadData()
        } catch {
            print("Error fetching data with context : ", error.localizedDescription)
        }
    }
    
    func saveItems() {
        do {
            try context.save()
        } catch {
            print("Error saving into context`", error.localizedDescription)
        }
    }
}
