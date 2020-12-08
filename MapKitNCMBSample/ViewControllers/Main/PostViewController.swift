//
//  PostViewController.swift
//  MapKitNCMBSample
//
//  Created by 清水智貴 on 2020/10/06.
//

import UIKit
import NCMB
import SVProgressHUD

class PostViewController: UIViewController {
    
    var placeLatitude: Double!
    var placeLongitude: Double!
    
    @IBOutlet var placeLatitudeLabel: UILabel!
    @IBOutlet var placeLongitudeLabel: UILabel!
    
    @IBOutlet var postButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        guard let placeLatitude = placeLatitude else { return }
        guard let placeLongitude = placeLongitude else { return }
        
        placeLatitudeLabel.text = "緯度：\(String(placeLatitude))"
        placeLongitudeLabel.text = "経度：\(String(placeLongitude))"
    }
    
    @IBAction func postPlace() {
        SVProgressHUD.show()
        
        let postObject = NCMBObject(className: "Place")
        
        let geoPoint = NCMBGeoPoint(latitude: self.placeLatitude, longitude: self.placeLongitude)
        postObject?.setObject(geoPoint, forKey: "geoPoint")
        postObject?.saveInBackground({ (error) in
            if error != nil {
                SVProgressHUD.showError(withStatus: error!.localizedDescription)
            } else {
                SVProgressHUD.dismiss()
                self.placeLatitude = nil
                self.placeLongitude = nil
                self.tabBarController?.selectedIndex = 0
            }
        })
    }
    
}
