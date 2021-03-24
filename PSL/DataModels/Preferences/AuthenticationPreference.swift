//
//  AuthenticationPreference.swift
//  AllomateAttendance
//
//  Created by MacBook on 23/12/2020.
//

import UIKit

class AuthenticationPreference: NSObject {
    static let SessionToken =  "session"
    static let empid =  "id"
    
    
    
    static func saveAuth(model:Auth){
        let userDefault = UserDefaults.standard
        userDefault.set(model.id, forKey: empid)
        userDefault.set(model.session, forKey: SessionToken)

        userDefault.synchronize()
        
    }
    
    
    static func removeAuth(){
        let userDefault = UserDefaults.standard
        userDefault.set(0, forKey: empid)
        userDefault.set("", forKey: SessionToken)
        userDefault.synchronize()
    }
    
    
    
    static func getSession ()->String{
        
        let str:String =  UserDefaults.standard.string(forKey: SessionToken) ?? ""
        return str
    }
    static func getClientId ()->Int{
        
       let str:Int =  UserDefaults.standard.integer(forKey: empid)
        return str
    }
    
}
