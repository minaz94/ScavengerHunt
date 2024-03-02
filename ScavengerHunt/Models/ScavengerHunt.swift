//
//  ScavengerHunt.swift
//  ScavengerHunt
//
//  Created by Mina on 3/1/24.
//

import UIKit
import MapKit

struct ScavengerHunt {
    
    let title: String
    let description: String
    var image: UIImage?
    var imageLocation: CLLocation?
    
    var isComplete: Bool {
        image != nil
    }
    
    init(title: String, description: String) {
        self.title = title
        self.description = description
    }
    
    mutating func set(_ image: UIImage, with location: CLLocation) {
        self.image = image
        self.imageLocation = location
    }
    
}
