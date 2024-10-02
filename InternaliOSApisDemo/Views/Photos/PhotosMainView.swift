//
//  PhotosMainView.swift
//  InternaliOSApisDemo
//
//  Created by Malte Ruff on 02.10.24.
//

import SwiftUI
import PhotosUI
import SwiftData

struct PhotosMainView: View {
	@Environment(\.modelContext) private var modelContext
	@Query private var savedImages: [ImageItem]
	
	@State private var selectedItems: [PhotosPickerItem] = []
	
	var body: some View {
		NavigationStack {
			Form {
				TabView {
					ForEach(savedImages) { imageItem in
						if let uiImage = UIImage(data: imageItem.imageData) {
							GeometryReader { geometry in
								Image(uiImage: uiImage)
									.resizable()
									.scaledToFill()
									.frame(width: geometry.size.width, height: geometry.size.height)
									.clipped()
									.overlay {
										VStack {
											HStack {
												Button(role: .destructive) {
													deleteImage(imageItem)
												} label: {
													Image(systemName: "trash")
												}
												.buttonStyle(.borderedProminent)
												.padding()
												Spacer()
											}
											Spacer()
										}
									}
							}
							
						}
					}
				}
				.listRowInsets(EdgeInsets())
				.frame(height: 500)
				.tabViewStyle(.page)
				.indexViewStyle(.page(backgroundDisplayMode: .always))

				
				Section {
					PhotosPicker(selection: $selectedItems, matching: .images, photoLibrary: .shared()) {
						HStack {
							Spacer()
							Label("Select photos", systemImage: "photo.on.rectangle.angled")
								.padding()
								.foregroundStyle(.white)
								.font(.system(.headline, design: .rounded, weight: .bold))
							Spacer()
						}
					}
				}
				.listRowInsets(EdgeInsets())
				.background(.tint)
				
				
			}
			.navigationTitle("Photo Gallery")
		}
		.onChange(of: selectedItems) {
			Task {
				for item in selectedItems {
					if let data = try? await item.loadTransferable(type: Data.self) {
						let imageItem = ImageItem(imageData: data)
						modelContext.insert(imageItem)
					}
				}
				try? modelContext.save()
				selectedItems.removeAll()
			}
		}
	}
	
	private func deleteImage(_ image: ImageItem) {
		modelContext.delete(image)
		try? modelContext.save()
	}
}

#Preview {
    PhotosMainView()
}
