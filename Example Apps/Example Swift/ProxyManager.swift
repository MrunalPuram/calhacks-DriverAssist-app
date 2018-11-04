//
//  ProxyManager.swift
//  SmartDeviceLink-ExampleSwift
//
//  Copyright © 2017 smartdevicelink. All rights reserved.
//

import UIKit
import SmartDeviceLink
import SmartDeviceLinkSwift

enum ProxyTransportType {
    case tcp
    case iap
}

enum ProxyState {
    case stopped
    case searching
    case connected
}

class ProxyManager: NSObject {
    fileprivate var sdlManager: SDLManager!
    fileprivate var buttonManager: ButtonManager!
    fileprivate var vehicleDataManager: VehicleDataManager!
    fileprivate var performInteractionManager: PerformInteractionManager!
    fileprivate var firstHMILevelState: SDLHMILevel
    weak var delegate: ProxyManagerDelegate?
    
    
    var subscribeVehicleData: SDLSubscribeVehicleData
    var SDLspeed: NSNumber
    var prevSpeed: NSNumber
    var SDLfuelLevel: NSNumber
    var SDLgps: SDLGPSData?
    var accelerationArray: [Int] = []
    var maxSpeed: Int = 0
    var speedDuration: Int = 0
    var aggressiveDrivingCount: Int = 0
    var turningMistakesCount: Int = 0
    var rollingStops: Int = 0
    var speedLimit: Int = 96 // 96km/hr is 60 mph
    
    var fuelLevel: Int = 100
    var fuelRange: Int = 100
//    var tirePressureFL: Double = 100
//    var tirePressureFR: Double = 100
//    var tirePressureBL: Double = 100
//    var tirePressureBR: Double = 100
    var tirePressureLF: String = ""
    var tirePressureRF: String = ""
    var tirePressureLR: String = ""
    var tirePressureRR: String = ""
    var externalTemperature: Int = 0
    var engineOilLife: Int = 100
    var odometer: Int = 0
    var vin: String = ""
    

    // Singleton
    static let sharedManager = ProxyManager()
    private override init() {
        firstHMILevelState = .none
        self.subscribeVehicleData = SDLSubscribeVehicleData()
        self.SDLspeed = -1
        self.prevSpeed = 0
        self.SDLfuelLevel = -1
        super.init()
    }
}

// MARK: - SDL Configuration

extension ProxyManager {
    
