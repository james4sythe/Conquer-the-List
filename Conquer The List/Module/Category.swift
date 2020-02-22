//
//  Category.swift
//  Task Master
//
//  Created by James Forsythe on 8/16/18.
//  Copyright © 2018 James Forsythe. All rights reserved.
//

import Foundation
import RealmSwift

class Category : Object {
    @objc dynamic var name : String = ""
    @objc dynamic var colour : String = ""
    let items = List<Item>()
}
