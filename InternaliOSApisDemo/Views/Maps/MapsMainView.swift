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
				}
				.frame(height: 300)
				.mapControls {
					MapCompass()
					MapScaleView()
					MapUserLocationButton()
				}
			}
			.listRowInsets(EdgeInsets())
			
			MapsAddDemoAnnotationsButtonView(annotations: $annotations)
			
			MapsSearchForPOIView(cameraPosition: $cameraPosition, searchText: $searchText, searchResults: $searchResults, isShowingSearchResults: $isShowingSearchResults)
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
}

#Preview {
	NavigationStack {
		MapsMainView()
	}
}
