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
        
        items = realm.objects(NotesModel.self).sorted(byKeyPath: "dateTime", ascending: false)
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
            self.items = self.realm.objects(NotesModel.self).sorted(byKeyPath: "dateTime", ascending: false)
            self.tableViewOutlet.reloadData()
        }))
        
        alert.addAction(UIAlertAction(title: "From old to new", style: .default , handler:{ (UIAlertAction)in
            self.items = self.realm.objects(NotesModel.self).sorted(byKeyPath: "dateTime", ascending: true)
            self.tableViewOutlet.reloadData()
        }))
        
        alert.addAction(UIAlertAction(title: "Alphabetically", style: .default , handler:{ (UIAlertAction)in
            self.items = self.realm.objects(NotesModel.self).sorted(byKeyPath: "noteText", ascending: true)
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
                
        passedState = 1
        passValue = true
        performSegue(withIdentifier: "NotesListToCreateNote", sender: self)
        tableViewOutlet.deselectRow(at: indexPath, animated: true)

    }
    
}

// MARK: - SearchBarDelegate
extension NotesListViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBarOutlet.endEditing(true)
    }
    
}
