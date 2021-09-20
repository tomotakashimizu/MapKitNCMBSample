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
    
    // 緯度経度のStringをkey,[Post]をvalueにした辞書型の配列を定義
    var posts = [String: [Post]]()
    var annotationList = [MKPointAnnotation]()
    var selectedCoordinate = CLLocationCoordinate2D()
    var locationManager: CLLocationManager!
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureMapView()
        setSearchBar()
        // locationManagerの設定
        setupLocationManager()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadPlacePoint()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetail" {
            let detailVC = segue.destination as! DetailViewController
            detailVC.selectedPosts = posts["\(self.selectedCoordinate)"]!
            print(self.selectedCoordinate)
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
                self.posts = [String: [Post]]()
                self.mapView.removeAnnotations(self.mapView.annotations)
                
                for postObject in result as! [NCMBObject] {
                    
                    // 投稿の情報を取得
                    let geoPoint = postObject.object(forKey: "geoPoint") as! NCMBGeoPoint
                    
                    let pointAnnotation = MKPointAnnotation()
                    let placePoint = CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude)
                    
                    pointAnnotation.coordinate = placePoint
                    pointAnnotation.title = "緯度経度"
                    pointAnnotation.subtitle = "緯度：\(placePoint.latitude), 経度：\(placePoint.longitude)"
                    self.mapView.addAnnotation(pointAnnotation)
                    
                    // 2つのデータ(投稿情報と誰が投稿したか?)を合わせてPostクラスにセット
                    let post = Post(objectId: postObject.objectId, createDate: postObject.createDate, geoPoint: geoPoint)
                    
                    if self.posts["\(placePoint)"] != nil {
                        // 配列に加える
                        self.posts["\(placePoint)"]!.append(post)
                    } else {
                        self.posts["\(placePoint)"] = [post]
                    }
                    
                    print(placePoint)
                }
                
            }
        })
    }
    
    @IBAction func toCurrentLocation() {
        // 現在地に移動
        mapView.setCenter(mapView.userLocation.coordinate, animated: true)
        print("latitude: \(mapView.userLocation.coordinate.latitude)")
        print("longitude: \(mapView.userLocation.coordinate.longitude)")
    }
}


// MARK:-  MapView に関する処理
extension AllPostedPlacePointViewController: MKMapViewDelegate {
    
    func configureMapView() {
        mapView.delegate = self
        
        // 現在位置表示の有効化
        mapView.showsUserLocation = true
        // 現在位置設定（デバイスの動きとしてこの時の一回だけ中心位置が現在位置で更新される）
        mapView.userTrackingMode = .followWithHeading
        
        let centerCoordinate = CLLocationCoordinate2D(latitude: 35.7020691, longitude: 139.7753269)
        let initialSpan = MKCoordinateSpan(latitudeDelta: 10.0, longitudeDelta: 10.0)
        let initialRegion = MKCoordinateRegion(center: centerCoordinate, span: initialSpan)
        self.mapView.setRegion(initialRegion, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // annotation がユーザの現在地の場合
        if (annotation is MKUserLocation) {
            // デフォルト
            return nil
        }
        let pinView = MKPinAnnotationView()
        pinView.animatesDrop = false
        pinView.isDraggable = false
        pinView.pinTintColor = .blue
        pinView.canShowCallout = true
        
        let button = UIButton()
        button.frame = CGRect(x: 0,y: 0,width: 120 ,height: 35)
        button.setTitle("この地点の投稿を見る", for: .normal)
        button.backgroundColor = UIColor.blue
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        
        pinView.rightCalloutAccessoryView = button
        
        return pinView
    }
    
    // 吹き出しをタップした時に呼ばれる関数
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        //投稿表示
        self.performSegue(withIdentifier: "toDetail", sender: nil)
    }
    
    // ピンをタップした時に呼ばれる関数
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        self.selectedCoordinate = view.annotation!.coordinate
        print(self.selectedCoordinate)
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


// MARK:- CLLocationManagerDelegate に関する処理
extension AllPostedPlacePointViewController: CLLocationManagerDelegate {
    
    // locationManagerの設定
    func setupLocationManager() {
        // locationManagerオブジェクトの初期化
        locationManager = CLLocationManager()
        
        // locationManagerオブジェクトが初期化に成功している場合のみ許可をリクエスト
        guard let locationManager = locationManager else { return }
        
        // ユーザに対して、位置情報を取得する許可をリクエスト
        locationManager.requestWhenInUseAuthorization()
        
        // ユーザから「アプリ使用中の位置情報取得」の許可が得られた場合のみ、マネージャの設定を行う
        let status = CLLocationManager.authorizationStatus()
        if status == .authorizedWhenInUse {
            
            // ViewControllerクラスが管理マネージャのデリゲート先になるように設定
            locationManager.delegate = self
            // メートル単位で設定
            locationManager.distanceFilter = 10
            // 位置情報の取得を開始
            locationManager.startUpdatingLocation()
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
