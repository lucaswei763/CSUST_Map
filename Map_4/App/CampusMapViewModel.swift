//
//  CampusMapViewModel.swift
//  Map_4
//
//  Created by 韦亦航 on 2026/1/7.
//

import Combine
import CoreLocation
import MapKit
import SwiftUI

enum Campus: String, CaseIterable, Identifiable {
    case jinpenling = "金盆岭校区"
    case yuntang = "云塘校区"

    var id: String { self.rawValue }

    var coordinate: CLLocationCoordinate2D {
        switch self {
        case .jinpenling:
            return CLLocationCoordinate2D(latitude: 28.1560, longitude: 112.9765)
        case .yuntang:
            return CLLocationCoordinate2D(latitude: 28.0668, longitude: 113.0095)
        }
    }

    var position: MapCameraPosition {
        .region(
            MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
            ))
    }
}

class CampusMapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var cameraPosition: MapCameraPosition = Campus.jinpenling.position
    @Published var selectedCampus: Campus = .jinpenling {
        didSet { cameraPosition = selectedCampus.position }
    }

    // 1. 新增：选中的分类
    @Published var selectedCategory: Category = .all

    @Published var userLocation: CLLocation?

    // 2. 新增：计算属性，返回过滤后的地点
    var filteredPlaces: [Place] {
        PlaceData.samplePlaces.filter { place in
            let campusMatch = place.campus == selectedCampus
            let categoryMatch = (selectedCategory == .all || place.category == selectedCategory)
            return campusMatch && categoryMatch
        }
    }

    // 3. 新增：选择地点并跳转地图
    func selectPlace(_ place: Place) {
        withAnimation(.easeInOut(duration: 0.3)) {
            cameraPosition = .region(
                MKCoordinateRegion(
                    center: place.location,
                    span: MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002)
                )
            )
        }
    }

    private let locationManager = CLLocationManager()

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()

        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        userLocation = location
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location update failed: \(error)")
    }


    //MARK: 计算距离和时间
    func getDistanceInfo(for place: Place) -> (distance: String, time: String)? {
        guard let userLoc = userLocation else { return nil }

        let destination = CLLocation(latitude: place.location.latitude, longitude: place.location.longitude)
        let distanceInMeters = userLoc.distance(from: destination)

        //格式化距离
        let distanceString : String
        if distanceInMeters < 1000 {
            distanceString = "\(Int(distanceInMeters))m"
        } else {
            distanceString = String(format: "%.1fkm", distanceInMeters / 1000)
        }
        
        let minutes = Int(distanceInMeters / (1.2 * 60))
        let timeString = minutes >= 1 ? "\(minutes)分钟" : "1分钟内"

        return (distanceString, timeString)
    }
}