    func getData() -> Int {
        print("Hi")
        let getVehicleData = SDLGetVehicleData()
        getVehicleData.prndl = true
        getVehicleData.fuelLevel = true
        getVehicleData.speed = true
        getVehicleData.accPedalPosition = true
        getVehicleData.driverBraking = true
        getVehicleData.gps = true
        getVehicleData.turnSignal = true
        getVehicleData.steeringWheelAngle = true
        sdlManager?.send(request: getVehicleData, responseHandler: { (request, response, error) in
            guard let response = response as? SDLGetVehicleDataResponse else { return }
            if let error = error {
                print("Encountered Error sending GetVehicleData: \(error)")
                return
            }

            
            guard response.success.boolValue == true else {
                if response.resultCode == .rejected {
                    print("GetVehicleData was rejected. Are you in an appropriate HMI?")
                } else if response.resultCode == .disallowed {
                    print("Your app is not allowed to use GetVehicleData")
                } else {
                    print("Some unknown error has occured!")
                }
                return
            }
            
//            guard let prndl = response.prndl else { return }
//            guard let fuelLevel = response.fuelLevel else { return }
            guard let speed = response.speed else { return }
//            guard let accPedalPosition = response.accPedalPosition else { return }
//            guard let driverBraking = response.driverBraking else { return }
//            guard let turnSignal = response.turnSignal else { return }
//            let turnSignal = response.turnSignal
            guard let gps = response.gps else { return }
            print("Hello World we want data")
//            print(prndl)
//            print("Fuellevel \(fuelLevel)")
            print(response)
//            print("Speed \(speed)")
//            print("accPedalPosition \(accPedalPosition)")
//            print("driverBraking \(driverBraking)")
//            print("turnSignal \(turnSignal)")
            
        })
        return 5
    }
    
//    func getValue(key:String) -> Int {
//        print("Calling Get Value")
//        let getVehicleData = SDLGetVehicleData()
//        getVehicleData.key = true
//
//        sdlManager?.send(request: getVehicleData, responseHandler: { (request, response, error) in
//            guard let response = response as? SDLGetVehicleDataResponse else { return }
//
//            if let error = error {
//                print("Encountered Error sending GetVehicleData: \(error)")
//                return
//            }
//
//
//            guard response.success.boolValue == true else {
//                if response.resultCode == .rejected {
//                    print("GetVehicleData was rejected. Are you in an appropriate HMI?")
//                } else if response.resultCode == .disallowed {
//                    print("Your app is not allowed to use GetVehicleData")
//                } else {
//                    print("Some unknown error has occured!")
//                }
//                return
//            }
//
//            guard let prndl = response.prndl else { return }
//            guard let fuelLevel = response.fuelLevel else { return }
//            guard let speed = response.speed else { return }
//            guard let accPedalPosition = response.accPedalPosition else { return }
//            guard let driverBraking = response.driverBraking else { return }
//            print("Hello World we want data")
//            print(prndl)
//            print(fuelLevel)
//            print(speed)
//            print(accPedalPosition)
//            print(driverBraking)
//
//        })
//        return 5
//    }
    
//    func subscribe() {
//        NotificationCenter.default.addObserver(self, selector: #selector(vehicleDataAvailable(_:)), name: .SDLDidReceiveVehicleData, object: nil)
//
//        let subscribeVehicleData = SDLSubscribeVehicleData()
//        subscribeVehicleData.prndl = true
//
//        sdlManager.send(request: subscribeVehicleData) { (request, response, error) in
//            guard let response = response as? SDLSubscribeVehicleDataResponse else { return }
//
//            guard response.success.boolValue == true else {
//                if response.resultCode == .disallowed {
//                    // Not allowed to register for this vehicle data.
//                } else if response.resultCode == .userDisallowed {
//                    // User disabled the ability to give you this vehicle data
//                } else if response.resultCode == .ignored {
//                    if let prndlData = response.prndl {
//                        if prndlData.resultCode == .dataAlreadySubscribed {
//                            // You have access to this data item, and you are already subscribed to this item so we are ignoring.
//                        } else if prndlData.resultCode == .vehicleDataNotAvailable {
//                            // You have access to this data item, but the vehicle you are connected to does not provide it.
//                        } else {
//                            print("Unknown reason for being ignored: \(prndlData.resultCode)")
//                        }
//                    } else {
//                        print("Unknown reason for being ignored: \(String(describing: response.info))")
//                    }
//                } else if let error = error {
//                    print("Encountered Error sending SubscribeVehicleData: \(error)")
//                }
//                return
//            }
//
//            // Successfully subscribed
//        }
//    }
    
//    func vehicleDataAvailable(_ notification: SDLRPCNotificationNotification) {
//        guard let onVehicleData = notification.notification as? SDLOnVehicleData else {
//            return
//        }
//
//        let prndl = onVehicleData.prndl
//    }
    
