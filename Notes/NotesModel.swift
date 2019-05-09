//
//  NotesModel.swift
//  Notes
//
//  Created by Тимур Кошевой on 5/8/19.
//  Copyright © 2019 Тимур Кошевой. All rights reserved.
//

import Foundation
import RealmSwift

class NotesModel: Object {
    
    @objc dynamic var noteID = UUID().uuidString
    @objc dynamic var noteText: String?
    @objc dynamic var dateTime: String?
//    @objc dynamic var date = Date()
    
    override static func primaryKey() -> String? {
        return "noteID"
    }
}
