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
    var createdBy: String
    var createdOn = ""
    var dueDate: String?
    var assignedTo: String?
    var completed = false
    var taskSelected = false
    
    
    init(id: String, name: String, type: taskType, creator:String){
        self._taskId = id
        self._name = name
        self._type = type
        self.createdBy = creator
        self.createdOn = self.created()
    }
    
    func created() -> String{
        
        let date = Date()
        let myFormatter = DateFormatter()
        myFormatter.dateFormat = "yyyy/MM/dd"
        myFormatter.date(from: (date.description))
        
        let formattedDate = myFormatter.string(from: (date))
        return formattedDate
    }
    
    
    
}

enum taskType:String {
    
    case userTask = "userTask"
    case teamTask = "teamTask"
    
}
