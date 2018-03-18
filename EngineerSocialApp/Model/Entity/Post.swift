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
    
    private var _date: String!
    private var _caption: String!
    
    private var _likes: Int!
    // ユーザーのアクション
    private var _smiles: Int!
    private var _hearts: Int!
    private var _cries: Int!
    private var _claps: Int!
    private var _oks: Int!
    
    // 開発項目と開発言語
    private var _develop: String!
    private var _programmingLang: String!
    
    private var _postUserId: String!
    private var _postKey: String!
    private var _postRef: FIRDatabaseReference!
    
    var date: String {
        return _date
    }
    
    var caption: String {
        return _caption
    }
    
    var programmingLang: String {
        return _programmingLang
    }
    
    var develop: String {
        return _develop
    }
    
    var likes: Int {
        return _likes
    }
    
    var smiles: Int {
        return _smiles
    }
    
    var hearts: Int {
        return _hearts
    }
    
    var cries: Int {
        return _cries
    }
    
    var claps: Int {
        return _claps
    }
    
    var oks: Int {
        return _oks
    }
    
    var postUserId: String {
        return _postUserId
    }
    
    var postKey: String {
        return _postKey
    }
    
    init(postKey: String, postData: Dictionary<String, AnyObject>) {
        
        self._postKey = postKey
        
        if let date = postData[DATE] as? String {
            self._date = date
        } else{
            self._date = "hello! bug!"
        }
        
        if let caption = postData[CAPTION] as? String {
            self._caption = caption
        }
        
        if let develop = postData[DEVELOP] as? String {
            self._develop = develop
        }
        
        if let programmingLang = postData[PROGRAMMING_LANGUAGE] as? String {
            self._programmingLang = programmingLang
        }
        
        if let likes = postData[LIKES] as? Int{
            self._likes = likes
        }
        
        // 投稿が取得しているアクション情報を取得
        let actionDictionary = postData[ACTION] as! Dictionary<String, AnyObject>
        if let smiles = actionDictionary[SMILES] as? Int{
            self._smiles = smiles
        }
        if let hearts = actionDictionary[HEARTS] as? Int{
            self._hearts = hearts
        }
        if let cries = actionDictionary[CRIES] as? Int{
            self._cries = cries
        }
        if let claps = actionDictionary[CLAPS] as? Int{
            self._claps = claps
        }
        if let oks = actionDictionary[OKS] as? Int{
            self._oks = oks
        }
        
        
        if let postUserId = postData[KEY_UID] as? String {
            self._postUserId = postUserId
        }
        
        _postRef = DataService.ds.REF_POSTS.child(_postKey)
    }
    
    // ユーザーのアクション数をdbに反映させる。postツリーの中の個々の投稿の中でアクション数を保持する。
    func ajustSmile (addSmile: Bool, completion: @escaping () -> Void) {
        if addSmile {
            _smiles = _smiles + 1
        } else {
            _smiles = _smiles - 1
        }
        _postRef.child(ACTION).child(SMILES).setValue(smiles) { (error, ref) in
            if error == nil {
                completion()
            }else {
                print("エラー: adjustSmile")
            }
        }
    }
    
    func ajustHeart (addHeart: Bool, completion: @escaping () -> Void) {
        if addHeart {
            _hearts = _hearts + 1
        } else {
            _hearts = _hearts - 1
        }
        _postRef.child(ACTION).child(HEARTS).setValue(_hearts) { (error, ref) in
            if error == nil {
                completion()
            }else {
                print("エラー: adjustHeart")
            }
        }
    }
    
    func ajustCry (addCry: Bool, completion: @escaping () -> Void) {
        if addCry {
            _cries = _cries + 1
        } else {
            _cries = _cries - 1
        }
        _postRef.child(ACTION).child(CRIES).setValue(_cries) { (error, ref) in
            if error == nil {
                completion()
            }else {
                print("エラー: adjustCry")
            }
        }
    }
    
    func ajustClap (addClap: Bool, completion: @escaping () -> Void) {
        if addClap {
            _claps = _claps + 1
        } else {
            _claps = _claps - 1
        }
        _postRef.child(ACTION).child(CLAPS).setValue(_claps) { (error, ref) in
            if error == nil {
                completion()
            }else {
                print("エラー: adjustClap")
            }
        }
    }
    
    func ajustOk (addOk: Bool, completion: @escaping () -> Void) {
        if addOk {
            _oks = _oks + 1
        } else {
            _oks = _oks - 1
        }
        _postRef.child(ACTION).child(OKS).setValue(_oks) { (error, ref) in
            if error == nil {
                completion()
            }else {
                print("エラー: adjustOk")
            }
        }
    }
}
