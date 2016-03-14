//
//  Record.swift
//  Prototype
//
//  Created by Andrey on 10/03/16.
//  Copyright © 2016 Tap Away. All rights reserved.
//

import Foundation
import CoreLocation

final class Record: NSObject, NSCoding {
    var location: CLLocation

    init(location: CLLocation) {
        self.location = location
    }

    // MARK: - NSCoding

    required convenience init?(coder aDecoder: NSCoder) {
        guard let location = aDecoder.decodeObjectForKey("location") as? CLLocation
            else { return nil }
        self.init(location: location)
    }

    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(location, forKey: "location")
    }
}
