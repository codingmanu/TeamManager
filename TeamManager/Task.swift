//
//  Task.swift
//  TeamManager
//
//  Created by Manuel S. Gomez on 12/27/16.
//  Copyright © 2016 Manuel S. Gomez. All rights reserved.
//

import UIKit

class Task {
    
    var _taskId: String!
    var _name: String!
    var _type: taskType
    var createdBy: String?
    var createdOn: Date?
    
    init(id: String, name: String, type: taskType){
        self._taskId = id
        self._name = name
        self._type = type
    }
    
}

enum taskType:String {
    
    case userTask = "userTask"
    case teamTask = "teamTask"
    
}