    func subscribe(){
        NotificationCenter.default.addObserver(self, selector: #selector(vehicleDataAvailable(_:)), name: .SDLDidReceiveVehicleData, object: nil)

        subscribeVehicleData.speed = true // as NSNumber & SDLBool
        subscribeVehicleData.fuelLevel = true //as NSNumber & SDLBool
        subscribeVehicleData.gps = true
        subscribeVehicleData.fuelRange = true
        subscribeVehicleData.tirePressure = true
        subscribeVehicleData.externalTemperature = true
        subscribeVehicleData.engineOilLife = true
        subscribeVehicleData.odometer = true



        sdlManager.send(request: subscribeVehicleData) { (request, response, error) in
            guard let response = response as? SDLSubscribeVehicleDataResponse else { return }

            guard response.success.boolValue == true else {
                if response.resultCode == .disallowed {
                    // Not allowed to register for this vehicle data.
                    print("Not allowed to register for this vehicle data.")
                } else if response.resultCode == .userDisallowed {
                    // User disabled the ability to give you this vehicle data
                    print("User disabled the ability to give you this vehicle data.")
                } else if response.resultCode == .ignored {
                    if let prndlData = response.prndl {
                        if prndlData.resultCode == .dataAlreadySubscribed {
                            // You have access to this data item, and you are already subscribed to this item so we are ignoring.
                        } else if prndlData.resultCode == .vehicleDataNotAvailable {
                            // You have access to this data item, but the vehicle you are connected to does not provide it.
                        } else {
                            print("Unknown reason for being ignored: \(prndlData.resultCode)")
                        }
                    } else {
                        print("Unknown reason for being ignored: \(String(describing: response.info))")
                    }
                } else if let error = error {
                    print("Encountered Error sending SubscribeVehicleData: \(error)")
                }
                return
            }

            // Successfully subscribed
            print("Successfully subscribed to SPEED")
//            self.subscribedToSpeed = true
        }
    }
    
    @objc func vehicleDataAvailable(_ notification: SDLRPCNotificationNotification) {
        print("rip")
        guard let onVehicleData = notification.notification as? SDLOnVehicleData else {
            return
        }
        
//        let eCallInfo = onVehicleData.eCallInfo
        prevSpeed = SDLspeed
        if onVehicleData.speed != nil {
            // save the new speed data
            SDLspeed = onVehicleData.speed!
        }
        
        if onVehicleData.gps != nil {
            SDLgps = onVehicleData.gps!
        }
        
        if onVehicleData.fuelLevel != nil {
            fuelLevel = Int(onVehicleData.fuelLevel!.intValue)
        }
        
//        if onVehicleData.fuelRange != nil {
//            fuelRange = onVehicleData.fuelRange!
//        }
        
        if onVehicleData.externalTemperature != nil {
            externalTemperature = Int(onVehicleData.externalTemperature!.intValue)
        }
        
        if onVehicleData.engineOilLife != nil {
            engineOilLife = Int(onVehicleData.engineOilLife!.intValue)
        }
        
        if onVehicleData.odometer != nil {
            odometer = Int(onVehicleData.odometer!.intValue)
        }
        
        if onVehicleData.tirePressure != nil {
//            if onVehicleData.tirePressure?.leftFront != nil {
//                if onVehicleData.tirePressure?.leftFront.pressure != nil {
//                    tirePressureFL = Double((onVehicleData.tirePressure?.leftFront.pressure!.doubleValue)!)
//                }
//            }
//            if onVehicleData.tirePressure?.leftFront != nil {
//                tirePressureFL = onVehicleData.tirePressure!.leftFront.pressure??.doubleValue * 0.145
//            }
//            if onVehicleData.tirePressure?.leftRear != nil {
//                tirePressureBL = onVehicleData.tirePressure!.leftRear.pressure??.doubleValue * 0.145
//            }
//            if onVehicleData.tirePressure?.rightFront != nil {
//                tirePressureBR = onVehicleData.tirePressure!.rightFront.pressure??.doubleValue * 0.145
//            }
//            if onVehicleData.tirePressure?.rightRear != nil {
//                tirePressureFR = onVehicleData.tirePressure!.rightRear.pressure??.doubleValue * 0.145
//            }
            if onVehicleData.tirePressure?.leftFront != nil {
                tirePressureLF = onVehicleData.tirePressure!.leftFront.status.rawValue.rawValue
            }
            if onVehicleData.tirePressure?.leftRear != nil {
                tirePressureLR = onVehicleData.tirePressure!.leftRear.status.rawValue.rawValue
            }
            if onVehicleData.tirePressure?.rightFront != nil {
                tirePressureRF = onVehicleData.tirePressure!.rightFront.status.rawValue.rawValue
            }
            if onVehicleData.tirePressure?.rightRear != nil {
                tirePressureRR = onVehicleData.tirePressure!.rightRear.status.rawValue.rawValue
            }

        }
        
        let acceleration:Int = Int(SDLspeed.intValue) - Int(prevSpeed.intValue)
        accelerationArray.append(acceleration)
        calcAggressiveDriving(acceleration: acceleration)
        
        calcSpeedingValues(speed: Int(SDLspeed.intValue))
        
//        let SDLspeed = onVehicleData.speed ?? -1
//        let SDLfuelLevel = onVehicleData.fuelLevel ?? -1
        
//        print("\(String(describing: eCallInfo)) updated")
        print("\(SDLspeed) is the current speed")
        print("\(SDLfuelLevel) is the current fuel level")
        print("gps: \(String(describing: SDLgps))")
        print(onVehicleData)
        
        
        
        self.sdlManager.screenManager.beginUpdates()
        self.sdlManager.screenManager.textField1 = "Speed is \(SDLspeed) MPH"
        self.sdlManager.screenManager.endUpdates()
        
        
    }
    
    func calcSpeedingValues(speed: Int) {
        if speed > maxSpeed {
            maxSpeed = speed
        }
        
        if speed > speedLimit {
            speedDuration += 1
        }
    }
    
    func calcAggressiveDriving(acceleration: Int) {
        if Double(acceleration) > 16.5 {
            aggressiveDrivingCount += 1
        } else if Double(acceleration) < -16.5 {
            aggressiveDrivingCount += 1
        }
    }
    
    func calcTurningMistakes(){}
    
    func calcRollingStops(){}
    
    
    
    /// Configures the SDL Manager that handles data transfer beween this app and the car's head unit and starts searching for a connection to a head unit. There are two possible types of transport layers to use: TCP is used to connect wirelessly to SDL Core and is only available for debugging; iAP is used to connect to MFi (Made for iPhone) hardware and is must be used for production builds.
    ///
    /// - Parameter connectionType: The type of transport layer to use.
    func start(with proxyTransportType: ProxyTransportType) {
        delegate?.didChangeProxyState(ProxyState.searching)
        sdlManager = SDLManager(configuration: proxyTransportType == .iap ? ProxyManager.connectIAP() : ProxyManager.connectTCP(), delegate: self)
        startManager()
    }

    /// Attempts to close the connection between the this app and the car's head unit. The `SDLManagerDelegate`'s `managerDidDisconnect()` is called when connection is actually closed.
    func resetConnection() {
        guard sdlManager != nil else {
            delegate?.didChangeProxyState(ProxyState.stopped)
            return
        }

        sdlManager.stop()
    }
}

// MARK: - SDL Configuration Helpers

private extension ProxyManager {
    /// Configures an iAP transport layer.
    ///
    /// - Returns: A SDLConfiguration object
    class func connectIAP() -> SDLConfiguration {
        let lifecycleConfiguration = SDLLifecycleConfiguration(appName: ExampleAppName, fullAppId: ExampleFullAppId)
        return setupManagerConfiguration(with: lifecycleConfiguration)
    }

