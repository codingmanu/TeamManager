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
    var tasks:[Task] = [Task]()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        collection.delegate = self
        collection.dataSource = self
        
        if user != nil {
            print("Current user: \(user.email)")
        }else{
            print("No users logged in")
        }
        
        downloadInfo()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        collection.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TaskCell", for: indexPath) as? TaskCell{
            let task = tasks[indexPath.row]
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
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { action in
            
        }))

        alert.addAction(UIAlertAction(title: "Delete task", style: UIAlertActionStyle.destructive, handler: { action in
            self.deleteTask(number: indexPath.row)
            self.tasks.remove(at: indexPath.row)
        }))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    func deleteTask(number: Int){
        var ref: FIRDatabaseReference!
        
        ref = FIRDatabase.database().reference(withPath: "tasks/\(number)")
        ref.removeValue()
        
    }
    
    func downloadInfo(){
        var ref: FIRDatabaseReference!
        
        ref = FIRDatabase.database().reference(withPath: "tasks")
        
        ref.observe(.value, with: { snapshot in
            for child in snapshot.children {
                let task = Task.init(id: "", name: "", type: .userTask)
                if let a = child as? FIRDataSnapshot{
                    if let taskId = a.childSnapshot(forPath: "taskId").value as? String{
                        task._taskId = taskId
                    }
                    if let title = a.childSnapshot(forPath: "title").value as? String{
                        task._name = title
                    }
                    if let type = a.childSnapshot(forPath: "taskType").value as? String{
                        if type == "userTask"{
                            task._type = .userTask
                        }else{
                            task._type = .teamTask
                        }
                    }
                    
                }
                self.tasks.append(task)
                self.collection.reloadData()
            }
        })

        
    }
    
}
