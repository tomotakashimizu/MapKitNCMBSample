//
//  PlacePointViewController.swift
//  MapKitNCMBSample
//
//  Created by 清水智貴 on 2020/10/17.
//

import UIKit
import NCMB
import MapKit

class SelectedPlacePointViewController: UIViewController, MKMapViewDelegate {
    
    var selectedGeoPoint = NCMBGeoPoint()
    @IBOutlet var selectedMapView: MKMapView!
    @IBOutlet var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        selectedMapView.delegate = self
        setSearchBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        let pointAnnotation = MKPointAnnotation()
        let placePoint = CLLocationCoordinate2DMake(selectedGeoPoint.latitude, selectedGeoPoint.longitude)
        
        pointAnnotation.coordinate = placePoint
        self.selectedMapView.addAnnotation(pointAnnotation)
        self.selectedMapView.region = MKCoordinateRegion(center: placePoint, latitudinalMeters: 3000.0, longitudinalMeters: 3000.0)
    }
    
    // ピンを立てる関数
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
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
        
        if let searchKey = searchText {
            
            let geocoder = CLGeocoder()
            
            geocoder.geocodeAddressString(searchKey, completionHandler: { (placemarks, error) in
                
                if let unwrapPlacemarks = placemarks {
                    if let firstPlacemark = unwrapPlacemarks.first {
                        if let location = firstPlacemark.location {
                            
                            let targetCoordinate = location.coordinate
                            print(targetCoordinate)
                            
                            self.selectedMapView.region = MKCoordinateRegion(center: targetCoordinate, latitudinalMeters: 500.0, longitudinalMeters: 500.0)
                        }
                    }
                }
            })
        }
    }
}
