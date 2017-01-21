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
    var task: Task = Task(id: "", name: "", type: taskType.userTask, creator: "")
    
    @IBAction func addDateBtnTapped(_ sender: Any) {
        hideKeyboard()
        if addDateBtn.titleLabel?.text != "Delete"{
            taskSubViewsLauncher.selectDate()
            
            NotificationCenter.default.addObserver(self, selector: #selector(updateUI), name: Notification.Name("taskDateSelected"), object: taskSubViewsLauncher.date)
        }else{
            //We remove the date from the task object and the label
            task.dueDate = nil
            dateLbl.text = ""
            addDateBtn.setTitle("Add Date", for: UIControlState.normal)
        }
    }
    
    @IBAction func assignToUserBtnTapped(_ sender: Any) {
        hideKeyboard()
        if assignToUserBtn.titleLabel?.text != "Delete"{
            taskSubViewsLauncher.selectUser()
            
            NotificationCenter.default.addObserver(self, selector: #selector(updateUI), name: Notification.Name("taskUserSelected"), object: taskSubViewsLauncher.selectedUser)
        }else{
            //We remove the user from the task object and the label
            task.assignedTo = nil
            userLbl.text = ""
            assignToUserBtn.setTitle("Assign to User", for: UIControlState.normal)
        }
    }
    
    @IBAction func doneBtnTapped(_ sender: Any) {
        if taskTextTF.text != "" {
            task._name = taskTextTF.text
            if taskTypeSelector.selectedSegmentIndex == 1 { task._type = .teamTask }
            
            performSegue(withIdentifier: "taskAdded", sender: nil)
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
        
        let dueDate = taskSubViewsLauncher.date
        let assignedUser = taskSubViewsLauncher.selectedUser
        let myFormatter = DateFormatter()
        myFormatter.dateFormat = "yyyy/MM/dd"
        
        if dueDate != nil{
            myFormatter.date(from: (dueDate!.description))
            
            let formattedDate = myFormatter.string(from: (dueDate)!)
            dateLbl.text = formattedDate
            self.task.dueDate = formattedDate
            addDateBtn.setTitle("Delete", for: UIControlState.normal)
            
        }
        if assignedUser != nil{
            userLbl.text = assignedUser!.1
            self.task.assignedTo = assignedUser!.0
            assignToUserBtn.setTitle("Delete", for: UIControlState.normal)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "taskAdded" {
            uploadTask()
        }
    }
    
    func uploadTask(){
        var ref: FIRDatabaseReference!
        ref = FIRDatabase.database().reference(withPath: "tasks")
        
        let taskId = ref.childByAutoId().key
        let user = FIRAuth.auth()?.currentUser?.uid
        
        ref.child("\(taskId)/title").setValue(self.task._name)
        ref.child("\(taskId)/taskType").setValue(self.task._type.rawValue)
        ref.child("\(taskId)/creator").setValue(user)
        
        ref.child("\(taskId)/createdOn").setValue(self.task.createdOn)
        
        ref.child("\(taskId)/completed").setValue(self.task.completed.description)
        
        if let date = self.task.dueDate {
            ref.child("\(taskId)/dueDate").setValue(date)
        }
        if task.assignedTo != nil {
            ref.child("\(taskId)/assignedTo").setValue(self.task.assignedTo)
            addTaskToUser(taskId: taskId.description, user: self.task.assignedTo, type:"assigned")
        }
        addTaskToUser(taskId: taskId.description, user: user, type:"self")
    }
    
    func addTaskToUser(taskId: String!, user:String!, type:String!){
        var ref: FIRDatabaseReference!
        ref = FIRDatabase.database().reference(withPath: "users")
        
        ref.child("\(user!)/tasks").child("\(taskId!)").setValue(type)
    }
    
    
    
}
