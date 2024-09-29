//
//  CalendarView.swift
//  InternaliOSApisDemo
//
//  Created by Malte Ruff on 26.09.24.
//
import SwiftUI

struct CalendarView: View {
    @StateObject private var viewModel = CalendarViewModel()
    
    var body: some View {
        List(viewModel.events, id: \.eventIdentifier) { event in
            VStack(alignment: .leading) {
                Text(event.title)
                    .font(.headline)
                Text("\(event.startDate, style: .date) - \(event.endDate, style: .date)")
                    .font(.subheadline)
				
                if let location = event.location, !location.isEmpty {
                    Text(location)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("Calendar Events")
        .onAppear {
            viewModel.fetchEvents()
        }
    }
}

#Preview {
	CalendarView()
}
