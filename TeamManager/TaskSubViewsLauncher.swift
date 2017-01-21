//
//  TaskSubViewsLauncher.swift
//  TeamManager
//
//  Created by Manuel S. Gomez on 1/2/17.
//  Copyright © 2017 Manuel S. Gomez. All rights reserved.
//

import UIKit
import Firebase

class TaskSubViewsLauncher: NSObject {
    
    let blackView = UIView()
    let dateView = DatePicker()
    let userView = UserPicker()
    var date: Date? = nil
    var selectedUser: (String, String)?
    
    var popUpView = UIView()
    
    override init(){
        super.init()
    }
    
    func selectDate(){
        showWindow(view: dateView)
    }
    
    func selectUser(){
        showWindow(view: userView)
    }
    
    
    func showWindow(view: UIView){
        
        popUpView = view
        
        if let window = UIApplication.shared.keyWindow{
            
            blackView.backgroundColor = UIColor(white: 0, alpha: 0.5)
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleDismiss(_:)))
            blackView.addGestureRecognizer(tap)
            
            blackView.isUserInteractionEnabled = true
            
            window.addSubview(blackView)
            window.addSubview(popUpView)
            
            let height: CGFloat = 200
            let y = window.frame.height - height
            popUpView.frame = CGRect(x: 0, y: y, width: window.frame.width, height: window.frame.height)
            
            blackView.frame = window.frame
            blackView.alpha = 0
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.blackView.alpha = 1
                self.popUpView.alpha = 1
                
                self.popUpView.frame = CGRect(x: 0, y: window.frame.height/2, width: window.frame.width, height: window.frame.height / 2)
                
                self.popUpView.backgroundColor = .white
            }, completion: nil)
        }
    }
    
    func handleDismiss(_ sender: UITapGestureRecognizer){
        UIView.animate(withDuration: 0.5) {
            self.blackView.alpha = 0
            self.popUpView.alpha = 0
            
            self.popUpView.frame = CGRect(x: 0, y: self.popUpView.frame.height*2, width: self.popUpView.frame.width, height: self.popUpView.frame.height)
            
            if self.popUpView.isKind(of: DatePicker.self){
                if let view = self.popUpView as? DatePicker{
                    if view.returnDate() != nil {
                        self.date = view.returnDate()
                        let nc = NotificationCenter.default
                        nc.post(name: Notification.Name("taskDateSelected"), object: self.date)
                    }
                }
            }
            if self.popUpView.isKind(of: UserPicker.self){
                if let view = self.popUpView as? UserPicker{
                    if view.selectedUser != nil {
                        self.selectedUser = view.selectedUser!
                        let nc = NotificationCenter.default
                        nc.post(name: Notification.Name("taskUserSelected"), object: self.selectedUser)
                    }
                }
            }
        }
    }
    
}

class DatePicker: UIView{
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 20))
    let datePicker = UIDatePicker(frame: CGRect(x: 10, y: 60, width: 300, height: 300))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        label.text = "Select Due Date:"
        label.center = CGPoint(x: 120, y: 30)
        self.addSubview(label)
        
        datePicker.center = CGPoint(x: 200, y: 180)
        datePicker.datePickerMode = UIDatePickerMode.date
        self.addSubview(datePicker)
    }
    
    func returnDate() -> Date?{
        return datePicker.date
    }
    
}

class UserPicker: UIView, UIPickerViewDataSource,UIPickerViewDelegate{
    
    //var userIds = [String]()
    var teamMembersIds = [String]()
    var users = Dictionary<String, String>()
    var usersArray = [(String, String)]()
    var selectedUser: (String, String)?
    
    var label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 20))
    var userPickerObj = UIPickerView(frame: CGRect(x: 10, y: 60, width: 300, height: 300))
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        userPickerObj.delegate = self
        userPickerObj.dataSource = self
        
        downloadUserTeam()
        
        label.text = "Select User:"
        label.center = CGPoint(x: 120, y: 30)
        self.addSubview(label)
        
        userPickerObj.center = CGPoint(x: 200, y: 180)
        self.addSubview(userPickerObj)
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return usersArray[row].1
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedRow = pickerView.selectedRow(inComponent: component)
        if self.usersArray[selectedRow].0.characters.count > 0 {
            selectedUser = (self.usersArray[selectedRow].0,self.usersArray[selectedRow].1)
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return users.count
    }
    
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func downloadUserTeam(){
        let user = FIRAuth.auth()?.currentUser?.uid
        var teamId = ""
        
        let ref = FIRDatabase.database().reference(withPath: "users/\(user!)/team")
        
        ref.observeSingleEvent(of: .value, with: { snapshot in
            if let team = snapshot.value as? String{
                teamId = team
            }
            self.downloadTeamUsers(team: teamId)
        })
    }
    
    func downloadTeamUsers(team:String){
        
        let ref = FIRDatabase.database().reference(withPath: "teams/\(team)/members")
        
        ref.observeSingleEvent(of: .value, with: { snapshot in
            for child in snapshot.children{
                if let childMember = child as? FIRDataSnapshot{
                    if let userId = childMember.value as? String{
                        self.teamMembersIds.append(userId)
                    }
                }
            }
            self.downloadUsersInfo()
        })
    }
    
    func downloadUsersInfo(){
        self.users.removeAll()
        for userId in teamMembersIds{
            let ref = FIRDatabase.database().reference(withPath: "users/\(userId)/fullName")
            ref.observeSingleEvent(of: .value, with: { snapshot in
                if let name = snapshot.value as? String{
                    self.users[userId] = name
                }
                self.initUsersArray()
            })
        }
    }
    
    func initUsersArray() {
        
        self.usersArray.removeAll()
        //self.users[userId] = task
        
        let usersArray = users.sorted{ $0.key > $1.key }
        
        for user in usersArray {
            self.usersArray.append(user.key, user.value)
        }
    }
    
}
