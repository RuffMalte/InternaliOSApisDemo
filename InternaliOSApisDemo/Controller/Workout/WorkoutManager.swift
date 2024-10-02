//
//  WorkoutManager.swift
//  InternaliOSApisDemo
//
//  Created by Malte Ruff on 02.10.24.
//

import SwiftUI
import HealthKit
import Observation

@Observable
class WorkoutManager: ObservableObject {
	let healthStore = HKHealthStore()
	var workouts: [HKWorkout] = []
	var isAuthorized = false
	
	init() {
		requestAuthorization()
	}
	
	func requestAuthorization() {
		let typesToRead: Set = [
			HKObjectType.workoutType(),
			HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
			HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
			HKObjectType.quantityType(forIdentifier: .heartRate)!
		]
		
		healthStore.requestAuthorization(toShare: nil, read: typesToRead) { (success, error) in
			DispatchQueue.main.async {
				self.isAuthorized = success
				if success {
					Task {
						await self.fetchLatestWorkouts()
					}
				} else if let error = error {
					print("Authorization failed: \(error.localizedDescription)")
				}
			}
		}
	}
	
	func fetchLatestWorkouts() async {
		let workoutType = HKObjectType.workoutType()
		let calendar = Calendar.current
		let now = Date()
		let startDate = calendar.date(byAdding: .day, value: -14, to: now)
		let predicate = HKQuery.predicateForSamples(withStart: startDate, end: now, options: .strictStartDate)
		let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
		
		do {
			let samples = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[HKSample], Error>) in
				let query = HKSampleQuery(sampleType: workoutType, predicate: predicate, limit: 20, sortDescriptors: [sortDescriptor]) { _, samples, error in
					if let error = error {
						continuation.resume(throwing: error)
					} else {
						continuation.resume(returning: samples ?? [])
					}
				}
				healthStore.execute(query)
			}
			
			self.workouts = samples.compactMap { $0 as? HKWorkout }
		} catch {
			print("Error fetching workouts: \(error.localizedDescription)")
		}
	}
	
	func appIcon(for workout: HKWorkout) async -> UIImage? {
		let bundleIdentifier = workout.sourceRevision.source.bundleIdentifier
		
#if os(iOS)
		guard let url = URL(string: "https://itunes.apple.com/lookup?bundleId=\(bundleIdentifier)") else {
			return nil
		}
		
		do {
			let (data, _) = try await URLSession.shared.data(from: url)
			if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
			   let results = json["results"] as? [[String: Any]],
			   let appInfo = results.first,
			   let iconUrlString = appInfo["artworkUrl60"] as? String,
			   let iconUrl = URL(string: iconUrlString) {
				
				let (iconData, _) = try await URLSession.shared.data(from: iconUrl)
				if let image = UIImage(data: iconData) {
					return image
				}
			}
		} catch {
			print("Error fetching app icon: \(error)")
		}
#elseif os(macOS)
		if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleIdentifier) {
			let image = NSWorkspace.shared.icon(forFile: url.path)
			return NSImage(cgImage: image.cgImage!, size: NSSize(width: 30, height: 30))
		}
#endif
		
		return nil
	}
	
	
	func workoutName(for workout: HKWorkout) -> String {
		if let name = workout.metadata?[HKMetadataKeyWorkoutBrandName] as? String {
			return name
		} else {
			return workoutActivityTypeToString(workout.workoutActivityType)
		}
	}
	
	func workoutActivityTypeToString(_ workoutType: HKWorkoutActivityType) -> String {
		switch workoutType {
		case .running:
			return "Running"
		case .walking:
			return "Walking"
		case .functionalStrengthTraining:
			return "Functional Strength Training"
		case .traditionalStrengthTraining:
			return "Traditional Strength Training"
		case .hiking:
			return "Hiking"
		case .dance:
			return "Dance"
		case .cooldown:
			return "Cooldown"
		default:
			return "Other Workout"
		}
	}
	
	func workoutActivityTypeToSymbol(_ workoutType: HKWorkoutActivityType) -> String {
		switch workoutType {
		case .running:
			return "figure.run"
		case .walking:
			return "figure.walk"
		case .functionalStrengthTraining, .traditionalStrengthTraining:
			return "dumbbell"
		case .hiking:
			return "mountain.2"
		case .dance:
			return "figure.dance"
		case .cooldown:
			return "figure.cooldown"
		case .cycling:
			return "figure.outdoor.cycle"
		case .swimming:
			return "figure.pool.swim"
		case .yoga:
			return "figure.mind.and.body"
		case .jumpRope:
			return "figure.jumprope"
		case .stairs:
			return "figure.stairs"
		default:
			return "figure.mixed.cardio"
		}
	}
}
