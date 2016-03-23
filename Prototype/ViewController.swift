//
//  ViewController.swift
//  Prototype
//
//  Created by Andrey on 07/03/16.
//  Copyright © 2016 Tap Away. All rights reserved.
//

import UIKit
import CoreLocation

final class ViewController: UIViewController {

    // MARK: - String keys for UserDefaults and file name
    let locationDefaultsKey = "locationTracking"
    let recordStorePath = "locationRecords"

    let locationManager = CLLocationManager()

    lazy var userDefaults: NSUserDefaults = {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.registerDefaults([self.locationDefaultsKey : false])
        return defaults
    }()

    var shouldTrackLocation: Bool {
        get {
            return userDefaults.boolForKey(locationDefaultsKey)
        }
        set {
            if newValue { startTracking() }
            else { stopTracking() }
            userDefaults.setBool(newValue, forKey: locationDefaultsKey)
        }
    }

    var records = [Record]()

    @IBOutlet weak var locationSwitch: UISwitch!

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        locationSwitch.on = shouldTrackLocation

        loadRecords()

        configureLocationManager()
        configureNotifications()
    }

    @IBAction func trackingChoiceChanged(sender: UISwitch) {
        shouldTrackLocation = sender.on
    }

    // MARK: - Loading & saving records

    func loadRecords() {
        guard let loadedObject = Storage.load(recordStorePath) as? [Record]
            else { debugPrint("Failed to load records"); return }
        records = loadedObject
    }

    func saveRecords() {
        Storage.save(object: records, recordStorePath) { error in
            guard let error = error else { return }
            debugPrint("Failed to save records: \(error)")
        }
    }

    // Subscribe to app state change notifications, so we can stop/start location services.
    func configureNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.applicationWillResignActive), name: UIApplicationWillResignActiveNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.applicationWillEnterForeground), name: UIApplicationWillEnterForegroundNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.applicationWillTerminate), name: UIApplicationWillTerminateNotification, object: nil)
    }

    func configureLocationManager() {
        locationManager.delegate = self
        locationManager.distanceFilter = kCLLocationAccuracyHundredMeters
        locationManager.desiredAccuracy = kCLLocationAccuracyBest

        let distanceTraveled: CLLocationDistance = 500;
        let timeout: NSTimeInterval = 5*60;

//        locationManager.allowDeferredLocationUpdatesUntilTraveled(distanceTraveled, timeout: timeout)
    }

    // MARK: - App state change

    func applicationWillResignActive() {
        saveRecords()
        switchTrackingToBackground()
    }

    func applicationWillEnterForeground() {
        switchTrackingToBackground()
    }

    func applicationWillTerminate() {
        saveRecords()
    }

    // MARK: - Location Tracking

    func startTracking() {
        let authorizationStatus = CLLocationManager.authorizationStatus()
        if authorizationStatus == .NotDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else if authorizationStatus == .Denied {
            // If authorization has been denied previously, inform the user.
            let alert = UIAlertController(title: "Location services", message: "Location services were previously denied. Please enable location services for this app in settings.", preferredStyle: .Alert)
            let defaultAction = UIAlertAction(title: "Dismiss", style: .Default, handler: nil)
            alert.addAction(defaultAction)

            presentViewController(alert, animated: true, completion: nil)
        } else {
            // We do have authorization.
            // Start the standard location service.
            locationManager.startUpdatingLocation()
        }
    }

    func stopTracking() {
        locationManager.stopUpdatingLocation()
    }

    // When our app is interrupted, stop the standard location service,
    // and start significant location change service, if available.
    func switchTrackingToBackground() {
        guard CLLocationManager.significantLocationChangeMonitoringAvailable()
            else { debugPrint("Significant location change monitoring is not available."); return }
        locationManager.stopUpdatingLocation()
        locationManager.startMonitoringSignificantLocationChanges()
    }

    // Stop the significant location change service, if available,
    // and start the standard location service.
    func switchTrackingToForeground() {
        guard CLLocationManager.significantLocationChangeMonitoringAvailable()
            else { debugPrint("Significant location change monitoring is not available."); return }
        locationManager.stopMonitoringSignificantLocationChanges()
        locationManager.startUpdatingLocation()
    }

}

// MARK: - CLLocationManagerDelegate
extension ViewController: CLLocationManagerDelegate {

    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        guard status == .AuthorizedAlways || status == .AuthorizedWhenInUse else { return }
        locationManager.startUpdatingLocation()
    }

    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        debugPrint("Location didFailWithError: \(error)")
    }

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        records += locations.map { Record(location: $0) }
    }
}

extension ViewController {

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }

}

