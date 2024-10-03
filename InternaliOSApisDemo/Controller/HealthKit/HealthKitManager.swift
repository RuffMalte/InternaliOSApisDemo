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
	var standHours: Double = 0
	var currentHeartRate: Double = 0
	
	init() { }
	
	func requestAuthorization() {
		guard HKHealthStore.isHealthDataAvailable() else {
			print("HealthKit is not available on this device")
			return
		}
		
		let typesToRead: Set = [
			HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
			HKObjectType.quantityType(forIdentifier: .appleExerciseTime)!,
			HKObjectType.categoryType(forIdentifier: .appleStandHour)!,
			HKObjectType.quantityType(forIdentifier: .heartRate)!,
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
	
	private func fetchStandHours(for type: HKCategoryTypeIdentifier, predicate: NSPredicate, completion: @escaping (Double) -> Void) {
		guard let type = HKCategoryType.categoryType(forIdentifier: type) else { return }

		let query = HKSampleQuery(sampleType: type, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, error in
			guard let samples = samples as? [HKCategorySample], error == nil else {
				print("Failed to fetch stand hours: \(error?.localizedDescription ?? "Unknown error")")
				completion(0)
				return
			}
			
			DispatchQueue.main.async {
				let standHours = samples.filter { $0.value == HKCategoryValueAppleStandHour.stood.rawValue }.count
				completion(Double(standHours))
			}
		}
		
		healthStore.execute(query)
	}
	
	
	func fetchLastHeartRate() {
		guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else { return }
		
		let query = HKSampleQuery(sampleType: heartRateType, predicate: nil, limit: 1, sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]) { query, samples, error in
			guard let sample = samples?.first as? HKQuantitySample else {
				print("Failed to fetch heart rate: \(error?.localizedDescription ?? "Unknown error")")
				return
			}
			
			DispatchQueue.main.async {
				self.currentHeartRate = sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
				print(self.currentHeartRate.description)
			}
		}
		
		healthStore.execute(query)
	}
	
	
	func fetchHistoricalHeartRate(for period: HistoricalDataPeriod, completion: @escaping ([(Date, Double)]) -> Void) {
		guard let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) else {
			completion([])
			return
		}
		
		let endDate = Date()
		let startDate: Date
		let interval: DateComponents
		let options: HKStatisticsOptions
		
		switch period {
		case .day:
			startDate = Calendar.current.date(byAdding: .day, value: -1, to: endDate)!
			interval = DateComponents(hour: 1)
			options = .discreteAverage
		case .week:
			startDate = Calendar.current.date(byAdding: .day, value: -7, to: endDate)!
			interval = DateComponents(day: 1)
			options = .discreteAverage
		case .month:
			startDate = Calendar.current.date(byAdding: .month, value: -1, to: endDate)!
			interval = DateComponents(day: 1)
			options = .discreteAverage
		case .sixMonths:
			startDate = Calendar.current.date(byAdding: .month, value: -6, to: endDate)!
			interval = DateComponents(day: 7)
			options = .discreteAverage
		case .year:
			startDate = Calendar.current.date(byAdding: .year, value: -1, to: endDate)!
			interval = DateComponents(month: 1)
			options = .discreteAverage
		}
		
		let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
		
		let query = HKStatisticsCollectionQuery(quantityType: heartRateType,
												quantitySamplePredicate: predicate,
												options: options,
												anchorDate: startDate,
												intervalComponents: interval)
		
		query.initialResultsHandler = { query, results, error in
			guard let statsCollection = results, error == nil else {
				print("Error fetching heart rate data: \(error?.localizedDescription ?? "Unknown error")")
				completion([])
				return
			}
			
			var heartRateData: [(Date, Double)] = []
			
			statsCollection.enumerateStatistics(from: startDate, to: endDate) { statistics, stop in
				if let quantity = statistics.averageQuantity() {
					let date = statistics.startDate
					let value = quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
					heartRateData.append((date, value))
				}
			}
			
			DispatchQueue.main.async {
				completion(heartRateData)
			}
		}
		
		healthStore.execute(query)
	}
}

enum HistoricalDataPeriod: String, CaseIterable {
	case day
	case week
	case month
	case sixMonths
	case year
	
	var shortName: String {
		switch self {
		case .day: return "1d"
		case .week: return "1w"
		case .month: return "1m"
		case .sixMonths: return "6m"
		case .year: return "1y"
		}
	}
}
