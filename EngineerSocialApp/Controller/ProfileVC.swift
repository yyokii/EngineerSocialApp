//
//  ProfileVC.swift
//  EngineerSocialApp
//
//  Created by Yoki on 2017/12/30.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

//メモ：　コンテンツオフセット、ヘッダーの下部のy座標が0、トップが-200とか-300（ヘッダーの高さ）。

/// 自分のプロフィール表示、他のユーザーのプロフィール表示の2パターン使い方あり
/// （デフォルトは自分のプロフィールを表示、他のユーザーのものを表示する場合はタイプとuidを遷移前にセットしてね）
/// 自分のプロフィールでは：画像変更可能、投稿にアクションできない、、、、とかとか
/// ＜初回＞didLoad：tableviewセット　didLayout：tableのheaderをセット、ユーザーの情報を取得して表示
/// ＜初回以後＞willappear：投稿情報、過去投稿の最新データを取得
class ProfileVC: UIViewController{
    
    // コンテンツ切り替え用のラベル
    @IBOutlet weak var myDataLabel: ProfileSetContentLabel!
    @IBOutlet weak var myPostLabel: ProfileSetContentLabel!
    
    @IBOutlet weak var profileScrollView: UIScrollView!
    @IBOutlet weak var userImageView: CircleView!
    @IBOutlet weak var nameLabel: UILabel!
    
    enum ProfileType {
        case myProfile
        case others
    }
    /// 自分のプロフィールか他の人のかで変化する変数
    var profileType: ProfileType = ProfileType.myProfile
    /// タブからこの画面使用の場合はログインユーザーのuid、その他の場合は他のユーザーuidを格納
    var uid = ""
    var baseTableViewHeight: CGFloat?
    /// （他のひとのプロフィールの場合）フォロー状態かどうかを判断する（true: unfollowできる、false： followできる）
    var isFollowState = false

    // ベースになってるテーブルビュー関係
    var baseTableView: UITableView!
    var baseTableViewCell: BaseTableViewCell!
    var headerView: ProfilehHeaderView!
    
    // ここはProfileHeaderViewのviewの高さと同じにする必要あり
    let hederViewHeight = 300
    let headerViewHeightDouble: Double = 300.0
    
    // ヘッダービューの下部のどれくらいを固定させるか（ex: 2.5 → x/2.5 → 40%）
    let stickHeaderRation = 2.5
    
    // 獲得した総アクション数を保持
    var smiles: Int = 0
    var heats: Int = 0
    var cries: Int = 0
    var claps: Int = 0
    var oks: Int = 0
    
    // フォロー、フォロワーデータ
    var followUidArray = [String]()
    var followerUidArray = [String]()
    
    // 投稿データを円グラフで表示するために使用
    var postDataView: PostDataView!
    var devLanguagesArray = [DevelopData]()
    var devThingsArray = [DevelopData]()
    
    // 過去の投稿を表示するために使用
    var postTableView: PostTableView!
    //var myPosts = [Post]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = " Profile "
        // 自分の？それとも他の人の？を判断（ここでuidを設定する）
        applyProfileViewType()
        
        setBaseTableView()
        // ユーザー情報を表示するヘッダーviewを設定
        setHeaderView()
        // ヘッダーviewの設定（フォローボタンの状態）
        initSettingBtn()
        // コンテンツの表示
        getMyPostData()
        setActionsData()
        getMyPosts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if headerView != nil {
            // フォロー、フォロワーラベルの設定
            applyFollowLabel()
            //applyFollowerLabel()
            
            // FIXME: 違ってたら更新するみたいな感じがよくね　→ それやるならfirebaseのオブザーブ方法変えた方がいいかも
            FirebaseLogic.fetchUserName(uid: uid, completion: {[weak self] (name) in self?.headerView.userNameLabel.text = name})
            FirebaseLogic.fetchUserImage(uid: uid, completion: {[weak self] (img) in self?.headerView.userImageView.image = img})
            FirebaseLogic.fetchTwitterAccount(uid: uid) { [weak self] (twitterId) in
                self?.headerView.twitter = twitterId
            }
            FirebaseLogic.fetcGitAccount (uid: uid) { [weak self] (gitId) in
                self?.headerView.git = gitId
            }
        }
        
        if postDataView != nil {
            // 投稿データを取得してviewの更新
            getMyPostData()
            setActionsData()
        }
        