    /// Configures a TCP transport layer with the IP address and port of the remote SDL Core instance.
    ///
    /// - Returns: A SDLConfiguration object
    class func connectTCP() -> SDLConfiguration {
        let lifecycleConfiguration = SDLLifecycleConfiguration(appName: ExampleAppName, fullAppId: ExampleFullAppId, ipAddress: AppUserDefaults.shared.ipAddress!, port: UInt16(AppUserDefaults.shared.port!)!)
        return setupManagerConfiguration(with: lifecycleConfiguration)
    }

    /// Helper method for setting additional configuration parameters for both TCP and iAP transport layers.
    ///
    /// - Parameter lifecycleConfiguration: The transport layer configuration
    /// - Returns: A SDLConfiguration object
    class func setupManagerConfiguration(with lifecycleConfiguration: SDLLifecycleConfiguration) -> SDLConfiguration {
        lifecycleConfiguration.shortAppName = ExampleAppNameShort
        let appIcon = UIImage(named: ExampleAppLogoName)?.withRenderingMode(.alwaysOriginal)
        lifecycleConfiguration.appIcon = appIcon != nil ? SDLArtwork(image: appIcon!, persistent: true, as: .PNG) : nil
        lifecycleConfiguration.appType = .default
        lifecycleConfiguration.language = .enUs
        lifecycleConfiguration.languagesSupported = [.enUs, .esMx, .frCa]
        lifecycleConfiguration.ttsName = [SDLTTSChunk(text: "S D L", type: .text)]

