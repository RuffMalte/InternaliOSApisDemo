//
//  MotionManager.swift
//  InternaliOSApisDemo
//
//  Created by Malte Ruff on 05.10.24.
//
import SwiftUI
import CoreMotion

class MotionManager: ObservableObject {
	private let motionManager = CMMotionManager()
	
	@Published var rotationRate = CMRotationRate()
	@Published var acceleration = CMAcceleration()
	@Published var magneticField = CMMagneticField()
	@Published var attitude = CMAttitude()
	@Published var isMotionDataAvailable = false
	
	init() {
		motionManager.deviceMotionUpdateInterval = 1.0 / 60.0 // 60 Hz update frequency
	}
	
	func startUpdates() {
		guard motionManager.isDeviceMotionAvailable else {
			print("Device motion is not available on this device")
			return
		}
		
		motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
			guard let self = self, let motion = motion, error == nil else {
				print("Error: \(error?.localizedDescription ?? "Unknown error")")
				return
			}
			
			DispatchQueue.main.async {
				self.rotationRate = motion.rotationRate
				self.acceleration = motion.userAcceleration
				self.magneticField = motion.magneticField.field
				self.attitude = motion.attitude
				self.isMotionDataAvailable = true
			}
		}
		
		// Ensure UI updates after a short delay
		DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
			self.isMotionDataAvailable = true
		}
	}
	
	func stopUpdates() {
		motionManager.stopDeviceMotionUpdates()
		isMotionDataAvailable = false
	}
}
