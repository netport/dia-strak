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
    var timestamp: NSDate

    init(location: CLLocation, timestamp: NSDate = NSDate()) {
        self.location = location
        self.timestamp = timestamp
    }

    // MARK: - NSCoding

    required convenience init?(coder aDecoder: NSCoder) {
        guard let location = aDecoder.decodeObjectForKey("location") as? CLLocation,
            let timestamp = aDecoder.decodeObjectForKey("timestamp") as? NSDate
            else { return nil }

        self.init(location: location, timestamp: timestamp)
    }

    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(location, forKey: "location")
        aCoder.encodeObject(timestamp, forKey: "timestamp")
    }
}
