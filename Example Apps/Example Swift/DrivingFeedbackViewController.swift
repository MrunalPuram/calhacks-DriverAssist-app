//
//  DrivingFeedbackViewController.swift
//  SmartDeviceLink-iOS
//
//  Created by Mrunal Puram on 11/4/18.
//  Copyright © 2018 smartdevicelink. All rights reserved.
//

import UIKit

class DrivingFeedbackViewController: UIViewController {
    

    @IBOutlet weak var maxSpeedLabel: UILabel!
    @IBOutlet weak var speedDurationLabel: UILabel!
    @IBOutlet weak var aggressiveDrivingCountLabel: UILabel!
    @IBOutlet weak var turningMistakesLabel: UILabel!
    @IBOutlet weak var rollingStopsLabel: UILabel!
    @IBOutlet weak var safetyIndexLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.setNeedsDisplay()
        maxSpeedLabel.text = "Max Speed (km/h): " + String(ProxyManager.sharedManager.maxSpeed)
        speedDurationLabel.text = "Speeding Duration (seconds): " + String(ProxyManager.sharedManager.speedDuration)
        aggressiveDrivingCountLabel.text = "Aggressive Driving Count: " + String(ProxyManager.sharedManager.aggressiveDrivingCount)
        turningMistakesLabel.text = "Turning Mistakes: " + String(ProxyManager.sharedManager.turningMistakesCount)
        rollingStopsLabel.text = "Rolling Stops: " + String(ProxyManager.sharedManager.rollingStops)
        
        let safetyIndex = max(0, 100 - (max(ProxyManager.sharedManager.maxSpeed - 90, 0) + ProxyManager.sharedManager.speedDuration/60 + ProxyManager.sharedManager.aggressiveDrivingCount*2 + ProxyManager.sharedManager.turningMistakesCount + ProxyManager.sharedManager.rollingStops))
        safetyIndexLabel.text = "Safety Index: " + String(safetyIndex)
        if safetyIndex < 30 {
            safetyIndexLabel.textColor = UIColor.red
        } else if safetyIndex < 60 {
            safetyIndexLabel.textColor = UIColor.orange
        } else {
            safetyIndexLabel.textColor = UIColor.green
        }
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
