//
//  MapsSearchForPOIView.swift
//  InternaliOSApisDemo
//
//  Created by Malte Ruff on 01.10.24.
//

import SwiftUI
import MapKit

struct MapsSearchForPOIView: View {
	
	@Binding var cameraPosition: MapCameraPosition
	@Binding var searchText: String
	@Binding var searchResults: [MKMapItem]
	@Binding var isShowingSearchResults: Bool
	@Binding var selectedRoute: MKRoute?
	@Binding var estimatedTravelTime: TimeInterval?

	@EnvironmentObject private var locationManager: LocationPermissionManager
	
	var body: some View {
		Section {
			DisclosureGroup(isExpanded: $isShowingSearchResults) {
				if !searchResults.isEmpty {
					List(searchResults, id: \.self) { item in
						HStack {
							Menu {
								Button {
									getDirections(to: item, transportType: .automobile)
								} label: {
									Label("Drive", systemImage: "car.fill")
								}
								
								Button {
									getDirections(to: item, transportType: .walking)
								} label: {
									Label("Walk", systemImage: "figure.walk")
								}
								
								Button {
									getDirections(to: item, transportType: .transit)
								} label: {
									Label("Public transport", systemImage: "bus.fill")
								}
							} label: {
								Image(systemName: "ellipsis.circle.fill")
							}

							VStack(alignment: .leading) {
								HStack {
									Text(item.name ?? "Unknown")
									Spacer()
									Text(item.phoneNumber ?? "")
										.foregroundStyle(.tint)
										.font(.system(.subheadline, design: .monospaced, weight: .bold))
								}
								Text(item.placemark.title ?? "")
									.font(.caption)
							}
						}
					}
					
				}
			} label: {
				TextField("Search for POIs", text: $searchText)
					.onSubmit {
						withAnimation {
							isShowingSearchResults = false
							searchPOIs()
							isShowingSearchResults = true
						}
					}
			}
		} header: {
			Text("Search for POIs")
		}
	}
	
	func getDirections(to destination: MKMapItem, transportType: MKDirectionsTransportType) {
		guard let userLocation = locationManager.lastLocation else { return }
		
		let request = MKDirections.Request()
		request.source = MKMapItem(placemark: MKPlacemark(coordinate: userLocation.coordinate))
		request.destination = destination
		request.transportType = transportType
		
		let directions = MKDirections(request: request)
		directions.calculate { response, error in
			guard let route = response?.routes.first else {
				print("Error calculating route: \(error?.localizedDescription ?? "Unknown error")")
				return
			}
			self.selectedRoute = route
			self.estimatedTravelTime = route.expectedTravelTime
			
			let rect = route.polyline.boundingMapRect
			self.cameraPosition = .rect(rect)
		}
	}
	
	func searchPOIs() {
		guard let location = locationManager.lastLocation else { return }
		
		let request = MKLocalSearch.Request()
		request.naturalLanguageQuery = searchText
		request.region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 2000, longitudinalMeters: 2000)
		
		let search = MKLocalSearch(request: request)
		search.start { response, error in
			guard let response = response else {
				print("Error: \(error?.localizedDescription ?? "Unknown error")")
				return
			}
			
			self.searchResults = response.mapItems
			
			if let firstResult = response.mapItems.first {
				cameraPosition = .region(MKCoordinateRegion(center: firstResult.placemark.coordinate, latitudinalMeters: 2000, longitudinalMeters: 2000))
			}
		}
	}
}

//#Preview {
//    MapsSearchForPOIView()
//}
