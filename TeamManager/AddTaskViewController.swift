//
//  AddTaskViewController.swift
//  TeamManager
//
//  Created by Manuel S. Gomez on 12/28/16.
//  Copyright © 2016 Manuel S. Gomez. All rights reserved.
//

import UIKit
import Firebase

class AddTaskViewController: UIViewController {
    
    @IBOutlet weak var taskTypeSelector: UISegmentedControl!
    @IBOutlet weak var addDateBtn: UIButton!
    @IBOutlet weak var assignToUserBtn: UIButton!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var userLbl: UILabel!
    @IBOutlet weak var taskTextTF: UITextField!
    
    let taskSubViewsLauncher = TaskSubViewsLauncher()
    var task: Task = Task(id: "", name: "", type: taskType.userTask)
    
    @IBAction func addDateBtnTapped(_ sender: Any) {
        hideKeyboard()
        if addDateBtn.titleLabel?.text != "Delete"{
            taskSubViewsLauncher.selectDate()
            
            NotificationCenter.default.addObserver(self, selector: #selector(updateUI), name: Notification.Name("taskDateSelected"), object: taskSubViewsLauncher.date)
        }else{
            //We remote the date from the task object and the label
            task.createdOn = nil
            dateLbl.text = ""
            addDateBtn.setTitle("Add Date", for: UIControlState.normal)
            
        }
    }
    
    @IBAction func assignToUserBtnTapped(_ sender: Any) {
        hideKeyboard()
        taskSubViewsLauncher.selectUser()
    }
    
    @IBAction func doneBtnTapped(_ sender: Any) {
        if taskTextTF.text != "" {
            task._name = taskTextTF.text
            if taskTypeSelector.selectedSegmentIndex == 1 { task._type = .teamTask }
            
            performSegue(withIdentifier: "taskAdded", sender: nil)
            
            //print(task._name)
            //print(task._type)
            //print(task.createdOn?.description)
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        self.task.createdOn = taskSubViewsLauncher.date
        let myFormatter = DateFormatter()
        myFormatter.dateFormat = "yyyy/MM/dd hh:mm z"
        
        if self.task.createdOn != nil{
            myFormatter.date(from: (self.task.createdOn!.description))
            
            let formattedDate = myFormatter.string(from: (self.task.createdOn)!)
            //addDateBtn.setTitle(formattedDate, for: UIControlState.normal)
            dateLbl.text = formattedDate
            addDateBtn.setTitle("Delete", for: UIControlState.normal)
            
        }
        //print(self.task!.createdOn!)
        //print(myFormatter.string(from: (self.task?.createdOn)!))
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "taskAdded" {
            uploadTask()
        }
    }
    
    func uploadTask(){
        var ref: FIRDatabaseReference!
        
        ref = FIRDatabase.database().reference(withPath: "tasks")

        let randomNum:UInt32 = arc4random_uniform(100)
        ref.child("\(randomNum)/title").setValue(self.task._name)
        ref.child("\(randomNum)/taskType").setValue(self.task._type.rawValue)
        
    }

}
