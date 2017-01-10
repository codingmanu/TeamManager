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
    var showCompleted = false
    
    var ref: FIRDatabaseReference!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        collection.delegate = self
        collection.dataSource = self
        
        downloadInfo()
        
        getCurrentUserTasks()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        downloadInfo()
        collection.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return taskArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TaskCell", for: indexPath) as? TaskCell{
            let task = taskArray[indexPath.row]
            cell.configureCell(task)
            return cell
        }else{
            return UICollectionViewCell()
        }
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
        var ref: FIRDatabaseReference!
        ref = FIRDatabase.database().reference(withPath: "tasks/\(id)")
        ref.removeValue()
    }
    
    func changeCompletion(task:Task){

        var ref: FIRDatabaseReference!
        ref = FIRDatabase.database().reference(withPath: "tasks")

        ref.child("\(task._taskId!)/completed").setValue(task.completed.description)
        
    }
    
    func getCurrentUserTasks() -> [String]{
        let user = FIRAuth.auth()?.currentUser?.uid
        var tasks = [String]()
        ref = FIRDatabase.database().reference(withPath: "users/\(user!)/tasks")
        
        ref.observe(.value, with: { snapshot in
            for child in snapshot.children{
                if let childTask = child as? FIRDataSnapshot{
                    let taskId = childTask.value as! String
                    tasks.append(taskId)
                }
            }
        })
        return tasks
    }
    
    func downloadInfo(){
        
        ref = FIRDatabase.database().reference(withPath: "tasks")
        
        ref.observe(.value, with: { snapshot in
            
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
                    
                }
                
                self.initTaskCollection(task: task)
            }
        })
        
        
    }
    
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