        if postTableView != nil {
            // 投稿データを取得してviewの更新
            getMyPosts()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /// FIXME: 自分のプロフィール画面か他の人の画面かでviewの位置や機能を分ける。フォロー非表示、設定表示　→ まとめてやりたかったけど個別でやってる
    func applyProfileViewType(){
        baseTableViewHeight = (self.navigationController?.navigationBar.frame.height)! + UIApplication.shared.statusBarFrame.height

        if profileType == ProfileType.myProfile {
            uid = KeychainWrapper.standard.string(forKey: KEY_UID)!
        }
    }
    
    /// 自分のプロフィールの際は設定ボタンを表示する
    func initSettingBtn(){
        if profileType == ProfileType.myProfile {
            // 設定ボタンをフォローボタンを代わりに表示
        } else if profileType == ProfileType.others {
            // フォロー状態を取得してヘッダーのボタンに反映
            FirebaseLogic.fetchFollowState(uid: uid, completion: { [weak self] (isFollowState) in
                if isFollowState {
                    // フォロー済みの場合
                    self?.isFollowState = true
                    self?.headerView.applyUnFollowBtn()
                } else {
                    // 未フォローの場合
                    self?.headerView.applyFollowBtn()
                }
            })
        }
    }
    
    func applyFollowLabel(){
        FirebaseLogic.fetchFollowUser(uid: uid) {[weak  self] (followUidArray) in
            self?.followUidArray = followUidArray
            self?.headerView.initFollowLabel(followCount: followUidArray.count)
        }
    }
    
//    func applyFollowerLabel(){
//        FirebaseLogic.fetchFollowerUser(uid: uid) {[weak  self] (followerUidArray) in
//            self?.followerUidArray = followerUidArray
//            self?.headerView.initFollowerLabel(followerCount: followerUidArray.count)
//        }
//    }
    
    func setActionsData(){
        FirebaseLogic.getGetActionsData(uid: uid) { [weak self] (dict) in
            self?.postDataView.setGetActionsCountLabel(smileCount: String(describing: dict[SMILES]!), heartCount: String(describing: dict[HEARTS]!), cryCount: String(describing: dict[CRIES]!), clapCount: String(describing: dict[CLAPS]!), okCount: String(describing: dict[OKS]!))
        }
    }
    
    /// 開発言語と開発項目のデータを取得して配列に保存
    func getMyPostData() {
        
        // 開発言語のデータ取得
        FirebaseLogic.fetchDevLangData(uid: uid) { [weak self] (devLanguages) in
            self?.devLanguagesArray = []
            if let devLangs = devLanguages{
                for devLanguage in devLangs{
                    let devLanguageData = DevelopData(devLanguage: devLanguage.key, count: devLanguage.value as! Int)
                    self?.devLanguagesArray.insert(devLanguageData, at: 0)
                }
            }
            self?.postDataView.setupDevLangsPieChartView(developDataArray: (self?.devLanguagesArray)!)
            self?.postDataView.animationDevLangsChart()
        }
        
        // 開発項目のデータ取得
        FirebaseLogic.fetchDevelopData(uid: uid) { [weak self] (develops) in
            self?.devThingsArray = []
            if let devs = develops{
                for dev in devs{
                    let devData = DevelopData(toDo: dev.key, count: dev.value as! Int)
                    self?.devThingsArray.insert(devData, at: 0)
                }
            }
            self?.postDataView.setupDevThingsPieChartView(developDataArray: (self?.devThingsArray)!)
            self?.postDataView.animationDevThingsChart()
        }
    }
    
    /// 過去の「自分の」投稿を取得
    func getMyPosts() {
        FirebaseLogic.fetchMyPostsData(uid: uid) { [weak self] (posts) in
            self?.postTableView.posts = posts
            if let _ = self?.postTableView {
                // 多分ないが（描画よりデータ取得の方が時間かかるのでデータ取れたころにはviewはあるはず）、nilをケア
                self?.postTableView.reloadData()
            }
        }
        
    }
    
    func setBaseTableView() {
        let displayWidth = self.view.frame.width
        let displayHeight = self.view.frame.height
        
        // テーブル
        baseTableView = UITableView(frame: CGRect(x: 0, y: baseTableViewHeight!, width: displayWidth, height: displayHeight))
        baseTableView.register(UINib(nibName: "BaseTableViewCell",bundle: nil), forCellReuseIdentifier: "BaseTableViewCell")
        baseTableView.dataSource = self
        baseTableView.delegate = self
        // コンテンツをヘッダーの高さ分だけ下げる
        baseTableView.contentInset.top = CGFloat(hederViewHeight)
        baseTableView.rowHeight = self.view.frame.height
        baseTableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        self.view.addSubview(baseTableView)
    }
    
    func setHeaderView() {
        // オリジナルヘッダービューを作成
        headerView = ProfilehHeaderView(frame: CGRect(x: 0, y: -CGFloat(hederViewHeight), width: self.view.frame.width, height: CGFloat(hederViewHeight)))
        headerView.backgroundColor = UIColor.green
        headerView.profilehHeaderViewDelegate = self
        baseTableView.addSubview(headerView)
        
        // 自分のプロフィール画面ではフォローボタン非表示
        if profileType == ProfileType.myProfile{
            headerView.followBtn.isHidden = true
        }else if profileType == ProfileType.others {
            headerView.followBtn.isHidden = false
            // フォロー状態を取得してヘッダーのボタンに反映
            FirebaseLogic.fetchFollowState(uid: uid, completion: { [weak self] (isFollowState) in
                if isFollowState {
                    // フォロー済みの場合
                    self?.isFollowState = true
                    self?.headerView.applyUnFollowBtn()
                } else {
                    // 未フォローの場合
                    self?.headerView.applyFollowBtn()
                }
            })
        }
        
        // ユーザー情報を設定
        FirebaseLogic.fetchUserImage(uid: uid) {[weak self] (img) in self?.headerView.userImageView.image = img}
        FirebaseLogic.fetchUserName(uid: uid) {[weak self] (name) in self?.headerView.userNameLabel.text = name}
        FirebaseLogic.fetchUserProfile(uid: uid) { [weak self] (profile) in self?.headerView.userDescription.text = profile}
        
        // twitter、git ボタンの設定をする
        FirebaseLogic.fetchTwitterAccount(uid: uid) { [weak self] (twitterId) in
            self?.headerView.twitter = twitterId
        }
        FirebaseLogic.fetcGitAccount (uid: uid) { [weak self] (gitId) in
            self?.headerView.git = gitId
        }
    }
}

extension ProfileVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        baseTableViewCell = tableView.dequeueReusableCell(withIdentifier: "BaseTableViewCell", for: indexPath) as! BaseTableViewCell
        baseTableViewCell.baseTableViewCellDelegate = self
        baseTableViewCell.setScrollView(contentWidth: self.view.frame.width*2)
        let contentHeight = self.view.frame.height - baseTableViewHeight! - CGFloat(headerViewHeightDouble/stickHeaderRation)
        
