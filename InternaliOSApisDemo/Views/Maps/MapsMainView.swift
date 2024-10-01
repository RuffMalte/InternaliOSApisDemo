//
//  MapsMainView.swift
//  InternaliOSApisDemo
//
//  Created by Malte Ruff on 30.09.24.
//

import SwiftUI
import MapKit

struct MapsMainView: View {
	@State private var cameraPosition: MapCameraPosition = .userLocation(fallback: .automatic)
	@State private var showUserLocation = false
	@EnvironmentObject private var locationManager: LocationPermissionManager
	@State private var showDebugPopup: Bool = false
	
	@State private var annotations: [CustomAnnotation] = []
	
	@State private var searchText = ""
	@State private var searchResults: [MKMapItem] = []
	@State private var isShowingSearchResults: Bool = false
	@State private var selectedRoute: MKRoute?
	@State private var estimatedTravelTime: TimeInterval?
	
	var body: some View {
		Form {
			MapsRequestPermissonsButtonView()
			
			Section {
				Map(position: $cameraPosition, interactionModes: [.pan, .zoom]) {
					if showUserLocation {
						UserAnnotation()
					}
					ForEach(searchResults, id: \.self) { item in
						Marker(item.name ?? "Unknown", coordinate: item.placemark.coordinate)
					}
					
					ForEach(annotations) { annotation in
						Annotation(annotation.title, coordinate: annotation.coordinate) {
							Image(systemName: "mappin.circle.fill")
								.foregroundColor(.yellow)
						}
					}
					
					if let route = selectedRoute {
						MapPolyline(route.polyline)
							.stroke(.blue, lineWidth: 5)
					}
				}
				.frame(height: 300)
				.mapControls {
					MapCompass()
					MapScaleView()
					MapUserLocationButton()
				}
			} footer: {
				if let time = estimatedTravelTime {
					HStack {
						Text("Estimated travel time: \(formatTravelTime(time))")
						Spacer()
						Button {
							selectedRoute = nil
							estimatedTravelTime = nil
						} label: {
							Image(systemName: "arrow.counterclockwise")
						}
					}
					.padding(.horizontal)
				}
			}
			.listRowInsets(EdgeInsets())
			
			MapsAddDemoAnnotationsButtonView(annotations: $annotations)
			
			MapsSearchForPOIView(cameraPosition: $cameraPosition, searchText: $searchText, searchResults: $searchResults, isShowingSearchResults: $isShowingSearchResults, selectedRoute: $selectedRoute, estimatedTravelTime: $estimatedTravelTime)
		}
		.navigationTitle("MapKit demo")
		.navigationBarTitleDisplayMode(.inline)
		.onAppear {
			if (locationManager.authorizationStatus == .authorizedWhenInUse) {
				locationManager.requestLocation()
			}
		}
		.onChange(of: locationManager.lastLocation) { _, newLocation in
			if let location = newLocation {
				cameraPosition = .region(
					MKCoordinateRegion(
						center: location.coordinate,
						latitudinalMeters: 1000,
						longitudinalMeters: 1000
					)
				)
				showUserLocation = true
			}
		}
	}
	func formatTravelTime(_ time: TimeInterval) -> String {
		let formatter = DateComponentsFormatter()
		formatter.allowedUnits = [.day, .hour, .minute, .second]
		formatter.unitsStyle = .abbreviated
		return formatter.string(from: time) ?? "Unknown"
	}
}

#Preview {
	NavigationStack {
		MapsMainView()
	}
}
