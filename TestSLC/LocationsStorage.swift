//
//  LocationsStorage.swift
//  TestSLC
//
//  Created by Maryan on 25.04.2020.
//  Copyright © 2020 Maryan. All rights reserved.
//

import Foundation
import CoreLocation

class LocationsStorage {
    static let shared = LocationsStorage()
    
    private(set) var locations: [Location]
    private let fileManager: FileManager
    private let documentsURL: URL
    
    init() {
        let fileManager = FileManager.default
        documentsURL = try! fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        self.fileManager = fileManager
        
        let jsonDecoder = JSONDecoder()
        
        let locationFilesURLs = try! fileManager.contentsOfDirectory(at: documentsURL,
                                                                     includingPropertiesForKeys: nil)
        locations = locationFilesURLs.compactMap { url -> Location? in
            guard !url.absoluteString.contains(".DS_Store") else {
                return nil
            }
            guard let data = try? Data(contentsOf: url) else {
                return nil
            }
            return try? jsonDecoder.decode(Location.self, from: data)
        }.sorted(by: { $0.date < $1.date })
    }
    
    func saveLocationOnDisk(_ location: Location) {
        let encoder = JSONEncoder()
        let timestamp = location.date.timeIntervalSince1970
        let fileURL = documentsURL.appendingPathComponent("\(timestamp)")
        
        let data = try! encoder.encode(location)
        try! data.write(to: fileURL)
        
        locations.append(location)
        
        NotificationCenter.default.post(name: .newLocationSaved, object: self, userInfo: ["location": location])
    }
    
    func saveCLLocationToDisk(_ clLocation: CLLocation) {
        let currentDate = Date()
        let location = Location(clLocation.coordinate, date: currentDate, descriptionString: "")
        self.saveLocationOnDisk(location)
    }
    
    func cleanFolder() {
        do {
            let documentsPath = documentsURL.path
            let fileNames = try fileManager.contentsOfDirectory(atPath: "\(documentsPath)")
            print("all files in cache: \(fileNames)")
            for fileName in fileNames {
                let filePathName = "\(documentsPath)/\(fileName)"
                try fileManager.removeItem(atPath: filePathName)
            }
            
            let files = try fileManager.contentsOfDirectory(atPath: "\(documentsPath)")
            print("all files in cache after deleting images: \(files)")
            locations.removeAll()
        } catch {
            print("Could not clear temp folder: \(error)")
        }
    }
}

extension Notification.Name {
    static let newLocationSaved = Notification.Name("newLocationSaved")
}

