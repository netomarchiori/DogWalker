//
//  UserAnnotation.swift
//  Dog Walker
//
//  Created by Thiago T Nogueira on 16/03/16.
//  Copyright © 2016 FIAP. All rights reserved.
//

import UIKit
import MapKit

class UserAnnotation: NSObject, MKAnnotation {

    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var image: String?
    var userUuid: String?

    init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String, image: String, userUuid: String) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.image = image
        self.userUuid = userUuid
    }
}
