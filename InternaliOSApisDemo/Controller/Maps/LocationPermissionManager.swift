//
//  LocationPermissionManager.swift
//  InternaliOSApisDemo
//
//  Created by Malte Ruff on 30.09.24.
//

import Foundation
import MapKit
import Observation

@Observable
class LocationPermissionManager: NSObject, ObservableObject {
	var authorizationStatus: CLAuthorizationStatus = .notDetermined
	var error: Error?
	var lastLocation: CLLocation?
	
	private let locationManager = CLLocationManager()
	
	override init() {
		super.init()
		locationManager.delegate = self
		authorizationStatus = locationManager.authorizationStatus
	}
	
	var authorizationStatusString: String {
		switch authorizationStatus {
		case .notDetermined:
			return "Not Determined"
		case .restricted:
			return "Restricted"
		case .denied:
			return "Denied"
		case .authorizedAlways:
			return "Authorized Always"
		case .authorizedWhenInUse:
			return "Authorized When in Use"
		@unknown default:
			return "Unknown"
		}
	}
	
	func requestPermission() {
		locationManager.requestWhenInUseAuthorization()
	}
	
	func requestLocation() {
		switch authorizationStatus {
		case .authorizedWhenInUse, .authorizedAlways:
			locationManager.requestLocation()
		case .denied, .restricted:
			self.error = NSError(domain: "LocationPermissionManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Location access denied or restricted."])
		case .notDetermined:
			requestPermission()
		@unknown default:
			self.error = NSError(domain: "LocationPermissionManager", code: 2, userInfo: [NSLocalizedDescriptionKey: "Unknown authorization status."])
		}
	}
}

extension LocationPermissionManager: CLLocationManagerDelegate {
	func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
		DispatchQueue.main.async {
			self.authorizationStatus = manager.authorizationStatus
		}
	}
	
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		DispatchQueue.main.async {
			self.lastLocation = locations.last
		}
	}
	
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		DispatchQueue.main.async {
			self.error = error
		}
	}
}
