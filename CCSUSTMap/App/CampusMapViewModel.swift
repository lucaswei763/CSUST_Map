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

    @Published var cameraPosition: MapCameraPosition = .automatic
    @Published var selectedCampus: Campus = .jinpenling {
        didSet { cameraPosition = selectedCampus.position }
    }

    // 选中的分类
    @Published var selectedCategory: Category = .all

    @Published var userLocation: CLLocation?

    @Published var selectedPlace: Place?

    // MARK: - 计算属性，返回过滤后的地点
    var filteredPlaces: [Place] {
        PlaceData.samplePlaces.filter { place in
            let campusMatch = place.campus == selectedCampus
            let categoryMatch = (selectedCategory == .all || place.category == selectedCategory)
            return campusMatch && categoryMatch
        }
    }

    // MARK: - 选择地点并跳转地图
    func selectPlace(_ place: Place) {
        selectedPlace = place
        withAnimation(.easeInOut(duration: 0.3)) {
            cameraPosition = .region(
                MKCoordinateRegion(
                    center: place.location.coordinate,
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

    private var hasCenteredOnUser = false

    // MARK: - 更新用户位置
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        // 1. 更新用户位置
        guard location.horizontalAccuracy < 100 && location.verticalAccuracy < 100 else { return }
        userLocation = location

        // 只有第一次定位时自动缩放到用户位置，或者提供手动按钮
        if !hasCenteredOnUser {
            withAnimation(.easeInOut(duration: 0.8)) {
                cameraPosition = .region(
                    MKCoordinateRegion(
                        center: location.coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
                    )
                )
            }
            hasCenteredOnUser = true
        }

        // 获取到位置后可以继续更新但不一定强制移动相机
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location update failed: \(error)")
    }

    //MARK: 计算距离和时间
    func getDistanceInfo(for place: Place) -> (distance: String, time: String)? {
        guard let userLoc = userLocation else { return nil }

        let destination = place.location
        let distanceInMeters = userLoc.distance(from: destination)

        //格式化距离
        let distanceString: String
        if distanceInMeters < 1000 {
            distanceString = "\(Int(distanceInMeters))m"
        } else {
            distanceString = String(format: "%.1fkm", distanceInMeters / 1000)
        }

        let minutes = Int(distanceInMeters / (1.2 * 60))
        var timeString = ""
        if minutes > 60 {
            timeString = "\(minutes / 60)小时"
        } else {
            timeString = minutes >= 1 ? "\(minutes)分钟" : "1分钟内"
        }
        return (distanceString, timeString)
    }

    // MARK: 在 AppleMap 中打开导航
    func navigation(to destination: Place) {

        var mapItem = MKMapItem()

        if #available(iOS 18.0, *) {
            // 1. 创建终点的坐标点
            let location = destination.location

            // 2. 创建地图项（包含终点坐标和名字）
            mapItem = MKMapItem(location: location, address: nil)
            mapItem.name = destination.name

            // 3. 设置导航参数
            // MKLaunchOptionsDirectionsModeKey: 设置导航模式
            // .driving (驾车), .walking (步行), .transit (公交)
            let launchOptions = [
                MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking
            ]

            // 4. 调起苹果地图应用
            mapItem.openInMaps(launchOptions: launchOptions)
        } else {
            let placeMark = MKPlacemark(coordinate: destination.location.coordinate)
            mapItem = MKMapItem(placemark: placeMark)
            mapItem.name = destination.name
            let launchOptions = [
                MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking
            ]
            mapItem.openInMaps(launchOptions: launchOptions)
        }
    }
}
