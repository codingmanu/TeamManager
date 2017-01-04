//
//  AddTaskViewController.swift
//  TeamManager
//
//  Created by Manuel S. Gomez on 12/28/16.
//  Copyright © 2016 Manuel S. Gomez. All rights reserved.
//

import UIKit

class AddTaskViewController: UIViewController {
    
    @IBOutlet weak var taskTypeSelector: UISegmentedControl!
    @IBOutlet weak var addDateBtn: UIButton!
    @IBOutlet weak var assignToUserBtn: UIButton!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var userLbl: UILabel!
    
    let taskSubViewsLauncher = TaskSubViewsLauncher()
    var task: Task? = nil
    
    @IBAction func addDateBtnTapped(_ sender: Any) {
        hideKeyboard()
        if addDateBtn.titleLabel?.text != "Delete"{
            taskSubViewsLauncher.selectDate()
            
            NotificationCenter.default.addObserver(self, selector: #selector(updateUI), name: Notification.Name("taskDateSelected"), object: taskSubViewsLauncher.date)
        }else{
            //We remote the date from the task object and the label
            task?.createdOn = nil
            dateLbl.text = ""
            addDateBtn.setTitle("Add Date", for: UIControlState.normal)

        }
    }
    
    @IBAction func assignToUserBtnTapped(_ sender: Any) {
        hideKeyboard()
        taskSubViewsLauncher.selectUser()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        task = Task(name: "", type: taskType.userTask)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.hideKeyboard))
        self.view.addGestureRecognizer(tap)
        
        self.view.isUserInteractionEnabled = true
        
    }
    
    func hideKeyboard(){
        UIView.animate(withDuration: 0.5) {
            self.view.endEditing(true)
        }
    }
    
    func updateUI(){
        self.task?.createdOn = taskSubViewsLauncher.date
        let myFormatter = DateFormatter()
        myFormatter.dateFormat = "yyyy/MM/dd hh:mm z"
        
        if self.task != nil && self.task?.createdOn != nil{
            myFormatter.date(from: (self.task!.createdOn!.description))
            
            let formattedDate = myFormatter.string(from: (self.task!.createdOn)!)
            //addDateBtn.setTitle(formattedDate, for: UIControlState.normal)
            dateLbl.text = formattedDate
            addDateBtn.setTitle("Delete", for: UIControlState.normal)
            
        }
        
        
        
        //print(self.task!.createdOn!)
        //print(myFormatter.string(from: (self.task?.createdOn)!))
        
    }
    
}
