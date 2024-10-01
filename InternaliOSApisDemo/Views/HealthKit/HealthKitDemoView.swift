//
//  HealthKitDemoView.swift
//  InternaliOSApisDemo
//
//  Created by Malte Ruff on 01.10.24.
//
import SwiftUI
import HealthKit

struct HealthKitDemoView: View {
    @StateObject private var healthKitManager = HealthKitManager()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("HealthKit Demo")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            if healthKitManager.isAuthorized {
                dailyActivityView
            } else {
                requestPermissionView
            }
        }
        .padding()
    }
    
    private var requestPermissionView: some View {
        VStack {
            Text("HealthKit access is required")
                .font(.headline)
            
            Button("Request Permission") {
                healthKitManager.requestAuthorization()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
    }
    
    private var dailyActivityView: some View {
        VStack(alignment: .leading, spacing: 15) {
			Text("Daily Activity")
				.font(.title2)
				.fontWeight(.semibold)
			
			HStack {
				ActivityRingView(progress: healthKitManager.moveProgress, color: .red)
				ActivityRingView(progress: healthKitManager.exerciseProgress, color: .green)
				ActivityRingView(progress: Double(healthKitManager.standHours), color: .blue)
			}
			.frame(height: 100)
			
			Group {
				Text("Move: \(Int(healthKitManager.moveCalories)) / 500 kcal")
				Text("Exercise: \(Int(healthKitManager.exerciseMinutes)) / 30 min")
				Text("Stand: \(Int(healthKitManager.standHours)) / 12 hours")
			}
			.font(.subheadline)
        }
    }
}

struct ActivityRingView: View {
	let progress: Double
	let color: Color
	
	var body: some View {
		ZStack {
			Circle()
				.stroke(color.opacity(0.3), lineWidth: 10)
			Circle()
				.trim(from: 0, to: CGFloat(min(progress, 1.0)))
				.stroke(color, style: StrokeStyle(lineWidth: 10, lineCap: .round))
				.rotationEffect(.degrees(-90))
				.animation(.snappy, value: progress)
		}
	}
}