        // ①投稿データviewの生成
        postDataView = PostDataView(frame:  CGRect(x: 0, y: 0, width: self.view.frame.width, height: contentHeight))
        postDataView.scrollView.isScrollEnabled = false
        postDataView.delegate = self

        // ②過去の投稿を表示するviewの生成
        let frame = CGRect(x: self.view.frame.width, y: 0, width: self.view.frame.width, height: contentHeight)
        self.postTableView = PostTableView(frame: frame,style: UITableViewStyle.plain)
        // セルの高さを可変にする
        postTableView.estimatedRowHeight = 200
        postTableView.rowHeight = UITableViewAutomaticDimension
        postTableView.isScrollEnabled = false
        postTableView.postTableViewDelegate = self
        
        baseTableViewCell.scrollView.addSubview(postDataView)
        baseTableViewCell.scrollView.addSubview(postTableView)
        return baseTableViewCell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // 下に引っ張ったときは、ヘッダー位置を計算して動かないようにする
        if scrollView.contentOffset.y < -CGFloat(hederViewHeight) {
            self.headerView.frame = CGRect(x: 0, y: scrollView.contentOffset.y, width: self.view.frame.width, height: CGFloat(hederViewHeight))
        }
        
        guard let _ = postDataView else {
            return
        }
        
        if scrollView.contentOffset.y > -CGFloat(headerViewHeightDouble/stickHeaderRation){
            // cell内のコンテンツだけを動かせる
            baseTableView.contentOffset = CGPoint(x: 0, y: -CGFloat(headerViewHeightDouble/stickHeaderRation))
            baseTableView.isScrollEnabled = false
            // 下部のコンテンツのスクロールを有効にする
            postDataView.scrollView.isScrollEnabled = true
            postTableView.isScrollEnabled = true
        }else {
            baseTableView.isScrollEnabled = true
            postDataView.scrollView.isScrollEnabled = false
            postTableView.isScrollEnabled = false
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == TO_FOLLOW_FOLLOWER {
            // ユーザーリストに表示するuidの配列を遷移時に渡す
            let  userListVC = segue.destination as! UserListVC
            userListVC.followUidArray = followUidArray
            userListVC.followerUidArray = followerUidArray
        }
    }
    
}

