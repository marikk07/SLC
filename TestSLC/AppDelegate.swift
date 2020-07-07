//
//  AppDelegate.swift
//  TestSLC
//
//  Created by Maryan on 25.04.2020.
//  Copyright © 2020 Maryan. All rights reserved.
//

import UIKit
import CoreLocation
import UserNotifications
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    let locationManager = CLLocationManager()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in}
        // When there is a significant changes of the location,
        // The key UIApplicationLaunchOptionsLocationKey will be returned from didFinishLaunchingWithOptions
        // When the app is receiving the key, it must reinitiate the locationManager and get
        // the latest location updates

        // This UIApplicationLaunchOptionsLocationKey key enables the location update even when
        // the app has been killed/terminated (Not in th background) by iOS or the user.
        
        print("didFinishLaunchingWithOptions!")
        
        if let keys = launchOptions?.keys {
            if keys.contains(.location)  {
                //You have a location when app is in killed/ not running state
                //let location = keys[UIApplication.LaunchOptionsKey.location] as! String
                newVisitReceived(loc: CLLocation(latitude: 0, longitude: 0), descr: "SLC")
                
                self.startMonitoringSLC()
            }
        } else {
            self.startMonitoringLocation()
        }
        
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        self.restartMonitoringLocation()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        self.startMonitoringLocation()
    }
    
    func startMonitoringLocation() {
        locationManager.stopMonitoringSignificantLocationChanges()
        locationManager.stopUpdatingLocation()
        
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.delegate = self
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.activityType = .other
        
        locationManager.startUpdatingLocation()
        locationManager.startMonitoringSignificantLocationChanges()
    }
    
    func startMonitoringSLC(){
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.delegate = self
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.activityType = .other
               
        locationManager.startMonitoringSignificantLocationChanges()
    }
    
    func restartMonitoringLocation() {
        locationManager.stopMonitoringSignificantLocationChanges()
        locationManager.stopUpdatingLocation()
          
        locationManager.requestAlwaysAuthorization()
        locationManager.startMonitoringSignificantLocationChanges()
        locationManager.startUpdatingLocation()
      }
    
    func newVisitReceived(loc : CLLocation, descr: String) {
          let location = Location(loc.coordinate, date: Date(), descriptionString: descr)
      LocationsStorage.shared.saveLocationOnDisk(location)
      
      let content = UNMutableNotificationContent()
      content.title = "New Journal entry 📌"
        content.body = location.description
      content.sound = UNNotificationSound.default
      
      let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
      let request = UNNotificationRequest(identifier: location.dateString, content: content, trigger: trigger)
      UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
}

extension AppDelegate: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Get location description
        guard let loc = locations.last else {
            return
        }
        if UIApplication.shared.applicationState == .background {
            newVisitReceived(loc: loc, descr: "Background")
        } else  if UIApplication.shared.applicationState == .inactive {
            newVisitReceived(loc: loc, descr: "Inactive")
        } else {
//            newVisitReceived(loc: loc, descr: "Active")
            
        }
    }
}
