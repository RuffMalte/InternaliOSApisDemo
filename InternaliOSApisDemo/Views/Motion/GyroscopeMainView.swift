//
//  GyroscopeMainView.swift
//  InternaliOSApisDemo
//
//  Created by Malte Ruff on 05.10.24.
//
import SwiftUI
import CoreMotion

struct GyroscopeMainView: View {
	@EnvironmentObject private var motionManager: MotionManager
	
	var body: some View {
		Form {
			if motionManager.isMotionDataAvailable {
				Section {
					sensorDataSection("Gyroscope (rad/s)", data: [
						("X", motionManager.rotationRate.x),
						("Y", motionManager.rotationRate.y),
						("Z", motionManager.rotationRate.z)
					])
				}
				
				Section {
					sensorDataSection("Accelerometer (g)", data: [
						("X", motionManager.acceleration.x),
						("Y", motionManager.acceleration.y),
						("Z", motionManager.acceleration.z)
					])
				}
				
				Section {
					sensorDataSection("Magnetometer (µT)", data: [
						("X", motionManager.magneticField.x),
						("Y", motionManager.magneticField.y),
						("Z", motionManager.magneticField.z)
					])
				}
				
				Section {
					sensorDataSection("Device Attitude (rad)", data: [
						("Roll", motionManager.attitude.roll),
						("Pitch", motionManager.attitude.pitch),
						("Yaw", motionManager.attitude.yaw)
					])
				}
				
				Section {
					HStack {
						Spacer()
						Text("Move your device to see changes")
							.font(.caption)
							.foregroundColor(.secondary)
						Spacer()
					}
				}
				.listRowInsets(EdgeInsets())
				.listRowBackground(Color.clear)
				
			} else {
				Section {
					Text("Waiting for motion data...")
						.font(.headline)
				}
			}
			
			
		}
		.navigationTitle("Device Sensors Demo")
		.onAppear {
			motionManager.startUpdates()
		}
		.onDisappear {
			motionManager.stopUpdates()
		}
		
	}
	
	func sensorDataSection(_ title: String, data: [(String, Double)]) -> some View {
		VStack(alignment: .leading, spacing: 10) {
			Text(title)
				.font(.headline)
			ForEach(data, id: \.0) { item in
				Text("\(item.0): \(item.1, specifier: "%.3f")")
			}
		}
	}
}

