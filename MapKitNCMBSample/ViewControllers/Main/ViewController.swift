//
//  ViewController.swift
//  MapKitNCMBSample
//
//  Created by 清水智貴 on 2020/10/06.
//

import UIKit
import NCMB
import SVProgressHUD

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var posts = [Post]()
    var selectdIndex: Int!
    
    @IBOutlet var timelineTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timelineTableView.delegate = self
        timelineTableView.dataSource = self
        
        // 不要な線を消す
        timelineTableView.tableFooterView = UIView()
        
        let nib = UINib(nibName: "TimelineTableViewCell", bundle: Bundle.main)
        timelineTableView.register(nib, forCellReuseIdentifier: "Cell")
        
        // 引っ張って更新
        setRefreshControl()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadTimeline()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TimelineTableViewCell
        cell.delegate = self
        cell.tag = indexPath.row
        
        cell.selectionStyle = .none
        
        cell.latitudeLabel.text = "緯度：\(posts[indexPath.row].geoPoint.latitude)"
        cell.longitudeLabel.text = "経度：\(posts[indexPath.row].geoPoint.longitude)"
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPlacePoint" {
            let selectedPlacePointVC = segue.destination as! SelectedPlacePointViewController
            selectedPlacePointVC.selectedGeoPoint = posts[selectdIndex].geoPoint
        }
    }
    
    func loadTimeline() {
        
        guard let currentUser = NCMBUser.current() else {
            // ログインに戻る
            let storyboard = UIStoryboard(name: "SignIn", bundle: Bundle.main)
            let rootViewController = storyboard.instantiateViewController(withIdentifier: "RootNavigationController")
            UIApplication.shared.keyWindow?.rootViewController = rootViewController
            
            // ログインしていない状態の保持(AppDelegateの"isLogin"の宣言より)
            let ud = UserDefaults.standard
            ud.set(false, forKey: "isLogin")
            ud.synchronize()
            
            return
        }
        
        
        let query = NCMBQuery(className: "Place")
        
        // 降順(新しいものがタイムラインの上に出てくるように)
        query?.order(byDescending: "createDate")
        
        // オブジェクトの取得
        query?.findObjectsInBackground({ (result, error) in
            if error != nil {
                SVProgressHUD.showError(withStatus: error!.localizedDescription)
            } else {
                // 投稿を格納しておく配列を初期化(これをしないとreload時にappendで二重に追加されてしまう)
                self.posts = [Post]()
                
                for postObject in result as! [NCMBObject] {
                    
                    // 投稿の情報を取得
                    let geoPoint = postObject.object(forKey: "geoPoint") as! NCMBGeoPoint
                    
                    // 2つのデータ(投稿情報と誰が投稿したか?)を合わせてPostクラスにセット
                    let post = Post(objectId: postObject.objectId, createDate: postObject.createDate, geoPoint: geoPoint)
                    
                    // 配列に加える
                    self.posts.append(post)
                }
                
                // 投稿のデータが揃ったらTableViewをリロード
                self.timelineTableView.reloadData()
            }
        })
    }
    
}

// MARK:- TimelineTableViewCellDelegate に関する処理
extension ViewController: TimelineTableViewCellDelegate {
    
    func didTapPlacePointButton(tableViewCell: UITableViewCell) {
        selectdIndex = tableViewCell.tag
        self.performSegue(withIdentifier: "toPlacePoint", sender: nil)
    }
}

// MARK:- 引っ張って更新を行う処理
extension ViewController {
    
    // 引っ張って更新を行うためにセットするための関数（たいていの場合viewDidLoadに書く）
    func setRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(reloadTimeline(refreshControl:)), for: .valueChanged)
        timelineTableView.addSubview(refreshControl)
    }
    
    @objc func reloadTimeline(refreshControl: UIRefreshControl) {
        // ここが引っ張られるたびに呼び出される
        
        refreshControl.beginRefreshing()
        self.loadTimeline()
        // 更新が早すぎるので2秒遅延させる
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            // 通信終了後、endRefreshingを実行することでロードインジケーター（くるくる）が終了
            refreshControl.endRefreshing()
        }
    }
}
