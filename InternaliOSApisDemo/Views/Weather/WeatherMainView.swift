//
//  WeatherMainView.swift
//  InternaliOSApisDemo
//
//  Created by Malte Ruff on 05.10.24.
//

import SwiftUI
import WeatherKit
import MapKit


struct WeatherMainView: View {
	@EnvironmentObject private var controller: WeatherController
	
	
	var body: some View {
		Form {
			WeatherLocationRequestButtonView()
			
			Group {
				
				
				if controller.isLoading {
					ProgressView()
				} else if let errorMessage = controller.errorMessage {
					Text(errorMessage)
						.foregroundColor(.red)
				} else {
					if let weather = controller.weather {
						WeatherContentView(weather: weather)
					}
				}
			}
			.frame(height: 200)
			
			
			
			Section {
				HStack {
					Spacer()
					VStack {
						Text(" Weather")
						
						Link("Legal Notices", destination: URL(string: "https://weather-data.apple.com/legal-attribution.html")!)
							.font(.subheadline)
					}
					Spacer()
				}
			}
			.listRowInsets(EdgeInsets())
			.listRowBackground(Color.clear)

			
		}
	}

}

#Preview {
    WeatherMainView()
}
