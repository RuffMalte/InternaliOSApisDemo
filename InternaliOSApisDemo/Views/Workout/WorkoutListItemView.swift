//
//  WorkoutListItemView.swift
//  InternaliOSApisDemo
//
//  Created by Malte Ruff on 02.10.24.
//

import SwiftUI
import HealthKit

struct WorkoutListItemView: View {
	
	var workout: HKWorkout
	@Binding var workoutIcons: [UUID: UIImage]
	
	@EnvironmentObject var workoutManager: WorkoutManager

	
	var body: some View {
		VStack(alignment: .leading, spacing: 10) {
			DisclosureGroup {
				detailView
			} label: {
				labelView
			}
		}
		.onAppear {
			Task {
				if let icon = await workoutManager.appIcon(for: workout) {
					workoutIcons[workout.uuid] = icon
				}
			}
		}
	}
	
	var labelView: some View {
		HStack {
			Group {
				if let icon = workoutIcons[workout.uuid] {
					Image(uiImage: icon)
						.resizable()
						.aspectRatio(contentMode: .fit)
				} else {
					ZStack {
						Color.black
						
						Image(systemName: workoutManager.workoutActivityTypeToSymbol(workout.workoutActivityType))
							.foregroundStyle(.green)
					}
				}
			}
			.frame(width: 50, height: 50)
			.clipShape(.rect(cornerRadius: 10))
			
			VStack(alignment: .leading) {
				Text(workoutManager.workoutName(for: workout))
					.font(.system(.headline, design: .rounded, weight: .bold))
				
				HStack {
					Text(formatDuration(workout.duration))
					if let distance = workout.totalDistance {
						Text("-")
						Text(formatDistance(distance))
					}
				}
				.font(.system(.subheadline, design: .monospaced, weight: .medium))
			}
			
			Spacer()
			
			Text(workout.startDate, format: .dateTime.weekday(.wide))
				.font(.system(.footnote, design: .default, weight: .regular))
				.foregroundStyle(.secondary)
		}
	}
	
	var detailView: some View {
		VStack(alignment: .leading, spacing: 5) {
			Text("Start: \(workout.startDate, format: .dateTime)")
			Text("End: \(workout.endDate, format: .dateTime)")
			
			if let energyBurnedType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned),
			   let statistics = workout.statistics(for: energyBurnedType),
			   let sum = statistics.sumQuantity() {
				let energyBurned = sum.doubleValue(for: .kilocalorie())
				Text("Energy Burned: \(energyBurned, specifier: "%.2f") kcal")
			}
			
			if let device = workout.device {
				Text("Device Info:")
				Text("  Name: \(device.name ?? "N/A")")
				Text("  Manufacturer: \(device.manufacturer ?? "N/A")")
				Text("  Model: \(device.model ?? "N/A")")
				Text("  Hardware Version: \(device.hardwareVersion ?? "N/A")")
				Text("  Software Version: \(device.softwareVersion ?? "N/A")")
			}
		}
		.font(.system(.caption, design: .default))
	}
	
	func formatDuration(_ duration: TimeInterval) -> String {
		let formatter = DateComponentsFormatter()
		formatter.allowedUnits = [.hour, .minute, .second]
		formatter.unitsStyle = .abbreviated
		return formatter.string(from: duration) ?? ""
	}
	
	func formatDistance(_ distance: HKQuantity) -> String {
		let meters = distance.doubleValue(for: .meter())
		let kilometers = meters / 1000
		
		let formatter = NumberFormatter()
		formatter.numberStyle = .decimal
		formatter.maximumFractionDigits = 2
		formatter.minimumFractionDigits = 2
		
		if kilometers >= 1 {
			if let formattedDistance = formatter.string(from: NSNumber(value: kilometers)) {
				return "\(formattedDistance) km"
			}
		} else {
			formatter.maximumFractionDigits = 0
			if let formattedDistance = formatter.string(from: NSNumber(value: meters)) {
				return "\(formattedDistance) m"
			}
		}
		
		return String(format: "%.2f km", kilometers)
	}
}
//
//#Preview {
//    WorkoutListItemView()
//}
