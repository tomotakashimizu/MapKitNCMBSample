//
//  DetailViewController.swift
//  MapKitNCMBSample
//
//  Created by 清水智貴 on 2020/10/18.
//

import UIKit

class DetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var selectedPost: Post!
    
    @IBOutlet var detailTimelineTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        detailTimelineTableView.delegate = self
        detailTimelineTableView.dataSource = self
        
        // 不要な線を消す
        detailTimelineTableView.tableFooterView = UIView()
        
        let nib = UINib(nibName: "TimelineTableViewCell", bundle: Bundle.main)
        detailTimelineTableView.register(nib, forCellReuseIdentifier: "Cell")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TimelineTableViewCell
        
        cell.selectionStyle = .none
        cell.toPlacePointButton.isHidden = true
        
        cell.latitudeLabel.text = "緯度：\(selectedPost.geoPoint.latitude)"
        cell.longitudeLabel.text = "経度：\(selectedPost.geoPoint.longitude)"
        
        return cell
    }
    
}
