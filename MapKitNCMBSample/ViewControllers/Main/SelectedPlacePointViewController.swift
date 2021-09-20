//
//  PlacePointViewController.swift
//  MapKitNCMBSample
//
//  Created by 清水智貴 on 2020/10/17.
//

import UIKit
import NCMB
import MapKit

class SelectedPlacePointViewController: UIViewController {
    
    var selectedGeoPoint = NCMBGeoPoint()
    var locationManager: CLLocationManager!
    @IBOutlet var selectedMapView: MKMapView!
    @IBOutlet var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureMapView()
        setSearchBar()
        // locationManagerの設定
        setupLocationManager()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        let pointAnnotation = MKPointAnnotation()
        let placePoint = CLLocationCoordinate2DMake(selectedGeoPoint.latitude, selectedGeoPoint.longitude)
        
        pointAnnotation.coordinate = placePoint
        self.selectedMapView.addAnnotation(pointAnnotation)
        self.selectedMapView.region = MKCoordinateRegion(center: placePoint, latitudinalMeters: 3000.0, longitudinalMeters: 3000.0)
    }
    
    @IBAction func toCurrentLocation() {
        // 現在地に移動
        selectedMapView.setCenter(selectedMapView.userLocation.coordinate, animated: true)
        print("latitude: \(selectedMapView.userLocation.coordinate.latitude)")
        print("longitude: \(selectedMapView.userLocation.coordinate.longitude)")
        selectedMapView.userTrackingMode = .followWithHeading
    }
    
}

// MARK:- SearchBar に関する処理
extension SelectedPlacePointViewController: UISearchBarDelegate {
    
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
            self.selectedMapView.region = MKCoordinateRegion(center: targetCoordinate, latitudinalMeters: 500.0, longitudinalMeters: 500.0)
        })
    }
}

// MARK:-  MapView に関する処理
extension SelectedPlacePointViewController: MKMapViewDelegate {
    
    func configureMapView() {
        selectedMapView.delegate = self
        
        // 現在位置表示の有効化
        selectedMapView.showsUserLocation = true
        selectedMapView.userTrackingMode = .followWithHeading
    }
    
    // ピンを立てる関数
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
        
        return pinView
    }
    
    @IBAction func changeMaptype(_ sender: Any) {
        switch (sender as AnyObject).selectedSegmentIndex {
        case 0:
            selectedMapView.mapType = .standard
        case 1:
            selectedMapView.mapType = .satellite
        case 2:
            selectedMapView.mapType = .hybrid
        default:
            selectedMapView.mapType = .standard
        }
    }
}


// MARK:- CLLocationManagerDelegate に関する処理
extension SelectedPlacePointViewController: CLLocationManagerDelegate {
    
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