        let green = SDLRGBColor(red: 126, green: 188, blue: 121)
        let white = SDLRGBColor(red: 249, green: 251, blue: 254)
        let grey = SDLRGBColor(red: 186, green: 198, blue: 210)
        let darkGrey = SDLRGBColor(red: 57, green: 78, blue: 96)
        lifecycleConfiguration.dayColorScheme = SDLTemplateColorScheme(primaryRGBColor: green, secondaryRGBColor: grey, backgroundRGBColor: white)
        lifecycleConfiguration.nightColorScheme = SDLTemplateColorScheme(primaryRGBColor: green, secondaryRGBColor: grey, backgroundRGBColor: darkGrey)

        let lockScreenConfiguration = SDLLockScreenConfiguration.disabled()
//        let lockScreenConfiguration = appIcon != nil ? SDLLockScreenConfiguration.enabledConfiguration(withAppIcon: appIcon!, backgroundColor: nil) : SDLLockScreenConfiguration.disabled()
        return SDLConfiguration(lifecycle: lifecycleConfiguration, lockScreen: lockScreenConfiguration, logging: logConfiguration(), fileManager:.default())
    }

    /// Sets the type of SDL debug logs that are visible and where to port the logs. There are 4 levels of log filtering, verbose, debug, warning and error. Verbose prints all SDL logs; error prints only the error logs. Adding SDLLogTargetFile to the targest will log to a text file on the iOS device. This file can be accessed via: iTunes > Your Device Name > File Sharing > Your App Name. Make sure `UIFileSharingEnabled` has been added to the application's info.plist and is set to `true`.
    ///
    /// - Returns: A SDLLogConfiguration object
    class func logConfiguration() -> SDLLogConfiguration {
        let logConfig = SDLLogConfiguration.default()
        let exampleLogFileModule = SDLLogFileModule(name: "SDL Swift Example App", files: ["ProxyManager", "AlertManager", "AudioManager", "ButtonManager", "MenuManager", "PerformInteractionManager", "RPCPermissionsManager", "VehicleDataManager"])
        logConfig.modules.insert(exampleLogFileModule)
        _ = logConfig.targets.insert(SDLLogTargetFile()) // Logs to file
        logConfig.globalLogLevel = .debug // Filters the logs
        return logConfig
    }

