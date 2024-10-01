//
//  HealthKitManager.swift
//  InternaliOSApisDemo
//
//  Created by Malte Ruff on 01.10.24.
//

import SwiftUI
import HealthKit
import Observation

@Observable
class HealthKitManager: ObservableObject {
	private let healthStore = HKHealthStore()
	var isAuthorized = false
	var moveCalories: Double = 0
	var exerciseMinutes: Double = 0
	var standHours: Int = 0
	
	var moveProgress: Double { moveCalories / 500 }
	var exerciseProgress: Double { exerciseMinutes / 30 }
	var standProgress: Int { standHours / 12 }
	
	init() {
		requestAuthorization()
	}
	
	func requestAuthorization() {
		guard HKHealthStore.isHealthDataAvailable() else {
			print("HealthKit is not available on this device")
			return
		}
		
		let typesToRead: Set = [
			HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
			HKObjectType.quantityType(forIdentifier: .appleExerciseTime)!,
			HKObjectType.quantityType(forIdentifier: .appleStandTime)!
		]
		
		healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
			DispatchQueue.main.async {
				self.isAuthorized = success
				if success {
					self.fetchDailyActivity()
				} else if let error = error {
					print("HealthKit authorization failed: \(error.localizedDescription)")
				}
			}
		}
	}
	
	func fetchDailyActivity() {
		let calendar = Calendar.current
		let now = Date()
		let startOfDay = calendar.startOfDay(for: now)
		let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
		
		fetchQuantity(for: .activeEnergyBurned, unit: .kilocalorie(), predicate: predicate) { calories in
			DispatchQueue.main.async {
				self.moveCalories = calories
			}
		}
		
		fetchQuantity(for: .appleExerciseTime, unit: .minute(), predicate: predicate) { minutes in
			DispatchQueue.main.async {
				self.exerciseMinutes = minutes
			}
		}
		
		fetchStandHours(for: .appleStandHour, predicate: predicate) { hours in
			DispatchQueue.main.async {
				self.standHours = hours
			}
		}
	}
	
	private func fetchQuantity(for quantityType: HKQuantityTypeIdentifier, unit: HKUnit, predicate: NSPredicate, completion: @escaping (Double) -> Void) {
		guard let type = HKQuantityType.quantityType(forIdentifier: quantityType) else { return }
		
		let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
			guard let result = result, let sum = result.sumQuantity() else {
				print("Failed to fetch \(quantityType): \(error?.localizedDescription ?? "Unknown error")")
				completion(0)
				return
			}
			
			let value = sum.doubleValue(for: unit)
			completion(value)
		}
		
		healthStore.execute(query)
	}
	
	private func fetchStandHours(for type: HKCategoryTypeIdentifier, predicate: NSPredicate, completion: @escaping (Int) -> Void) {
		guard let type = HKCategoryType.categoryType(forIdentifier: type) else { return }

		let query = HKSampleQuery(sampleType: type, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, error in
			guard let samples = samples as? [HKCategorySample], error == nil else {
				print("Failed to fetch stand hours: \(error?.localizedDescription ?? "Unknown error")")
				completion(0)
				return
			}
			
			DispatchQueue.main.async {
				let standHours = samples.filter { $0.value == HKCategoryValueAppleStandHour.stood.rawValue }.count
				completion(standHours)
			}
		}
		
		healthStore.execute(query)
	}
}
