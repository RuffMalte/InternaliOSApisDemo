//
//  InternaliOSApisDemoApp.swift
//  InternaliOSApisDemo
//
//  Created by Malte Ruff on 26.09.24.
//

import SwiftUI
import SwiftData

@main
struct InternaliOSApisDemoApp: App {
	
	@StateObject private var reminderManager = ReminderManager()
	
	@StateObject private var calendarManager = CalendarManager()
	
	@StateObject private var locationManager = LocationPermissionManager()
	
	@StateObject private var healthKitManager = HealthKitManager()
	
	@StateObject private var workoutManager = WorkoutManager()
	
	@StateObject private var weatherController = WeatherController()
	
	@StateObject private var motionManager = MotionManager()

	let container: ModelContainer

	init() {
		let schema = Schema([
			ImageItem.self
		])
		let config = ModelConfiguration("InternalIOsApisDemo", schema: schema)
		do {
			container = try ModelContainer(for: schema, configurations: config)
		} catch {
			fatalError("Could not configure the container")
		}

		print(URL.applicationSupportDirectory.path(percentEncoded: false))
	}
	
	
    var body: some Scene {
        WindowGroup {
            ContentView()
				.environmentObject(reminderManager)
				.environmentObject(calendarManager)
				.environmentObject(locationManager)
				.environmentObject(healthKitManager)
				.environmentObject(workoutManager)
				.modelContainer(container)
				.environmentObject(weatherController)
				.environmentObject(motionManager)
        }
    }
}