extension ProfileVC: PostDataViewDelegate{
    func didScrollToBottom(y: CGFloat) {
    }
    
    func didScrollToTop(y: CGFloat) {
        if baseTableView.contentOffset.y <= 0 {
            baseTableView.isScrollEnabled = true
            postDataView.scrollView.isScrollEnabled = false
            // -100（固定させるヘッダーの高さ）の設定をすることで挙動のカクツキが改善。ないとスクロールが2タップぐらい反応しない
            baseTableView.contentOffset = CGPoint(x: 0, y: -CGFloat(headerViewHeightDouble/stickHeaderRation))
            // ヘッダー全体を表示時はコンテンツのスクロールをリセットする（他のコンテンツも）。そうしないとコンテンツが見切れる場合が生じる。
            postTableView.contentOffset = CGPoint(x: 0, y: 0)
        }
    }
}

extension ProfileVC: PostTableViewDelegate{
    func didSelectCell(postUserId: String) {
        // なにもしない
    }
    
    // Fixme:使わないっぽいので消そうぜ
    func didTableScrollToBottom(y: CGFloat) {
    }
    
    func didTableScrollToTop(y: CGFloat) {
        if baseTableView.contentOffset.y <= 0 {
            baseTableView.isScrollEnabled = true
            postTableView.isScrollEnabled = false
            // -100（固定させるヘッダーの高さ）の設定をすることで挙動のカクツキが改善。ないとスクロールが2タップぐらい反応しない
            baseTableView.contentOffset = CGPoint(x: 0, y: -CGFloat(headerViewHeightDouble/stickHeaderRation))
            // ヘッダー全体を表示時はコンテンツのスクロールをリセットする（他のコンテンツも）。そうしないとコンテンツが見切れる場合が生じる。
            postDataView.scrollView.contentOffset = CGPoint(x: 0, y: 0)
        }
    }
}

extension ProfileVC: ProfilehHeaderViewDelegate{
    func settingButtonTapped() {
        
        if profileType == ProfileType.myProfile{
            // 自分のプロフィール画面の場合は設定画面に遷移
            let settingStoryBoard = UIStoryboard(name: "Setting", bundle: nil)
            let settingVC = settingStoryBoard.instantiateInitialViewController() as! SettingVC
            
            var currentUser = User()
            currentUser.profileImage = headerView.userImageView.image
            currentUser.name = headerView.userNameLabel.text
            currentUser.profile = headerView.userDescription.text
            currentUser.twitter = headerView.twitter
            currentUser.git = headerView.git
            settingVC.currentUser = currentUser
            
            self.present(settingVC, animated: true, completion: nil)
        }else if profileType == ProfileType.others {
            // 他の人のプロフィール画面の場合は通報用のアクションシートを表示する
            Alert.presentReportActionSheet(vc: self, uid: uid) { [weak self] in
                Util.presentMailView(vc: self!, subject: "お問い合わせ（不適切なユーザー）", message: "不適切な投稿をした次のユーザーを通報します。\n " + "ID: " + self!.uid + "\nこのまま（もしくは開発者へのエールを添えて）ご送信ください:)。運営にて投稿内容を確認し、24時間以内に対応いたします。")
            }
        }
    }
    
    func followLabelTapped() {
        performSegue(withIdentifier: TO_FOLLOW_FOLLOWER, sender: nil)
    }
    
    func followerLabelTapped() {
        performSegue(withIdentifier: TO_FOLLOW_FOLLOWER, sender: nil)
    }
    
    func followButtonTapped() {
        if (isFollowState){
            // 「フォローをはずす」場合
            FirebaseLogic.unfollowAction(vc: self, uid: uid, completion: { [weak self] in
                self?.isFollowState  = false
                self?.headerView.applyFollowBtn()
            })
        } else {
            // 「フォローする」場合
            FirebaseLogic.followAction(vc: self, uid: uid, completion: { [weak self] in
                self?.isFollowState  = true
                self?.headerView.applyUnFollowBtn()
            })
        }
    }
    
    func dataLblTapped() {
        baseTableViewCell.adjustContent(pointX: 0)
    }
    
    func postLblTapped() {
        baseTableViewCell.adjustContent(pointX: Int(self.baseTableView.frame.width))
    }
}

extension ProfileVC: BaseTableViewCellDelegate{
    func scrollViewDidEndScroll(x: CGFloat) {
        if x == 0 {
            headerView.dataContentSelected()
        }else {
            headerView.postContentSelected()
        }
    }
}
