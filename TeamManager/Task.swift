//
//  Task.swift
//  TeamManager
//
//  Created by Manuel S. Gomez on 12/27/16.
//  Copyright © 2016 Manuel S. Gomez. All rights reserved.
//

import UIKit
import FirebaseAuth

class Task {
    
    var _taskId: String!
    var _name: String!
    var _type: taskType
    var createdBy: String
    var createdOn: Date
    var dueDate: Date?
    var completed = false
    
    init(id: String, name: String, type: taskType, creator:String){
        self._taskId = id
        self._name = name
        self._type = type
        self.createdBy = creator
        createdOn = Date.init()
    }
    
}

enum taskType:String {
    
    case userTask = "userTask"
    case teamTask = "teamTask"
    
}
