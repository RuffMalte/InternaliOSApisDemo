//
//  CalendarListView.swift
//  InternaliOSApisDemo
//
//  Created by Malte Ruff on 03.10.24.
//

import SwiftUI

struct CalendarListView: View {
	@EnvironmentObject private var calendarManager: CalendarManager

    var body: some View {
		Section {
			List(calendarManager.events, id: \.eventIdentifier) { event in
				CalendarListCellView(event: event)
			}
		}
    }
}

#Preview {
    CalendarListView()
}
