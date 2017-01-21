
//
//  TaskCell.swift
//  TeamManager
//
//  Created by Manuel S. Gomez on 12/27/16.
//  Copyright © 2016 Manuel S. Gomez. All rights reserved.
//

import UIKit
import Firebase

class TaskCell: UICollectionViewCell {
    
    var task: Task!
    
    @IBOutlet weak var cellText: UILabel!
    @IBOutlet weak var cellImg: UIImageView!
    @IBOutlet weak var dueDateLbl: UILabel!
    @IBOutlet weak var assignedToUserImg: UIImageView!
    @IBOutlet weak var assignedToUserLbl: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configureCell(_ task: Task){
        //We assign which task belong to this cell
        self.task = task
        
        //We define the icon for user or team task
        cellImg.image = UIImage(named: task._type.rawValue)
        
        if task.dueDate != nil {
            dueDateLbl.isHidden = false
            dueDateLbl.text = "Due: \(task.dueDate!)"
        }else{
            dueDateLbl.isHidden = true
            dueDateLbl.text = ""
        }
        
        if task.assignedTo != nil {
            assignedToUserImg.image = UIImage(named: "user")
            getAssignedUserName()
        }else{
            assignedToUserImg.image = nil
            assignedToUserLbl.text = nil
        }
        
        
        
        //Depending on if the task is completed or not, we strike through the text and turn it gray along with the icon
        if task.completed{
            let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: task._name)
            attributeString.addAttribute(
                NSStrikethroughStyleAttributeName,
                value: 2,
                range: NSMakeRange(0, attributeString.length))
            
            attributeString.addAttribute(
                NSForegroundColorAttributeName,
                value: UIColor.darkGray,
                range: NSMakeRange(0, attributeString.length))
            //Apply to the label
            cellText.attributedText = attributeString
            cellImg.tintColor = UIColor.darkGray
            self.backgroundColor = UIColor.lightGray
            
        }else{
            cellText.text = task._name
            cellImg.tintColor = UIColor.blue
            self.backgroundColor = UIColor.white
        }
    }
    
    func getAssignedUserName(){
        
        let ref = FIRDatabase.database().reference(withPath: "users/\(self.task.assignedTo!)/fullName")
        ref.observeSingleEvent(of: .value, with: { snapshot in
            if let name = snapshot.value as? String{
                self.assignedToUserLbl.text = name
            }
        })
    }
    
}
