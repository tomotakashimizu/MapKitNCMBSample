//
//  PostPlaceViewController.swift
//  MapKitNCMBSample
//
//  Created by 清水智貴 on 2020/10/06.
//

import UIKit
import MapKit
import CoreLocation

class PostPlacePointViewController: UIViewController {
    
    var locationManager: CLLocationManager!
    var currentLatitude :Double!
    var currentLongitude :Double!
    var latitude: Double!
    var longitude: Double!
    var adressString = ""
    var annotationList = [MKPointAnnotation]()
    
    @IBOutlet var postMapView: MKMapView!
    @IBOutlet var longPressGestureRecognizer: UILongPressGestureRecognizer!
    @IBOutlet var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // locationManagerの設定
        setupLocationManager()
        
        // 地図の初期化
        initMap()
        setupScaleBar()
        setupCompass()
        
        setSearchBar()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPost" {
            let postVC = segue.destination as! PostViewController
            postVC.placeLatitude = latitude
            postVC.placeLongitude = longitude
            //postVC.adressString = adressString
        }
    }
    
    @IBAction func toPost() {
        if adressString == "" || latitude == nil || longitude == nil {
            SimpleAlert.showAlert(viewController: self, title: "確認", message: "まだ位置情報が定められていません。", buttonTitle: "OK")
        } else {
            self.performSegue(withIdentifier: "toPost", sender: nil)
        }
    }
    
}


// MARK:- CLLocationManagerDelegate に関する処理
extension PostPlacePointViewController: CLLocationManagerDelegate {
    
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
    
    // 現在の位置情報を取得・更新するたびに呼ばれるデリゲートメソッド
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // 現在位置の取得
        let location = locations.first
        // 緯度の取得
        currentLatitude = location?.coordinate.latitude
        // 経度の取得
        currentLongitude = location?.coordinate.longitude
        
        print("latitude: \(currentLatitude!)\nlongitude: \(currentLongitude!)")
        
        // 現在位置が更新される度に地図の中心位置を変更する（アニメーション）
        postMapView.userTrackingMode = .follow
    }
    
    // 緯度・経度から住所(String型)へ変換
    func convert(lat: CLLocationDegrees, long: CLLocationDegrees) {
        let geocorder = CLGeocoder()
        let location = CLLocation(latitude: lat, longitude: long)
        geocorder.reverseGeocodeLocation(location) { (placeMark, error) in
            if let placeMark = placeMark {
                if let pm = placeMark.first {
                    if pm.administrativeArea != nil && pm.locality != nil {
                        self.adressString = pm.administrativeArea! + pm.locality!
                    }else{
                        self.adressString = pm.name!
                    }
                }
            }
        }
    }
}


// MARK:- UIGestureRecognizerDelegate に関する処理
extension PostPlacePointViewController: UIGestureRecognizerDelegate {
    
    // UILongPressGestureRecognizerのdelegate：ロングタップを検出する
    @IBAction func mapViewDidLongPress(_ sender: UILongPressGestureRecognizer) {
        // ロングタップ開始
        if sender.state == .began {
        }
        // ロングタップ終了（手を離した）
        else if sender.state == .ended {
            
            // annotationの初期化
            postMapView.removeAnnotations(annotationList)
            
            // タップした位置（CGPoint）を指定してMkMapView上の緯度経度を取得する
            let tapPoint = sender.location(in: view)
            let pressCordinate = postMapView.convert(tapPoint, toCoordinateFrom: postMapView)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = pressCordinate
            annotation.title = "場所"
            annotationList.append(annotation)
            postMapView.addAnnotation(annotation)
            
            print(pressCordinate.latitude, type(of: pressCordinate.latitude))
            
            convert(lat: pressCordinate.latitude, long: pressCordinate.longitude)
            
            latitude = pressCordinate.latitude
            longitude = pressCordinate.longitude
        }
    }
}


// MARK:- SearchBar に関する処理
extension PostPlacePointViewController: UISearchBarDelegate {
    
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
            
            // annotationの初期化
            self.postMapView.removeAnnotations(self.annotationList)
            
            let targetCoordinate = location.coordinate
            print(targetCoordinate)
            self.latitude = targetCoordinate.latitude
            self.longitude = targetCoordinate.longitude
            
            let pin = MKPointAnnotation()
            pin.coordinate = targetCoordinate
            pin.title = searchKey
            self.postMapView.addAnnotation(pin)
            self.annotationList.append(pin)
            self.postMapView.region = MKCoordinateRegion(center: targetCoordinate, latitudinalMeters: 500.0, longitudinalMeters: 500.0)
            
            print(searchKey)
            self.adressString = searchKey
        })
    }
}


// MARK:- MapView に関する処理
extension PostPlacePointViewController: MKMapViewDelegate {
    
    // 地図の初期化
    func initMap() {
        // 縮尺を設定
        var region: MKCoordinateRegion = postMapView.region
        region.span.latitudeDelta = 0.02
        region.span.longitudeDelta = 0.02
        postMapView.setRegion(region,animated:true)
        
        // 現在位置表示の有効化
        postMapView.showsUserLocation = true
        // 現在位置設定（デバイスの動きとしてこの時の一回だけ中心位置が現在位置で更新される）
        postMapView.userTrackingMode = .follow
    }
    
    func setupScaleBar() {
        // スケールバーの表示
        let scale = MKScaleView(mapView: postMapView)
        scale.frame.origin.x = 15
        scale.frame.origin.y = 45
        scale.legendAlignment = .leading
        self.view.addSubview(scale)
    }
    
    func setupCompass() {
        // コンパスの表示
        let compass = MKCompassButton(mapView: postMapView)
        compass.compassVisibility = .adaptive
        compass.frame = CGRect(x: 10, y: 150, width: 40, height: 40)
        self.view.addSubview(compass)
        // デフォルトのコンパスを非表示にする
        postMapView.showsCompass = false
    }
    
    // 地図の種類を変更
    @IBAction func changeMaptype(_ sender: Any) {
        switch (sender as AnyObject).selectedSegmentIndex {
        case 0:
            postMapView.mapType = .standard
        case 1:
            postMapView.mapType = .satellite
        case 2:
            postMapView.mapType = .hybrid
        default:
            postMapView.mapType = .standard
        }
    }
}
