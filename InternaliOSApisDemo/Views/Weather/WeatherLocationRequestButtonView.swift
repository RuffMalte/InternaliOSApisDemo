//
//  WeatherLocationRequestButtonView.swift
//  InternaliOSApisDemo
//
//  Created by Malte Ruff on 05.10.24.
//

import SwiftUI

struct WeatherLocationRequestButtonView: View {
	
	@EnvironmentObject private var weatherController: WeatherController

    var body: some View {
		Section {
			Button {
				weatherController.requestLocationPermission()
			} label: {
				Label("Request Location Access", systemImage: "cloud.drizzle.fill")
			}
		} header: {
			Text(weatherController.authorizationStatusString)
		}
    }
}

#Preview {
	WeatherLocationRequestButtonView()
}
