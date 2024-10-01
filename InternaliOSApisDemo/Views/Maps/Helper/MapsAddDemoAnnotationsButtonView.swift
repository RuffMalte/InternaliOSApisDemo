//
//  MapsAddDemoAnnotationsButtonView.swift
//  InternaliOSApisDemo
//
//  Created by Malte Ruff on 30.09.24.
//

import SwiftUI
import MapKit

struct CustomAnnotation: Identifiable {
	let id: UUID
	let title: String
	let coordinate: CLLocationCoordinate2D
}

struct MapsAddDemoAnnotationsButtonView: View {
	
	@Binding var annotations: [CustomAnnotation]
	
	@EnvironmentObject private var locationManager: LocationPermissionManager
	
    var body: some View {
		Section {
			Button("Add 4 Annotations") {
				addAnnotations()
			}
			.contextMenu {
				Button(role: .destructive) {
					deleteAnnotation()
				} label: {
					Label("Delete All Annotations", systemImage: "trash")
				}
			}
			.disabled(locationManager.lastLocation == nil)
		}
    }
	
	private func addAnnotations() {
		guard let userLocation = locationManager.lastLocation?.coordinate else { return }
		
		let offsets = [
			(lat: 0.0001, lon: 0.0001),
			(lat: 0.0001, lon: -0.0001),
			(lat: -0.0001, lon: 0.0001),
			(lat: -0.0001, lon: -0.0001)
		]
		
		for (index, offset) in offsets.enumerated() {
			let newCoordinate = CLLocationCoordinate2D(
				latitude: userLocation.latitude + offset.lat,
				longitude: userLocation.longitude + offset.lon
			)
			let annotation = CustomAnnotation(
				id: UUID(),
				title: "Annotation \(index + 1)",
				coordinate: newCoordinate
			)
			annotations.append(annotation)
		}
	}
	
	private func deleteAnnotation() {
		annotations.removeAll()
	}
}

#Preview {
	MapsAddDemoAnnotationsButtonView(annotations: .constant([]))
}
