//
//  Post.swift
//  UdemySocialApp
//
//  Created by 東原与生 on 2017/03/18.
//  Copyright © 2017年 yoki. All rights reserved.
//

import Foundation
import Firebase

class Post {
    
    private var _caption: String!
    private var _imageUrl: String!
    private var _likes: Int!
    private var _postUserId: String!
    private var _postKey: String!
    private var _postRef: FIRDatabaseReference!
    
    var caption: String {
        return _caption
    }
    
    var imageUrl: String {
        return _imageUrl
    }
    
    var likes: Int {
        return _likes
    }
    
    var postUserId: String {
        return _postUserId
    }
    
    var postKey: String {
        return _postKey
    }
    
    init(caption: String, imageUrl: String, liles: Int) {
        
        self._caption = caption
        self._imageUrl = imageUrl
        self._likes = likes
    }
    
    init(postKey: String, postData: Dictionary<String, AnyObject>) {
        
        self._postKey = postKey
        
        if let caption = postData["caption"] as? String {
            self._caption = caption
        }
        
        if let imageUrl = postData["imageUrl"] as? String {
            self._imageUrl = imageUrl
        }
        
        if let likes = postData["likes"] as? Int{
            self._likes = likes
        }
        
        if let postUserId = postData["uid"] as? String {
            self._postUserId = postUserId
        }
        
        _postRef = DataService.ds.REF_POSTS.child(_postKey)
        
    }
    
    func ajustLike (addLike: Bool) {
        if addLike {
            _likes = _likes + 1   //////////////////
        } else {
            _likes = likes - 1    //////////////////
        }
        
        _postRef.child("likes").setValue(_likes)
        
    }

}