    /// Searches for a connection to a SDL enabled accessory. When a connection has been established, the ready handler is called. Even though the app is connected to SDL Core, it does not mean that RPCs can be immediately sent to the accessory as there is no guarentee that SDL Core is ready to receive RPCs. Monitor the `SDLManagerDelegate`'s `hmiLevel:didChangeToLevel:` to determine when to send RPCs.
    func startManager() {
        sdlManager.start(readyHandler: { [unowned self] (success, error) in
            guard success else {
                SDLLog.e("There was an error while starting up: \(String(describing: error))")
                self.resetConnection()
                return
            }

            self.delegate?.didChangeProxyState(ProxyState.connected)

            self.buttonManager = ButtonManager(sdlManager: self.sdlManager, updateScreenHandler: self.refreshUIHandler)
            self.vehicleDataManager = VehicleDataManager(sdlManager: self.sdlManager, refreshUIHandler: self.refreshUIHandler)
            self.performInteractionManager = PerformInteractionManager(sdlManager: self.sdlManager)

            RPCPermissionsManager.setupPermissionsCallbacks(with: self.sdlManager)

            SDLLog.d("SDL file manager storage: \(self.sdlManager.fileManager.bytesAvailable / 1024 / 1024) mb")
        })
    }
}

// MARK: - SDLManagerDelegate

extension ProxyManager: SDLManagerDelegate {
    /// Called when the connection beween this app and SDL Core has closed.
    func managerDidDisconnect() {
        delegate?.didChangeProxyState(ProxyState.stopped)
        firstHMILevelState = .none

        // If desired, automatically start searching for a new connection to Core
        if ExampleAppShouldRestartSDLManagerOnDisconnect.boolValue {
            startManager()
        }
    }

    /// Called when the state of the SDL app has changed. The state limits the type of RPC that can be sent. Refer to the class documentation for each RPC to determine what state(s) the RPC can be sent.
    ///
    /// - Parameters:
    ///   - oldLevel: The old SDL HMI Level
    ///   - newLevel: The new SDL HMI Level
    func hmiLevel(_ oldLevel: SDLHMILevel, didChangeToLevel newLevel: SDLHMILevel) {
        if newLevel != .none && firstHMILevelState == .none {
            // This is our first time in a non-NONE state
            firstHMILevelState = newLevel

            // Send static menu items. Menu related RPCs can be sent at all `hmiLevel`s except `NONE`
            createMenuAndGlobalVoiceCommands()
            vehicleDataManager.subscribeToVehicleOdometer()
        }

        if newLevel == .full && firstHMILevelState != .full {
            // This is our first time in a `FULL` state.
            firstHMILevelState = newLevel
        }

        switch newLevel {
        case .full:                // The SDL app is in the foreground
            // Always try to show the initial state to guard against some possible weird states. Duplicates will be ignored by Core.
            showInitialData()
        case .limited: break        // An active NAV or MEDIA SDL app is in the background
        case .background: break     // The SDL app is not in the foreground
        case .none: break           // The SDL app is not yet running
        default: break
        }
    }

    func systemContext(_ oldContext: SDLSystemContext?, didChangeToContext newContext: SDLSystemContext) {
        switch newContext {
        case SDLSystemContext.alert: break
        case SDLSystemContext.hmiObscured: break
        case SDLSystemContext.main: break
        case SDLSystemContext.menu: break
        case SDLSystemContext.voiceRecognitionSession: break
        default: break
        }
    }

    /// Called when the audio state of the SDL app has changed. The audio state only needs to be monitored if the app is streaming audio.
    ///
    /// - Parameters:
    ///   - oldState: The old SDL audio streaming state
    ///   - newState: The new SDL audio streaming state
    func audioStreamingState(_ oldState: SDLAudioStreamingState?, didChangeToState newState: SDLAudioStreamingState) {
        switch newState {
        case .audible: break        // The SDL app's audio can be heard
        case .notAudible: break     // The SDL app's audio cannot be heard
        case .attenuated: break     // The SDL app's audio volume has been lowered to let the system speak over the audio. This usually happens with voice recognition commands.
        default: break
        }
    }

