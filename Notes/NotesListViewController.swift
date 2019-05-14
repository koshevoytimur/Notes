//
//  ViewController.swift
//  Notes
//
//  Created by Тимур Кошевой on 5/4/19.
//  Copyright © 2019 Тимур Кошевой. All rights reserved.
//

import UIKit
import RealmSwift

class NotesListViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var searchBarOutlet: UISearchBar!
    @IBOutlet weak var tableViewOutlet: UITableView!
    
    // MARK: - Properties
    let cellId = "noteCell"
    let realm = try! Realm()
    var items: Results<NotesModel>!
    var passedState: Int? // 0 - Add new note. 1 - Details screen. 2 - Edit screen
    var passValue: Bool = false
    var index: Int?
    
    // MARK: - Funcs
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableViewOutlet.delegate = self
        tableViewOutlet.dataSource = self
        searchBarOutlet.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadList), name: NSNotification.Name(rawValue: "load"), object: nil)
        
        sortObjects()
    }
    
    func sortObjects() {
        let ascending = UserDefaults.standard.bool(forKey: "ascending")
        let sortedByKeyPath = UserDefaults.standard.string(forKey: "sortedByKeyPath")
        
        if searchBarOutlet.text == "" {
            items = realm.objects(NotesModel.self).sorted(byKeyPath: sortedByKeyPath!, ascending: ascending)
        } else {
            items = realm.objects(NotesModel.self).sorted(byKeyPath: sortedByKeyPath!, ascending: ascending).filter("noteText CONTAINS[c] %@", searchBarOutlet.text!)
        }
        
    }
    
    @objc func loadList(notification: NSNotification){
        self.tableViewOutlet.reloadData()
    }
    
    func dismissKeyboardOnTap() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    // Hide Keyboard.
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "NotesListToCreateNote") {
            let createVC = segue.destination as? CreateNoteViewController
            createVC!.passedState = passedState
            if passValue {
                if passedState == 1{
                    self.index = tableViewOutlet.indexPathForSelectedRow?.row
                    createVC!.passedNoteId = items![index!].noteID
                } else if passedState == 2 {
                    createVC!.passedNoteId = items![index!].noteID
                    
                }
            }
        }
    }
    
    // MARK: - Actions
    @IBAction func addNoteAction(_ sender: Any) {
        dismissKeyboard()
        passedState = 0
        passValue = false
        performSegue(withIdentifier: "NotesListToCreateNote", sender: self)
    }
    
    @IBAction func sortNotesAction(_ sender: Any) {
        dismissKeyboard()
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "From new to old", style: .default , handler:{ (UIAlertAction)in
            
            UserDefaults.standard.set(false, forKey: "ascending")
            UserDefaults.standard.set("dateTime", forKey: "sortedByKeyPath")
            
            self.sortObjects()
            self.tableViewOutlet.reloadData()
        }))
        
        alert.addAction(UIAlertAction(title: "From old to new", style: .default , handler:{ (UIAlertAction)in
            
            UserDefaults.standard.set(true, forKey: "ascending")
            UserDefaults.standard.set("dateTime", forKey: "sortedByKeyPath")
            
            self.sortObjects()
            self.tableViewOutlet.reloadData()
        }))
        
        alert.addAction(UIAlertAction(title: "Alphabetically", style: .default , handler:{ (UIAlertAction)in
            
            UserDefaults.standard.set(true, forKey: "ascending")
            UserDefaults.standard.set("noteText", forKey: "sortedByKeyPath")
            
            self.sortObjects()
            self.tableViewOutlet.reloadData()
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
}

// MARK: - Extensions
// MARK: - TableViewDelegate and TableViewDataSource
extension NotesListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if items.count != 0 {
            return items.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableViewOutlet.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        
        let item = items[indexPath.row]
        cell.textLabel?.text = item.noteText
        cell.detailTextLabel?.text = item.dateTime
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        dismissKeyboard()
        
        let editingRow = items[indexPath.row]
        
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete") { _,_ in
            try! self.realm.write {
                self.realm.delete(editingRow)
                self.tableViewOutlet.reloadData()
            }
        }
        
        let editAction = UITableViewRowAction(style: .normal, title: "Edit") { _,_ in
            self.passedState = 2
            self.passValue = true
            self.index = indexPath.row
            self.performSegue(withIdentifier: "NotesListToCreateNote", sender: self)
        }
        
        return [deleteAction, editAction]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You selected cell #\(indexPath.row)!")
        dismissKeyboard()
        
        passedState = 1
        passValue = true
        performSegue(withIdentifier: "NotesListToCreateNote", sender: self)
        tableViewOutlet.deselectRow(at: indexPath, animated: true)
    }
    
}

// MARK: - SearchBarDelegate
extension NotesListViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        let ascending = UserDefaults.standard.bool(forKey: "ascending")
        let sortedByKeyPath = UserDefaults.standard.string(forKey: "sortedByKeyPath")
        
        let searchText = searchBarOutlet.text
        
        if searchText == "" {
            items = realm.objects(NotesModel.self).sorted(byKeyPath: sortedByKeyPath!, ascending: ascending)
            self.tableViewOutlet.reloadData()
        } else {
            items = realm.objects(NotesModel.self).filter("noteText CONTAINS[c] %@", searchText!)
            self.tableViewOutlet.reloadData()
        }
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBarOutlet.text = ""
        tableViewOutlet.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBarOutlet.endEditing(true)
    }
    
}
