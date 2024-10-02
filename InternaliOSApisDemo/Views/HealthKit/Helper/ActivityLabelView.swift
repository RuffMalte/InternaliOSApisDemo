//
//  ActivityLabelView.swift
//  InternaliOSApisDemo
//
//  Created by Malte Ruff on 02.10.24.
//
import SwiftUI

struct ActivityLabelView: View {
	
	@Binding var moveCalories: Double
	var systemImage: String
	var color: Color
	var unit: String
	
	var body: some View {
		HStack(alignment: .firstTextBaseline) {
			HStack {
				Image(systemName: systemImage)
				Text(Int(moveCalories).description)
			}
			.foregroundStyle(color)
			.font(.system(.headline, design: .monospaced, weight: .bold))
			
			Text(unit)
				.font(.caption2)
				.foregroundStyle(.secondary)
		}
	}
}