    /// Called when the car's head unit language is different from the default langage set in the SDLConfiguration AND the head unit language is supported by the app (as set in `languagesSupported` of SDLConfiguration). This method is only called when a connection to Core is first established. If desired, you can update the app's name and text-to-speech name to reflect the head unit's language.
    ///
    /// - Parameter language: The head unit's current language
    /// - Returns: A SDLLifecycleConfigurationUpdate object
    func managerShouldUpdateLifecycle(toLanguage language: SDLLanguage) -> SDLLifecycleConfigurationUpdate? {
        var appName = ""
        switch language {
        case .enUs:
            appName = ExampleAppName
        case .esMx:
            appName = ExampleAppNameSpanish
        case .frCa:
            appName = ExampleAppNameFrench
        default:
            return nil
        }

        return SDLLifecycleConfigurationUpdate(appName: appName, shortAppName: nil, ttsName: [SDLTTSChunk(text: appName, type: .text)], voiceRecognitionCommandNames: nil)
    }
}

// MARK: - SDL UI

private extension ProxyManager {
    /// Handler for refreshing the UI
    var refreshUIHandler: RefreshUIHandler? {
        return { [unowned self] () in
            self.updateScreen()
        }
    }

    /// Set the template and create the UI
    func showInitialData() {
        guard sdlManager.hmiLevel == .full else { return }
        
        let setDisplayLayout = SDLSetDisplayLayout(predefinedLayout: .nonMedia)
        sdlManager.send(setDisplayLayout)

        updateScreen()
        sdlManager.screenManager.softButtonObjects = buttonManager.allScreenSoftButtons(with: sdlManager)
    }

    /// Update the UI's textfields, images and soft buttons
    func updateScreen() {
        guard sdlManager.hmiLevel == .full else { return }

        let screenManager = sdlManager.screenManager
        let isTextVisible = buttonManager.textEnabled
        let areImagesVisible = buttonManager.imagesEnabled

        screenManager.beginUpdates()
        screenManager.textAlignment = .left
        screenManager.textField1 = isTextVisible ? SmartDeviceLinkText : nil
        screenManager.textField2 = isTextVisible ? "Swift \(ExampleAppText)" : nil
        screenManager.textField3 = isTextVisible ? vehicleDataManager.vehicleOdometerData : nil

        if sdlManager.systemCapabilityManager.displayCapabilities?.graphicSupported.boolValue ?? false {
            // Primary graphic
            if imageFieldSupported(imageFieldName: .graphic) {
                screenManager.primaryGraphic = areImagesVisible ? SDLArtwork(image: UIImage(named: ExampleAppLogoName)!.withRenderingMode(.alwaysOriginal), persistent: false, as: .PNG) : nil
            }

            // Secondary graphic
            if imageFieldSupported(imageFieldName: .secondaryGraphic) {
                screenManager.secondaryGraphic = areImagesVisible ? SDLArtwork(image: UIImage(named: CarBWIconImageName)!, persistent: false, as: .PNG) : nil
            }
        }
        
        screenManager.endUpdates(completionHandler: { (error) in
            guard error != nil else { return }
            SDLLog.e("Textfields, graphics and soft buttons failed to update: \(error!.localizedDescription)")
        })
    }

    /// Send static menu data
    func createMenuAndGlobalVoiceCommands() {
        // Send the root menu items
        let screenManager = sdlManager.screenManager
        let menuItems = MenuManager.allMenuItems(with: sdlManager, choiceSetManager: performInteractionManager)
        let voiceMenuItems = MenuManager.allVoiceMenuItems(with: sdlManager)

        if !menuItems.isEmpty { screenManager.menu = menuItems }
        if !voiceMenuItems.isEmpty { screenManager.voiceCommands = voiceMenuItems }
    }

    /// Checks if SDL Core's HMI current template supports the template image field (i.e. primary graphic, secondary graphic, etc.)
    ///
    /// - Parameter imageFieldName: The name for the image field
    /// - Returns:                  True if the image field is supported, false if not
    func imageFieldSupported(imageFieldName: SDLImageFieldName) -> Bool {
        return sdlManager.systemCapabilityManager.displayCapabilities?.imageFields?.first { $0.name == imageFieldName } != nil ? true : false
    }
}
