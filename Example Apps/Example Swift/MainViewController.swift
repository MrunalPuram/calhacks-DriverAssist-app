//
//  MainViewController.swift
//  SmartDeviceLink-iOS
//
//  Created by Mrunal Puram on 11/3/18.
//  Copyright © 2018 smartdevicelink. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    var count: Int = 0
//    var proxy:ProxyManager
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ProxyManager.sharedManager.subscribe()
        if ProxyManager.sharedManager.fuelLevel < 25 {
            let alert = UIAlertController(title: "Running low on fuel", message: "Running low on fuel", preferredStyle: .alert)
            alert.message = "You have \(ProxyManager.sharedManager.fuelLevel)% fuel left"
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            self.present(alert, animated: true)
        }
        // Do any additional setup after loading the view.
    }
    
    @IBAction func goToDriverFeedback(_ sender: Any) {
        performSegue(withIdentifier: "toDriverFeedback", sender: sender)
    }
    @IBAction func goToVehicleStatus(_ sender: Any) {
        performSegue(withIdentifier: "toVehicleStatus", sender: sender)
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if let dest = segue.destination as? DrivingFeedbackViewController {
//            dest.proxy = self.proxy
//        }
//    }
    
    @IBAction func updateLabel(_ sender: Any) {
//        ProxyManager.sharedManager.getData()
//        printVals()
        print(ProxyManager.sharedManager.accelerationArray)
        self.count += 1
    }
    
    func printVals() {
        for index in 1...20 {
            ProxyManager.sharedManager.getData()
            
        }
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
