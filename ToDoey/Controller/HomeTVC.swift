//
//  HomeTVC.swift
//  ToDoey
//
//  Created by Vandan Patel on 12/16/17.
//  Copyright © 2017 Vandan Patel. All rights reserved.
//

import UIKit

class HomeTVC: UITableViewController {
    
    var itemsArray = [Item]()
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let newItem1 = Item(title: "Find Mike", done: true)
        let newItem2 = Item(title: "Find Kohli", done: false)
        let newItem3 = Item(title: "Find Anushka", done: false)
        itemsArray.append(newItem1)
        itemsArray.append(newItem2)
        itemsArray.append(newItem3)
        
        loadItems()
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
    
    // MARK: - Add New Items
    fileprivate func saveItems() {
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(self.itemsArray)
            try data.write(to: self.dataFilePath!)
        } catch {
            print("Error encoding item array", error.localizedDescription)
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
            self.itemsArray.append(Item(title: textField.text!, done: false))
            self.saveItems()
            self.tableView.insertRows(at: [indexPath], with: .automatic)
        }
        alert.addAction(action)
        present(alert, animated: true)
    }
    
    func loadItems() {
        do {
            let data = try Data(contentsOf: dataFilePath!)
            let decoder = PropertyListDecoder()
            self.itemsArray = try decoder.decode([Item].self, from: data)
        } catch {
            print("Error decoding")
        }
        
    }
}
