//
//  CreateNoteViewController.swift
//  Notes
//
//  Created by Тимур Кошевой on 5/4/19.
//  Copyright © 2019 Тимур Кошевой. All rights reserved.
//

import UIKit
import RealmSwift

class CreateNoteViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var textViewOutlet: UITextView!
    @IBOutlet weak var saveButtonOutlet: UIBarButtonItem!
    
    // MARK: - Properties
    let realm = try! Realm()
    var passedState: Int? // 0 - Add new note. 1 - Details screen. 2 - Edit screen
    var passedNoteId: String?
    var items: Results<NotesModel>!
    
    // MARK: - Funcs
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("#1")
        print(passedState)
        print(passedNoteId)
        print("#2")
        
        handleState()
    }
    
    func writeToDB() {
        let myNotes = NotesModel()
        
        let now = Date()
        print(now)
        let formatter = DateFormatter()
        
        formatter.timeZone = TimeZone.current
        
        formatter.dateFormat = "dd.MM.yyyy HH:mm"
        
        let dateString = formatter.string(from: now)
        
        myNotes.noteText = textViewOutlet.text
//        myNotes.dateTime = "\(Date().timeIntervalSince1970)"
        myNotes.dateTime = dateString

        try! realm.write {
            realm.add(myNotes)
        }
        
        items = realm.objects(NotesModel.self)
        
        for i in 0..<items.count{
            print(items[i].noteText)
            print(items[i].dateTime)
            print(items[i].noteID)
//            print(items[i].date)
        }
        
    }
    
    func handleState() {
        if passedState == 0 {
            saveButtonOutlet.title = "Save"
        } else if passedState == 1 {
            saveButtonOutlet.title = "Share"
            
            items = realm.objects(NotesModel.self)
            
            let currentNote = realm.object(ofType: NotesModel.self, forPrimaryKey: passedNoteId)
            textViewOutlet.text = currentNote?.noteText
            textViewOutlet.isEditable = false
            
        } else if passedState == 2 {
            saveButtonOutlet.title = "Edit"
            
            items = realm.objects(NotesModel.self)
            
            let currentNote = realm.object(ofType: NotesModel.self, forPrimaryKey: passedNoteId)
            textViewOutlet.text = currentNote?.noteText
        }
    }
    
    func updateTableAndPopToRootVc() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
        navigationController?.popToRootViewController(animated: true)
    }
    
    // MARK: - Actions
    @IBAction func saveNoteAction(_ sender: Any) {
        
        if passedState == 0 /* Create */{
            if textViewOutlet.text == "" {
                navigationController?.popToRootViewController(animated: true)
            } else {
                writeToDB()
                updateTableAndPopToRootVc()
            }
        } else if passedState == 1 /* Detail&Share */ {
            
            //insert sharing logic here
            
        } else if passedState == 2 /* Edit */ {
            
            let currentNote = realm.object(ofType: NotesModel.self, forPrimaryKey: passedNoteId)
            
            if textViewOutlet.text .isEmpty {
                
                try! realm.write {
                    realm.delete(currentNote!)
                }
                updateTableAndPopToRootVc()
                
            } else {
                try! realm.write {
                    currentNote!.noteText = textViewOutlet.text
                }
                updateTableAndPopToRootVc()
            }
            
        }
        
        
        
        
    }
    
}
