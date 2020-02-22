//
//  Item.swift
//  Task Master
//
//  Created by James Forsythe on 8/16/18.
//  Copyright © 2018 James Forsythe. All rights reserved.
//

import Foundation
import RealmSwift

class Item : Object {
    @objc dynamic var name : String = ""
    @objc dynamic var done : Bool = false
    @objc dynamic var dateCreated : Date?
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
