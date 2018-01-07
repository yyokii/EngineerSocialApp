//
//  DevelopData.swift
//  EngineerSocialApp
//
//  Created by Yoki Higashihara on 2018/01/07.
//

import Foundation

/// 開発言語とやること（やったこと）のデータモデルを扱うクラス
class DevelopData {

    // 開発言語
    private var _devLanguage: String!
    private var _languageCount: Int!
    
    // 開発内容、やること
    private var _toDo: String!
    private var _doCount: Int!
    
    
    var devLanguage: String {
        return _devLanguage
    }
    
    var languageCount: Int {
        return _languageCount
    }
    
    var toDo: String {
        return _toDo
    }
    
    var doCount: Int {
        return _doCount
    }
    
    // 開発言語データの初期化
    init(devLanguage: String, count: Int) {
        
        self._devLanguage = devLanguage
        self._languageCount = count
    }
    
    // やることデータの初期化
    init(toDo: String, count: Int) {
        
        self._toDo = toDo
        self._doCount = count
    }
}
