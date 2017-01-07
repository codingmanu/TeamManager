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
        taskSubViewsLauncher.selectUser()
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
        self.task.dueDate = taskSubViewsLauncher.date
        let myFormatter = DateFormatter()
        myFormatter.dateFormat = "yyyy/MM/dd"
        
        if self.task.dueDate != nil{
            myFormatter.date(from: (self.task.dueDate!.description))
            
            let formattedDate = myFormatter.string(from: (self.task.dueDate)!)
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
        
        let time = String(Int(Date().timeIntervalSince1970))
        let email = FIRAuth.auth()?.currentUser?.email!
        let emailId = email!.replacingOccurrences(of: "@", with: "(-at-)").replacingOccurrences(of: ".", with: "(-dot-)")
        let taskId = "\(emailId)-\(time)"

        ref.child("\(taskId)/title").setValue(self.task._name)
        ref.child("\(taskId)/taskType").setValue(self.task._type.rawValue)
        ref.child("\(taskId)/creator").setValue(email)
        
        if let date = self.task.dueDate {
            ref.child("\(taskId)/dueDate").setValue(date)
        }
    }

}
