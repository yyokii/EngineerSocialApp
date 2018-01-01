//
//  PostTableView.swift
//  EngineerSocialApp
//
//  Created by Yoki on 2017/12/31.
//

import UIKit

// FIXME: Feedのテーブルもこのviewで置き換えたい
class PostTableView: UITableView ,UITableViewDelegate,UITableViewDataSource{
    
    // 投稿情報を渡して表示する
    var posts = [Post]()
    
    override init(frame: CGRect,style: UITableViewStyle){
        super.init(frame: frame, style: style)
        
        self.delegate = self
        self.dataSource = self

        self.register(UINib(nibName: "PostTableViewCell",bundle: nil), forCellReuseIdentifier: "PostTableViewCell")
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostTableViewCell", for: indexPath) as! PostTableViewCell
        let post = posts[indexPath.row]
        cell.configureCell(post: post)
        
        return cell
    }
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 300
//    }
    
}

