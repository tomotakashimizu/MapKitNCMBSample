//
//  AllPostedPlaceViewController.swift
//  MapKitNCMBSample
//
//  Created by 清水智貴 on 2020/10/06.
//

import UIKit
import NCMB
import MapKit
import SVProgressHUD

class AllPostedPlacePointViewController: UIViewController {
    
    var posts = [Post]()
    var annotationList = [MKPointAnnotation]()
    var selectedGeoPoint = NCMBGeoPoint()
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureMapView()
        setSearchBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadPlacePoint()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetail" {
            let detailVC = segue.destination as! DetailViewController
            detailVC.selectedPost = posts[0]
        }
    }
    
    func loadPlacePoint() {
        
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
                self.mapView.removeAnnotations(self.mapView.annotations)
                
                for postObject in result as! [NCMBObject] {
                    
                    // 投稿の情報を取得
                    let geoPoint = postObject.object(forKey: "geoPoint") as! NCMBGeoPoint
                    
                    let pointAnnotation = MKPointAnnotation()
                    let placePoint = CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude)
                    
                    pointAnnotation.coordinate = placePoint
                    pointAnnotation.title = "緯度：\(geoPoint.latitude)"
                    self.mapView.addAnnotation(pointAnnotation)
                    self.mapView.region = MKCoordinateRegion(center: placePoint, latitudinalMeters: 3000.0, longitudinalMeters: 3000.0)
                    
                    // 2つのデータ(投稿情報と誰が投稿したか?)を合わせてPostクラスにセット
                    let post = Post(objectId: postObject.objectId, createDate: postObject.createDate, geoPoint: geoPoint)
                    
                    // 配列に加える
                    self.posts.append(post)
                }
                
            }
        })
    }
    
    func loadSelectedPlacePoint(selectedGeoPoint: NCMBGeoPoint?) {
        
        let query = NCMBQuery(className: "Place")
        
        // 降順(新しいものがタイムラインの上に出てくるように)
        query?.order(byDescending: "createDate")
        
        if let geoPoint = selectedGeoPoint {
            query?.whereKey("geoPoint", equalTo: geoPoint)
        }
        
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
                
            }
        })
    }
}


// MARK:-  MapView に関する処理
extension AllPostedPlacePointViewController: MKMapViewDelegate {
    
    func configureMapView() {
        mapView.delegate = self
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let pinView = MKPinAnnotationView()
        pinView.animatesDrop = false
        pinView.isDraggable = false
        pinView.pinTintColor = .blue
        pinView.canShowCallout = true
        
        let button = UIButton()
        button.frame = CGRect(x: 0,y: 0,width: 70 ,height: 35)
        button.setTitle("投稿を見る", for: .normal)
        button.backgroundColor = UIColor.blue
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        pinView.rightCalloutAccessoryView = button
        
        //mapView.addAnnotations(annotationList)
        
        return pinView
    }
    
    // 吹き出しをタップした時に呼ばれる関数
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        //投稿表示
        self.performSegue(withIdentifier: "toDetail", sender: nil)
    }
    
    // ピンをタップした時に呼ばれる関数
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let coordinate = view.annotation?.coordinate
        selectedGeoPoint = NCMBGeoPoint(latitude: coordinate!.latitude, longitude: coordinate!.longitude)
        loadSelectedPlacePoint(selectedGeoPoint: selectedGeoPoint)
    }
    
    @IBAction func changeMaptype(_ sender: Any) {
        switch (sender as AnyObject).selectedSegmentIndex {
        case 0:
            mapView.mapType = .standard
        case 1:
            mapView.mapType = .satellite
        case 2:
            mapView.mapType = .hybrid
        default:
            mapView.mapType = .standard
        }
    }
}


// MARK:- SearchBar に関する処理
extension AllPostedPlacePointViewController: UISearchBarDelegate {
    
    func setSearchBar() {
        searchBar.delegate = self
        searchBar.placeholder = "都市名で検索"
        searchBar.autocapitalizationType = UITextAutocapitalizationType.none
    }
    
    // searcBarをクリック時
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(true, animated: true)
        return true
    }
    
    // キャンセルボタンを押した時の処理
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchPlaces(searchText: nil)
        searchBar.text = ""
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
    }
    
    // searchBarで検索時(Enter押した時)呼ばれる関数
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchPlaces(searchText: searchBar.text)
    }
    
    func searchPlaces(searchText: String?) {
        
        guard let searchKey = searchText else { return }
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(searchKey, completionHandler: { (placemarks, error) in
            
            guard let unwrapPlacemarks = placemarks else { return }
            guard let firstPlacemark = unwrapPlacemarks.first else { return }
            guard let location = firstPlacemark.location else { return }
            
            let targetCoordinate = location.coordinate
            print(targetCoordinate)
            self.mapView.region = MKCoordinateRegion(center: targetCoordinate, latitudinalMeters: 500.0, longitudinalMeters: 500.0)
        })
    }
}
