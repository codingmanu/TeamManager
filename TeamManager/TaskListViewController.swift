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
    
    var user: FIRUser! = nil
    var tasks = Dictionary<String, Task>()
    var taskArray = [Task]()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        collection.delegate = self
        collection.dataSource = self
        
        downloadInfo()
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
        return CGSize(width: 250, height: 30)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // create the alert
        let alert = UIAlertController(title: "Notice", message: "What?", preferredStyle: UIAlertControllerStyle.alert)
        
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Mark as done", style: UIAlertActionStyle.default, handler: { action in
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Delete task", style: UIAlertActionStyle.destructive, handler: { action in
            self.tasks.removeValue(forKey: self.taskArray[indexPath.row]._taskId)
            self.deleteTask(id: self.taskArray[indexPath.row]._taskId)
        }))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    func deleteTask(id: String){
        var ref: FIRDatabaseReference!
        
        
        ref = FIRDatabase.database().reference(withPath: "tasks/\(id)")
        ref.removeValue()
        
    }
    
    func downloadInfo(){
        var ref: FIRDatabaseReference!
        
        ref = FIRDatabase.database().reference(withPath: "tasks")
        
        ref.observe(.value, with: { snapshot in
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
