//
//  VehicleStatusViewController.swift
//  SmartDeviceLink-Example-Swift
//
//  Created by Mrunal Puram on 11/4/18.
//  Copyright © 2018 smartdevicelink. All rights reserved.
//

import UIKit

class VehicleStatusViewController: UIViewController {

    @IBOutlet weak var fuelLevelLabel: UILabel!
    @IBOutlet weak var fuelRangeLabel: UILabel!
    @IBOutlet weak var tirePressureLabel: UILabel!
    @IBOutlet weak var externalTemperatureLabel: UILabel!
    @IBOutlet weak var engineOilLifeLabel: UILabel!
    @IBOutlet weak var odometerOutlet: UILabel!
    @IBOutlet weak var vinLabel: UILabel!
    @IBOutlet weak var LFLabel: UILabel!
    @IBOutlet weak var RFLabel: UILabel!
    @IBOutlet weak var LRLabel: UILabel!
    @IBOutlet weak var RRLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.setNeedsDisplay()
        fuelLevelLabel.text = "Fuel Level: " + String(ProxyManager.sharedManager.fuelLevel) + "%"
        fuelRangeLabel.text = "Fuel Range: " + String(ProxyManager.sharedManager.fuelRange) + " km"
        LFLabel.text = "LF: " + String(ProxyManager.sharedManager.tirePressureLF)
        RFLabel.text = "RF: " + String(ProxyManager.sharedManager.tirePressureRF)
        LRLabel.text = "LR: " + String(ProxyManager.sharedManager.tirePressureLR)
        RRLabel.text = "RR: " + String(ProxyManager.sharedManager.tirePressureRR)
        externalTemperatureLabel.text = "External Temp: " + String(ProxyManager.sharedManager.externalTemperature) + " C"
        engineOilLifeLabel.text = "Engine Oil Life: " + String(ProxyManager.sharedManager.engineOilLife) + "%"
        odometerOutlet.text = "Odometer: " + String(ProxyManager.sharedManager.odometer) + " km"
        
        
        
//        vinLabel.text = "VIN: " + String(VIN)
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
