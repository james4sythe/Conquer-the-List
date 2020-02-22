//
//  ItemViewController.swift
//  Task Master
//
//  Created by James Forsythe on 8/15/18.
//  Copyright © 2018 James Forsythe. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class ItemViewController: SwipeViewController {
    
    var taskItems: Results<Item>?
    let realm = try! Realm()
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var selectedCategory : Category? {
        didSet{
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        title = selectedCategory?.name
        
        guard let colourHex = selectedCategory?.colour else { fatalError() }
        
        updateNavBar(withHexCode: colourHex)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        updateNavBar(withHexCode: "1D9BF6")
        
    }
    
    //MARK: - Nav Bar Setup Methods
    
    func updateNavBar(withHexCode colourHexCode: String){
        
        guard let navBar = navigationController?.navigationBar else {fatalError("Navigation controller does not exist.")}
        
        guard let navBarColour = UIColor(hexString: colourHexCode) else { fatalError()}
        
        navBar.barTintColor = navBarColour
        
        navBar.tintColor = ContrastColorOf(navBarColour, returnFlat: true)
        
        navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : ContrastColorOf(navBarColour, returnFlat: true)]
        
        searchBar.barTintColor = navBarColour
        
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = taskItems?[indexPath.row] {
            
            cell.textLabel?.text = item.name
            
            if let colour = UIColor(hexString: selectedCategory!.colour)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(taskItems!.count)) {
                cell.backgroundColor = colour
                cell.textLabel?.textColor = ContrastColorOf(colour, returnFlat: true)
            }
            
            cell.accessoryType = item.done ? .checkmark : .none
        } else {
            cell.textLabel?.text = "No Items Added"
        }
        
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let completeAlert = UIAlertController(title: "Task Action", message: "Choose your action below.", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Complete/Delete", style: .default) { (action) in
            
            if let item = self.taskItems?[indexPath.row] {
                do {
                    try self.realm.write {
                        self.realm.delete(item)
                    }
                } catch {
                    print("Error deleting Item, \(error)")
                }
                
                tableView.reloadData()
                
                tableView.deselectRow(at: indexPath, animated: true)
                
            }
        }
        
        let check = UIAlertAction(title: "Check/Uncheck", style: .default) { (check) in
            if let item = self.taskItems?[indexPath.row] {
                do {
                    try self.realm.write {
                        item.done = !item.done
                    }
                } catch {
                    print("Error saving done status, \(error)")
                }
                
                tableView.reloadData()
                
                tableView.deselectRow(at: indexPath, animated: true)
            }

        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .default) { (cancel) in
            self.dismiss(animated: true, completion: nil)
            
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
        completeAlert.addAction(action)
        completeAlert.addAction(check)
        completeAlert.addAction(cancel)
        
        
        present(completeAlert, animated: true, completion: nil)
        
    }
    
    //MARK: - Add New Items
    
    @IBAction func addButtonPressed(_ sender: Any) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            //what will happen once the user clicks the Add Item button on our UIAlert
            
            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write {
                        let newItem = Item()
                        newItem.name = textField.text!
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)
                    }
                } catch {
                    print("Error saving new items, \(error)")
                }
            }
            
            self.tableView.reloadData()
            
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .default) { (cancel) in
            self.dismiss(animated: true, completion: nil)
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
            
        }
        
        
        alert.addAction(action)
        alert.addAction(cancel)
        
        present(alert, animated: true, completion: nil)
    }
    
    //MARK - Model Manupulation Methods
    
    
    
    func loadItems() {
        
        taskItems = selectedCategory?.items.sorted(byKeyPath: "name", ascending: true)
        
        tableView.reloadData()
        
    }
    
    override func updateModel(at indexPath: IndexPath) {
        if let item = taskItems?[indexPath.row] {
            do {
                try realm.write {
                    realm.delete(item)
                }
            } catch {
                print("Error deleting Item, \(error)")
            }
        }
    }
    
}

//MARK: - Search bar methods

extension ItemViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        taskItems = taskItems?.filter("name CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            
        }
    }
}
