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
	@State private var annotations: [CustomAnnotation] = []

    var body: some View {
		Form {
			
			MapsRequestPermissonsButtonView()
			
			Section {
				Map(
					position: $cameraPosition,
					bounds: MapCameraBounds(
						minimumDistance: 10,  // Minimum zoom level (in meters)
						maximumDistance: 1000000  // Maximum zoom level (in meters)
					),
					interactionModes: [.pan, .zoom]
				) {
					if showUserLocation {
						UserAnnotation()
					}
					ForEach(annotations) { annotation in
						Annotation(annotation.title, coordinate: annotation.coordinate) {
							Image(systemName: "mappin.circle.fill")
								.foregroundColor(.red)
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
			
			
		}
		.navigationTitle("MapKit demo")
		.navigationBarTitleDisplayMode(.inline)
		.onAppear {
			if (locationManager.authorizationStatus == .authorizedWhenInUse) {
				locationManager.requestLocation()
			}
		}
		.onChange(of: locationManager.lastLocation) { _ ,newLocation in
			if let location = newLocation {
				cameraPosition = .region(
					MKCoordinateRegion(
						center: location.coordinate,
						latitudinalMeters: 200,
						longitudinalMeters: 200
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

struct CustomAnnotation: Identifiable {
	let id: UUID
	let title: String
	let coordinate: CLLocationCoordinate2D
}
