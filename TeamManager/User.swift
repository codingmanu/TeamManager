//
//  User.swift
//  TeamManager
//
//  Created by Manuel S. Gomez on 1/11/17.
//  Copyright © 2017 Manuel S. Gomez. All rights reserved.
//

import Foundation
import Firebase

class User{
    
    var userID:String! = ""
    var name: String! = ""
    var email: String! = ""
    var team: String?
    
    init(){
        userID = FIRAuth.auth()?.currentUser?.uid
        email = FIRAuth.auth()?.currentUser?.email
        
        //createTeam()
    }
    
    func getFullName(){
        let ref = FIRDatabase.database().reference(withPath: "users/\(userID!)/fullName")
        ref.observeSingleEvent(of: .value, with: { snapshot in
            if let name = snapshot.value as? String{
                self.name = name
            }
        })
    }
    
    func createTeam(){
        var ref: FIRDatabaseReference!
        ref = FIRDatabase.database().reference(withPath: "teams/-KaFut1RjfTvylH2-i7t/members")
        
        let teamId = ref.childByAutoId().key
        
        ref.child(teamId).setValue(userID!)
    }
    
}
