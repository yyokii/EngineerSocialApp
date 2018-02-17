//
//  DataService.swift
//  UdemySocialApp
//
//  Created by 東原与生 on 2017/03/18.
//  Copyright © 2017年 yoki. All rights reserved.
//

import Foundation
import Firebase
import SwiftKeychainWrapper

let DB_BASE = FIRDatabase.database().reference()
let STORAGE_BASE = FIRStorage.storage().reference()

class DataService {
    
    static let ds = DataService()
    
    //DB referrence
    private var _REF_BASE = DB_BASE
    private var _REF_POSTS = DB_BASE.child(POSTS)
    private var _REF_USERS = DB_BASE.child(USERS)
    private var _REF_FOLLOW_FOLLOWER = DB_BASE.child(FOLLOW_FOLLOWER)
    //アイコンupload用
    private var _REF_USER_IMAGES = STORAGE_BASE.child(USER_ICON_PICS)
    
    var REF_BASE: FIRDatabaseReference {
        
        return _REF_BASE
    }
    
    var REF_POSTS: FIRDatabaseReference {
        
        return _REF_POSTS
    }
    
    var REF_USERS: FIRDatabaseReference {
        
        return _REF_USERS
    }
    
    var REF_FOLLOW_FOLLOWER: FIRDatabaseReference {
        
        return _REF_FOLLOW_FOLLOWER
    }
    
    var REF_USER_CURRENT: FIRDatabaseReference {
        
        let uid = KeychainWrapper.standard.string(forKey: KEY_UID)
        let user = REF_USERS.child(uid!)
        return user
    }
    
    var REF_USER_IMAGES: FIRStorageReference {
        
        return _REF_USER_IMAGES
    }
    
    func createFirebaseDBUser (uid: String, userData: Dictionary<String, Any>) {
        
        REF_USERS.child(uid).updateChildValues(userData)
    }
    
    func getPostUser(uid: String) -> FIRDatabaseReference{
        //投稿に紐づくユーザー情報取得
        return DB_BASE.child(USERS).child(uid)
    }
}
