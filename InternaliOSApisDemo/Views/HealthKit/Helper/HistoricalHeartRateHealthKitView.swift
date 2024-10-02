//
//  HistoricalHeartRateHealthKitView.swift
//  InternaliOSApisDemo
//
//  Created by Malte Ruff on 02.10.24.
//

import SwiftUI
import Charts

struct HistoricalHeartRateHealthKitView: View {
	
	@EnvironmentObject private var healthKitManager: HealthKitManager
	@State private var selectedHistoricalDataPeriod: HistoricalDataPeriod = .day
	@State private var heartRateData: [(Date, Double)] = []
	
	var body: some View {
		Section {
			VStack {
				Picker(selection: $selectedHistoricalDataPeriod) {
					ForEach(HistoricalDataPeriod.allCases, id: \.self) { period in
						Text(period.shortName)
							.tag(period)
					}
				} label: { }
					.pickerStyle(.segmented)
					.padding()
				
				Chart(heartRateData, id: \.0) { item in
					LineMark(
						x: .value("Time", item.0),
						y: .value("Heart Rate", item.1)
					)
					.interpolationMethod(.catmullRom)
					.lineStyle(StrokeStyle(lineWidth: 3))
					.foregroundStyle(.red)
				}
				.chartXAxis {
					AxisMarks(values: .automatic(desiredCount: 5)) { value in
						AxisGridLine()
						AxisValueLabel(format: dateFormatForSelectedPeriod)
					}
				}
				.chartYAxis {
					AxisMarks(position: .leading)
				}
				.frame(height: 300)
				.padding(2)
			}
			.onChange(of: selectedHistoricalDataPeriod) {
				fetchHeartRateData()
			}
			.onAppear {
				fetchHeartRateData()
			}
		} header: {
			Label("Historical Heart Rate", systemImage: "chart.bar.fill")
		}
	}
	
	private func fetchHeartRateData() {
		healthKitManager.fetchHistoricalHeartRate(for: selectedHistoricalDataPeriod) { data in
			self.heartRateData = data
		}
	}
	private var dateFormatForSelectedPeriod: Date.FormatStyle {
		switch selectedHistoricalDataPeriod {
		case .day:
			return .dateTime.hour()
		case .week:
			return .dateTime.weekday(.abbreviated)
		case .month:
			return .dateTime.day()
		case .sixMonths:
			return .dateTime.month(.abbreviated)
		case .year:
			return .dateTime.month()
		}
	}
}

#Preview {
    HistoricalHeartRateHealthKitView()
}
