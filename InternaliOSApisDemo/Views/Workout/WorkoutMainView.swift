//
//  WorkoutMainView.swift
//  InternaliOSApisDemo
//
//  Created by Malte Ruff on 02.10.24.
//

import SwiftUI
import HealthKit

struct WorkoutMainView: View {
	@EnvironmentObject var workoutManager: WorkoutManager
	@State private var workoutIcons: [UUID: UIImage] = [:]
	
	@Namespace private var workoutTransition

	var body: some View {
		Form {
			
			Section {
				Button {
					workoutManager.requestAuthorization()
				} label: {
					Label("Request HealthKit Permission", systemImage: "figure.run")
				}
			} header: {
				if workoutManager.isAuthorized {
					Text("Authorized")
				} else {
					Text("Not Authorized")
				}
			}
			
			Section {
				ForEach(workoutManager.workouts, id: \.uuid) { workout in
					WorkoutListItemView(workout: workout, workoutIcons: $workoutIcons)
				}
			} header: {
				Label("Workouts", systemImage: "figure.run")
			}
			
			.navigationTitle("Workouts")
			.navigationBarTitleDisplayMode(.inline)
		}
	}

}
#Preview {
    WorkoutMainView()
}
