//
//  HealthKitDemoView.swift
//  InternaliOSApisDemo
//
//  Created by Malte Ruff on 01.10.24.
//
import SwiftUI
import HealthKit

struct HealthKitDemoView: View {
	@EnvironmentObject private var healthKitManager: HealthKitManager
    
    var body: some View {
		Form {
			
			RequestHealthKitPermissionView()
			
			Section {
				HStack {
					ActivityLabelView(moveCalories: $healthKitManager.moveCalories, systemImage: "arrow.forward", color: .red, unit: "KCAL")
					
					Spacer()
					
					ActivityLabelView(moveCalories: $healthKitManager.exerciseMinutes, systemImage: "arrow.counterclockwise", color: .green, unit: "MIN")
					
					Spacer()
					
					ActivityLabelView(moveCalories: $healthKitManager.standHours, systemImage: "arrow.up", color: .blue, unit: "HRS")
					
				}
				.font(.system(.subheadline, design: .monospaced, weight: .bold))
			} header: {
				Label("Daily Activity", systemImage: "flame.fill")
			}
			
			
			CurrentHeartRateView()
			
			HistoricalHeartRateHealthKitView()
			
		}
    }
}


