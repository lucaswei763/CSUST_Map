//
//  ContentView.swift
//  Map_4
//
//  Created by 韦亦航 on 2026/1/7.
//

import Combine
import MapKit
import SwiftUI

struct CampusMapView: View {
    @StateObject private var viewModel = CampusMapViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // MARK: 1. 地图视图
                Map(position: $viewModel.cameraPosition) {
                    UserAnnotation()
                }
                .mapControls { MapUserLocationButton() }
                .frame(height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding()
                
                // MARK: 2. 分类横条 (Category Bar)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(Category.allCases) { category in
                            CategoryButton(
                                category: category,
                                isSelected: viewModel.selectedCategory == category
                            ) {
                                viewModel.selectedCategory = category
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)
                
                // MARK: 3. 建筑物列表 (Building List)
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 12) {
                        ForEach(viewModel.filteredPlaces) { place in
                            PlaceRowView(
                                place: place,
                                action: {
                                    viewModel.selectPlace(place)
                                },
                                distanceInfo: viewModel.getDistanceInfo(for: place)
                            )
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 8)
                    
                    Spacer()
                }
                .navigationTitle(viewModel.selectedCampus.rawValue)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Menu {
                            Button {
                                viewModel.selectedCampus = .jinpenling
                            } label: {
                                HStack {
                                    Text("金盆岭校区")
                                    if viewModel.selectedCampus == .jinpenling {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                            
                            Button {
                                viewModel.selectedCampus = .yuntang
                            } label: {
                                HStack {
                                    Text("云塘校区")
                                    if viewModel.selectedCampus == .yuntang {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        } label: {
                            Image(systemName: "building.columns")
                            Image(systemName: "chevron.down")
                        }
                    }
                }
            }
        }
    }
}

// MARK: - 辅助子视图：地点行视图
struct PlaceRowView: View {
    let place: Place
    let action: () -> Void
    let distanceInfo: (distance: String, time: String)? // 传入信息

    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                // 图标
                Image(systemName: place.category.icon)
                    .font(.title3)
                    .foregroundColor(.blue)
                    .frame(width: 45, height: 45)
                    .background(Color.blue.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                // 文字详情
                VStack(alignment: .leading, spacing: 4) {
                    Text(place.name)
                        .font(.headline)
                        .foregroundColor(.primary)

                    HStack (spacing: 8) {
                        Text(place.category.rawValue)

                        
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }

                Spacer()

                HStack {
                    VStack {
                        //显示距离和时间
                        if let info = distanceInfo {
                            Text("\(info.distance)")
                            Text(" \(info.time)")
                        }
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                    
                    // 右侧箭头
                    Image(systemName: "arrow.turn.up.right")
                        .font(.caption)
                        .foregroundColor(Color(.systemGray3))
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(.systemGray6), lineWidth: 1)
            )
        }
    }
}

// MARK:辅助子视图：分类按钮
struct CategoryButton: View {
    let category: Category
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: category.icon)
                Text(category.rawValue)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isSelected ? Color.blue : Color(.systemGray6))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(20)
        }
    }
}

#Preview {
    CampusMapView()
}
