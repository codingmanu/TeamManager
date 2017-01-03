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
    
    let taskSubViewsLauncher = TaskSubViewsLauncher()
    
    @IBAction func addDateBtnTapped(_ sender: Any) {
        hideKeyboard()
        taskSubViewsLauncher.selectDate()
    }
    
    @IBAction func assignToUserBtnTapped(_ sender: Any) {
        hideKeyboard()
        taskSubViewsLauncher.selectUser()
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
    
}
