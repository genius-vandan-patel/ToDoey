//
//  Item.swift
//  ToDoey
//
//  Created by Vandan Patel on 12/17/17.
//  Copyright © 2017 Vandan Patel. All rights reserved.
//

import Foundation

class Item: Codable {
    var title: String = ""
    var done: Bool = false
    
    init(title: String, done: Bool) {
        self.title = title
        self.done = done
    }
}
