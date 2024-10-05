//
//  WeatherContentView.swift
//  InternaliOSApisDemo
//
//  Created by Malte Ruff on 05.10.24.
//

import SwiftUI
import WeatherKit

struct WeatherContentView: View {
	
	var weather: Weather
	@EnvironmentObject private var controller: WeatherController

    var body: some View {
		Section {
			VStack(alignment: .center, spacing: 20) {
				
				HStack {
					Spacer()
					Image(systemName: weather.currentWeather.symbolName)
						.font(.system(size: 75))
					
					VStack(alignment: .leading) {
						Text(weather.currentWeather.temperature.formatted(.measurement(width: .narrow, usage: .weather, numberFormatStyle: .number.precision(.fractionLength(0)))))
							.font(.system(.title, design: .default, weight: .bold))
						
						Text(weather.currentWeather.condition.description)
							.font(.subheadline)
						
						Text("Feels: " + weather.currentWeather.apparentTemperature.formatted(.measurement(width: .narrow, usage: .weather, numberFormatStyle: .number.precision(.fractionLength(0)))))
							.font(.subheadline)
					}
					Spacer()
					
				}
				
				HStack {
					Spacer()
					VStack(alignment: .leading) {
						infoRow("Humidity:", value: weather.currentWeather.humidity.formatted(.percent))
						infoRow("Wind:", value: weather.currentWeather.wind.speed.formatted() + " " + weather.currentWeather.wind.direction.description)
						infoRow("UV Index:", value: weather.currentWeather.uvIndex.category.description)
					}
					Spacer()
				}
			}
		}
		.listRowInsets(EdgeInsets())
		.listRowBackground(Color.blue)
    }
	
	func infoRow(_ title: String, value: String) -> some View {
		HStack {
			Text(title)
				.fontWeight(.semibold)
			Text(value)
		}
	}
	
}

//#Preview {
//    WeatherContentView()
//}
