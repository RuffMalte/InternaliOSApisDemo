//
//  WeatherController.swift
//  InternaliOSApisDemo
//
//  Created by Malte Ruff on 05.10.24.
//


import Foundation
import MapKit
import WeatherKit

class WeatherController: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var weather: Weather?
    @Published var currentLocation: CLLocation?
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    private let locationManager = CLLocationManager()
    private let weatherService = WeatherService()
    
    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    func checkLocationPermission() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            requestLocationPermission()
        case .restricted, .denied:
            errorMessage = "Location access is restricted. Please enable it in Settings to use this feature."
        case .authorizedAlways, .authorizedWhenInUse:
            fetchLocation()
        @unknown default:
            break
        }
    }
    
	var authorizationStatusString: String {
		switch locationManager.authorizationStatus {
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
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    private func fetchLocation() {
        locationManager.requestLocation()
    }
    
	func fetchWeather() {
		guard let location = currentLocation else {
			errorMessage = "Location not available. Please try again."
			return
		}
		
		isLoading = true
		Task {
			do {
				let weather = try await weatherService.weather(for: location)
				DispatchQueue.main.async {
					self.weather = weather
					self.isLoading = false
				}
			} catch {
				DispatchQueue.main.async {
					self.errorMessage = "Failed to fetch weather: \(error.localizedDescription)"
					print("Detailed error: \(error)")
					self.isLoading = false
				}
			}
		}
	}
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            currentLocation = location
            fetchWeather()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        errorMessage = "Failed to get location: \(error.localizedDescription)"
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationPermission()
    }
}
