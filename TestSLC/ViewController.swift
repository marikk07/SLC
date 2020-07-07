//
//  ViewController.swift
//  TestSLC
//
//  Created by Maryan on 25.04.2020.
//  Copyright © 2020 Maryan. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
      super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
      NotificationCenter.default.addObserver(
        self,
        selector: #selector(newLocationAdded(_:)),
        name: .newLocationSaved,
        object: nil)
    }
    
    @objc func newLocationAdded(_ notification: Notification) {
      tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return LocationsStorage.shared.locations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceCell", for: indexPath)
      let location = LocationsStorage.shared.locations[indexPath.row]
      cell.textLabel?.numberOfLines = 3
      cell.textLabel?.text = location.description
      cell.detailTextLabel?.text = "Lat: \(location.coordinates.latitude) " + "Lon: \(location.coordinates.longitude) " + location.dateString
      return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
      return 110
    }

    @IBAction func resetData(_ sender: Any) {
        LocationsStorage.shared.cleanFolder()
        tableView.reloadData()
    }

}

