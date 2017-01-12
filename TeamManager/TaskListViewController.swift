//
//  TaskListViewController.swift
//  TeamManager
//
//  Created by Manuel S. Gomez on 12/27/16.
//  Copyright © 2016 Manuel S. Gomez. All rights reserved.
//

import UIKit
import Firebase

class TaskListViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collection: UICollectionView!
    @IBOutlet weak var showCompletedBtn: UIButton!
    
    var user: FIRUser! = nil
    var tasks = Dictionary<String, Task>()
    var taskArray = [Task]()
    var userTaskList = [String]()
    var showCompleted = false
    
    var ref: FIRDatabaseReference!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        collection.delegate = self
        collection.dataSource = self
        
        getCurrentUserTasks()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        getCurrentUserTasks()
        collection.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return taskArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let task = taskArray[indexPath.row]
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TaskCell", for: indexPath) as? TaskCell{
            cell.configureCell(task)
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let task = taskArray[indexPath.row]
        if !showCompleted && task.completed{
            return CGSize(width: collection.frame.width, height: 0)
        }
        return CGSize(width: collection.frame.width, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // create the alert
        let alert = UIAlertController(title: "Notice", message: "What?", preferredStyle: UIAlertControllerStyle.alert)
        
        if self.taskArray[indexPath.row].completed{
            alert.addAction(UIAlertAction(title: "Mark as not done", style: UIAlertActionStyle.default, handler: { action in
                self.taskArray[indexPath.row].completed = false
                self.changeCompletion(task: self.taskArray[indexPath.row])
            }))
        }else{
            alert.addAction(UIAlertAction(title: "Mark as done", style: UIAlertActionStyle.default, handler: { action in
                self.taskArray[indexPath.row].completed = true
                self.changeCompletion(task: self.taskArray[indexPath.row])
            }))
        }
        // add the actions (buttons)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Delete task", style: UIAlertActionStyle.destructive, handler: { action in
            self.tasks.removeValue(forKey: self.taskArray[indexPath.row]._taskId)
            self.deleteTask(id: self.taskArray[indexPath.row]._taskId)
            if self.tasks.isEmpty {
                self.taskArray.removeAll()
                self.collection.reloadData()
            }
        }))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func showCompletedBtnTapped(_ sender: Any) {
        if showCompleted{
            showCompletedBtn.setTitle("Show completed tasks", for: UIControlState.normal)
            showCompleted = false
            collection.reloadData()
        }else{
            showCompletedBtn.setTitle("Hide completed tasks", for: UIControlState.normal)
            showCompleted = true
            collection.reloadData()
        }
    }
    
    
    func deleteTask(id: String){
        let user = FIRAuth.auth()?.currentUser?.uid
        var ref: FIRDatabaseReference!
        ref = FIRDatabase.database().reference(withPath: "tasks/\(id)")
        ref.removeValue()
        
        ref = FIRDatabase.database().reference(withPath: "users/\(user!)/tasks/\(id)")
        ref.removeValue()
    }
    
    //This updates the tasks' completion
    func changeCompletion(task:Task){
        
        var ref: FIRDatabaseReference!
        ref = FIRDatabase.database().reference(withPath: "tasks")
        
        ref.child("\(task._taskId!)/completed").setValue(task.completed.description)
        
    }
    
    //This function queries the tasks from the current user object
    func getCurrentUserTasks(){
        let user = FIRAuth.auth()?.currentUser?.uid
        
        ref = FIRDatabase.database().reference(withPath: "users/\(user!)/tasks")
        
        ref.observeSingleEvent(of: .value, with: { snapshot in
            self.userTaskList.removeAll()
            for child in snapshot.children{
                if let childTask = child as? FIRDataSnapshot{
                    if let taskId = childTask.value as? String{
                        self.userTaskList.append(taskId)
                    }
                }
            }
            self.downloadTasksInfo()
        })
    }
    
    //This function downloads the task info from the task list saved by getCurrentUserTasks()
    func downloadTasksInfo(){
        
        let user = FIRAuth.auth()?.currentUser?.uid
        if userTaskList.count > 0{
            let ref = FIRDatabase.database().reference().child("tasks").queryOrdered(byChild: "creator").queryEqual(toValue: user)
            ref.observe(.value, with:{ (snapshot: FIRDataSnapshot) in
                self.taskArray.removeAll()
                self.tasks.removeAll()
                self.collection.reloadData()
                
                for child in snapshot.children {
                    let task = Task.init(id: "", name: "", type: .userTask, creator: "")
                    
                    if let childTask = child as? FIRDataSnapshot{
                        task._taskId = childTask.key
                        
                        if let title = childTask.childSnapshot(forPath: "title").value as? String{
                            task._name = title
                        }
                        if let type = childTask.childSnapshot(forPath: "taskType").value as? String{
                            if type == "userTask"{
                                task._type = .userTask
                            }else{
                                task._type = .teamTask
                            }
                        }
                        
                        if let creator = childTask.childSnapshot(forPath: "creator").value as? String{
                            task.createdBy = creator
                        }
                        
                        if let completed = childTask.childSnapshot(forPath: "completed").value as? String{
                            if completed == "true"{
                                task.completed = true
                            }
                        }
                        
                        if let dueDate = childTask.childSnapshot(forPath: "dueDate").value as? String{
                            task.dueDate = dueDate
                        }
                        
                        if let assignedTo = childTask.childSnapshot(forPath: "assignedTo").value as? String{
                            task.assignedTo = assignedTo
                        }
                        
                    }
                    
                    self.initTaskCollection(task: task)
                }
            })
        }
    }
    
    
    //This function converts the tasks Dictionary into an array for the collection view to pull data from.
    func initTaskCollection(task: Task) {
        
        self.taskArray.removeAll()
        self.tasks[task._taskId] = task
        
        let tasksArray = tasks.sorted{ $0.key > $1.key }
        
        for task in tasksArray {
            self.taskArray.append(task.value)
        }
        
        self.collection.reloadData()
    }
}
