//
//  CurrentHeartRateView.swift
//  InternaliOSApisDemo
//
//  Created by Malte Ruff on 02.10.24.
//

import SwiftUI

struct CurrentHeartRateView: View {
	@EnvironmentObject private var healthKitManager: HealthKitManager
	@State private var timeRemaining: Int = 10
	@State private var timer: Timer?
	
	var body: some View {
		Section {
			HStack {
				Text(Int(healthKitManager.currentHeartRate).description)
				Spacer()
				Text("\(timeRemaining)s")
					.foregroundColor(.secondary)
					.font(.system(.caption, design: .monospaced, weight: .semibold))
			}
		} header: {
			HStack {
				Label("Current Heart Rate", systemImage: "heart.fill")
				Spacer()
				Button {
					healthKitManager.fetchLastHeartRate()
					resetTimer()
				} label: {
					Image(systemName: "arrow.counterclockwise")
				}
			}
		}
		.onAppear {
			healthKitManager.fetchLastHeartRate()
			startTimer()
		}
		.onDisappear {
			stopTimer()
		}
	}
	
	private func startTimer() {
		timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
			if timeRemaining > 0 {
				timeRemaining -= 1
			} else {
				healthKitManager.fetchLastHeartRate()
				resetTimer()
			}
		}
	}
	
	private func stopTimer() {
		timer?.invalidate()
		timer = nil
	}
	
	private func resetTimer() {
		timeRemaining = 10
	}
}

#Preview {
    CurrentHeartRateView()
}
