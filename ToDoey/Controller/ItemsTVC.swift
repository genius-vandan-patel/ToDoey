//
//  HomeTVC.swift
//  ToDoey
//
//  Created by Vandan Patel on 12/16/17.
//  Copyright © 2017 Vandan Patel. All rights reserved.
//

import UIKit
import CoreData

let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

class ItemsTVC: UITableViewController {
    
    var itemsArray = [Item]()
    var selectedCategory: Category? {
        didSet {
            fetch()
        }
    }
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return itemsArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        let item = itemsArray[indexPath.row]
        cell.textLabel?.text = item.title
        cell.accessoryType = item.done ? .checkmark : .none
        return cell
    }
    
    // MARK: - Table view delegate methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = itemsArray[indexPath.row]
        item.done = !item.done
        saveItems()
        tableView.reloadRows(at: [indexPath], with: .automatic)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let item = itemsArray[indexPath.row]
            context.delete(item)
            itemsArray.remove(at: indexPath.row)
            let indexPath = IndexPath(row: indexPath.row, section: 0)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    // MARK: - Add New Items
    fileprivate func saveItems() {
        do {
            try context.save()
        } catch {
            print("Error saving into context`", error.localizedDescription)
        }
    }
    
    @IBAction func didTapAdd(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New ToDoey Item", message: "", preferredStyle: .alert)
        alert.addTextField { (alertTextField) in
            textField.placeholder = "Create New Item"
            textField = alertTextField
        }
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            let indexPath = IndexPath(row: self.itemsArray.count, section: 0)
            let newItem = Item(context: context)
            newItem.title = textField.text
            newItem.done = false
            newItem.parentCategory = self.selectedCategory
            self.itemsArray.append(newItem)
            self.saveItems()
            self.tableView.insertRows(at: [indexPath], with: .automatic)
        }
        alert.addAction(action)
        present(alert, animated: true)
    }
}

extension ItemsTVC: UISearchBarDelegate {
    func fetch(_ request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", (selectedCategory?.name)!)
        if predicate != nil {
            let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, predicate!])
            request.predicate = compoundPredicate
        } else {
            request.predicate = categoryPredicate
        }
        
        do {
            itemsArray = try context.fetch(request)
            tableView.reloadData()
        } catch {
            print("Error fetching data with context : ", error.localizedDescription)
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            fetch()
            DispatchQueue.main.async { searchBar.resignFirstResponder() }
        } else {
            let request: NSFetchRequest<Item> = Item.fetchRequest()
            let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
            request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
            fetch(request, predicate: predicate)
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        fetch(request, predicate: predicate)
    }
}
