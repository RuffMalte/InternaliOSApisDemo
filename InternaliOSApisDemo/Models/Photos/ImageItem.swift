//
//  ImageItem.swift
//  InternaliOSApisDemo
//
//  Created by Malte Ruff on 02.10.24.
//


import SwiftUI
import SwiftData

@Model
class ImageItem {
    var imageData: Data
    @Attribute(.externalStorage) var largeImageData: Data?
    var date: Date
    
    init(imageData: Data, date: Date = Date()) {
        self.imageData = imageData
        self.date = date
    }
}