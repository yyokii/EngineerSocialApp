//
//  PostTableView.swift
//  EngineerSocialApp
//
//  Created by Yoki on 2017/12/31.
//

import UIKit

protocol PostTableViewDelegate: class {
    func didScrollToBottom(y: CGFloat) -> Void
    func didScrollToTop(y: CGFloat) -> Void
}

class PostTableView: UITableView {
    
    // 投稿情報を渡して表示する
    var posts = [Post]()
    
    weak var postTableViewDelegate: PostTableViewDelegate?

    override init(frame: CGRect,style: UITableViewStyle){
        super.init(frame: frame, style: style)
        
        self.delegate = self
        self.dataSource = self

        self.register(UINib(nibName: "PostTableViewCell",bundle: nil), forCellReuseIdentifier: "PostTableViewCell")
        self.separatorColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PostTableView: UITableViewDataSource {
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
        cell.selectionStyle = .none
        
        return cell
    }
}

extension PostTableView: UITableViewDelegate {
    
}


