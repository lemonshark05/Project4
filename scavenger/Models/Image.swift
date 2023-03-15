//
//  Image.swift
//  scavenger
//
//  Created by lemonshark on 2023/3/14.
//

import Foundation
import CoreLocation
import UIKit

class Image {
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

    func set(_ image: UIImage, with location: CLLocation) {
        self.image = image
        self.imageLocation = location
    }
}

extension Image {
    static var mockedLists: [Image] {
        return [
            Image(title: "Your favorite local restaruant",
                 description: "Where do you go to have a meal with friends?"),
            Image(title: "Your favorite local cafe",
                 description: "Where do you go to have a cup of coffee with friends?"),
            Image(title: "Your favorite hiking spot",
                 description: "Where do you go to be one with nature?"),
            Image(title: "Your go to brunch plase",
                 description: "Where do you go?")
        ]
    }
}
