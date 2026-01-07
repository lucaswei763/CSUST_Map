import SwiftUI
import MapKit

// MARK: 1. 分类枚举
enum Category: String, CaseIterable, Identifiable {
    case all = "全部"
    case teaching = "教学楼"
    case food = "餐饮"
    case study = "学习"
    case dorm = "宿舍"
    
    var id: Self { self }
    
    // 辅助图标
    var icon: String {
        switch self {
        case .all: return "square.grid.2x2"
        case .teaching: return "book.closed"
        case .food: return "fork.knife"
        case .study: return "graduationcap"
        case .dorm: return "bed.double"
        }
    }
}

// MARK: 2. 地点结构体
struct Place: Identifiable {
    let id = UUID()
    let name: String
    let category: Category
    let campus: Campus
    let location: CLLocationCoordinate2D
}

// MARK: 3. 地点数据
struct PlaceData {
    static let samplePlaces: [Place] = [
        // MARK: 金盆岭校区地标
        Place(
            name: "第9教学楼",
            category: .teaching,
            campus: .jinpenling,
            location: CLLocationCoordinate2D(latitude: 28.1558, longitude: 112.9780)
        ),
        
        Place(
            name: "西苑食堂",
            category: .food,
            campus: .jinpenling,
            location: CLLocationCoordinate2D(
                latitude: 28.1549,
                longitude: 112.9775
            )
        ),
        
        Place(
            name: "金盆岭图书馆",
            category: .study,
            campus: .jinpenling,
            location: CLLocationCoordinate2D(
                latitude: 28.1562,
                longitude: 112.9768
            )
        ),
        
        // 云塘校区地标
        Place(
            name: "综教楼",
            category: .teaching,
            campus: .yuntang,
            location: CLLocationCoordinate2D(
                latitude: 28.0668,
                longitude: 113.0095
            )
        ),
        
        Place(
            name: "甘草园食堂",
            category: .food,
            campus: .yuntang,
            location: CLLocationCoordinate2D(
                latitude: 28.0700,
                longitude: 113.0110
            )
        ),
        
        Place(
            name: "云塘图书馆",
            category: .study,
            campus: .yuntang,
            location: CLLocationCoordinate2D(
                latitude: 28.0680,
                longitude: 113.0125
            )
        )
    ]
}
