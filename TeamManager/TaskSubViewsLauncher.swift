//
//  TaskSubViewsLauncher.swift
//  TeamManager
//
//  Created by Manuel S. Gomez on 1/2/17.
//  Copyright © 2017 Manuel S. Gomez. All rights reserved.
//

import UIKit

class TaskSubViewsLauncher: NSObject {
    
    let blackView = UIView()
    let dateView = DatePicker()
    let userView = UserPicker()
    var date: Date? = nil
    
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

class UserPicker: UIView{
    
}
