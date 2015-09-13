//
//  BluetoothController.swift
//  BLE-Test
//
//  Created by Pierre Karashchuk on 9/13/15.
//  Copyright (c) 2015 Pierre Karashchuk. All rights reserved.
//

import UIKit
import CoreBluetooth

enum ConnectionMode:Int {
    case None
    case PinIO
    case UART
    case Info
    case Controller
    case DFU
}

enum ConnectionStatus:Int {
    case Idle = 0
    case Scanning
    case Connected
    case Connecting
}

@objc protocol BLEDelegate: Any {
    func didReceiveData(data:NSData)
    func btConnectionChanged(state:Bool)
}


class BLEController: NSObject, CBCentralManagerDelegate, BLEPeripheralDelegate {
    private var cm:CBCentralManager?
    private var currentAlertView:UIAlertController?
    private var currentPeripheral:BLEPeripheral?
    private let cbcmQueue = dispatch_queue_create("com.adafruit.bluefruitconnect.cbcmqueue", DISPATCH_QUEUE_CONCURRENT)
    
    private let connectionTimeOutIntvl:NSTimeInterval = 30.0
    private var connectionTimer:NSTimer?
    
    var delegate:UIViewController;
    @objc var dataDelegate:BLEDelegate;

    var connectionMode:ConnectionMode = ConnectionMode.None
    var connectionStatus:ConnectionStatus = ConnectionStatus.Idle
    

    
    @objc init(UIdelegate: UIViewController, dataDelegate: BLEDelegate) {
        self.delegate = UIdelegate;
        self.dataDelegate = dataDelegate;

        super.init()
        
        // Create core bluetooth manager on launch
        if (cm == nil) {
            cm = CBCentralManager(delegate: self, queue: cbcmQueue)
            
            connectionMode = ConnectionMode.None
            connectionStatus = ConnectionStatus.Idle
            currentAlertView = nil
        }

        startScan()
    }
    
    
    func didFindPeripheral(peripheral:CBPeripheral!, advertisementData:[NSObject : AnyObject]!, RSSI:NSNumber!) {
        
        //        println("\(self.classForCoder.description()) didFindPeripheral")
        
        let device = BLEDevice(peripheral: peripheral, advertisementData: advertisementData, RSSI: RSSI)
        
        if(device.isUART) {
            NSLog("Found peripheral %@, data: %@, RSSI: %@", peripheral, advertisementData, RSSI);
//            print(RSSI.floatValue)
            if(RSSI.floatValue > -60) {
                print("connecting")
                // let's try to connect
                self.connectPeripheral(peripheral, mode: ConnectionMode.UART)
            }
            
        }
        
//        //If device is already listed, just update RSSI
//        let newID = peripheral.identifier
//        for device in devices {
//            if device.identifier == newID {
//                //                println("   \(self.classForCoder.description()) updating device RSSI")
//                device.RSSI = RSSI
//                return
//            }
//        }
//        
//        //Add reference to new device
//        let newDevice = BLEDevice(peripheral: peripheral, advertisementData: advertisementData, RSSI: RSSI)
//        newDevice.printAdData()
//        devices.append(newDevice)
//        
//        //Reload tableview to show new device
//        if tableView != nil {
//            tableIsLoading = true
//            tableView.reloadData()
//            tableIsLoading = false
//        }
//        
//        delegate?.warningLabel.text = ""
    }
    

    
    
    //MARK: CBCentralManagerDelegate methods
    
    func centralManagerDidUpdateState(central: CBCentralManager!) {
        
        if (central.state == CBCentralManagerState.PoweredOn){
            
            //respond to powered on
        }
            
        else if (central.state == CBCentralManagerState.PoweredOff){
            
            //respond to powered off
        }
        
    }
    
    
    func centralManager(central: CBCentralManager!, didDiscoverPeripheral peripheral: CBPeripheral!, advertisementData: [NSObject : AnyObject]!, RSSI: NSNumber!) {
        
        if connectionMode == ConnectionMode.None {
            dispatch_sync(dispatch_get_main_queue(), { () -> Void in
//                if self.deviceListViewController == nil {
//                    self.createDeviceListViewController()
//                }
                
                self.didFindPeripheral(peripheral, advertisementData: advertisementData, RSSI:RSSI)
            })
            
//            if navController.topViewController != deviceListViewController {
//                dispatch_sync(dispatch_get_main_queue(), { () -> Void in
//                    self.pushViewController(self.deviceListViewController)
//                })
//            }
            
        }
    }
    
    
    func centralManager(central: CBCentralManager!, didConnectPeripheral peripheral: CBPeripheral!) {
        
//        if (delegate != nil) {
//            delegate!.onDeviceConnectionChange(peripheral)
//        }
        
        
        println("connected!")
        
        currentAlertView?.dismissViewControllerAnimated(true, completion: nil)
        
        //Connecting in DFU mode, discover specific services
        if connectionMode == ConnectionMode.DFU {
            peripheral.discoverServices([dfuServiceUUID(), deviceInformationServiceUUID()])
        }
        
        if currentPeripheral == nil {
            printLog(self, "didConnectPeripheral", "No current peripheral found, unable to connect")
            return
        }
        
        
        if currentPeripheral!.currentPeripheral == peripheral {
            
            printLog(self, "didConnectPeripheral", "\(peripheral.name)")
            
            //Discover Services for device
            if((peripheral.services) != nil){
                printLog(self, "didConnectPeripheral", "Did connect to existing peripheral \(peripheral.name)")
                currentPeripheral!.peripheral(peripheral, didDiscoverServices: nil)  //already discovered services, DO NOT re-discover. Just pass along the peripheral.
            }
            else {
                currentPeripheral!.didConnect(connectionMode)
            }
            
        }
        
        self.dataDelegate.btConnectionChanged(true);
    }
    
    
    func centralManager(central: CBCentralManager!, didDisconnectPeripheral peripheral: CBPeripheral!, error: NSError!) {
        
        //respond to disconnection
        
//        if (delegate != nil) {
//            delegate!.onDeviceConnectionChange(peripheral)
//        }
        
        if connectionMode == ConnectionMode.DFU {
            connectionStatus = ConnectionStatus.Idle
            return
        }
        else if connectionMode == ConnectionMode.Controller {
//            controllerViewController.showNavbar()
        }
        
        printLog(self, "didDisconnectPeripheral", "")
        
        if currentPeripheral == nil {
            printLog(self, "didDisconnectPeripheral", "No current peripheral found, unable to disconnect")
            return
        }
        
        //if we were in the process of scanning/connecting, dismiss alert
        if (currentAlertView != nil) {
            uartDidEncounterError("Peripheral disconnected")
        }
        
        //if status was connected, then disconnect was unexpected by the user, show alert
//        let topVC = navController.topViewController
//        if  connectionStatus == ConnectionStatus.Connected && isModuleController(topVC) {
        if  connectionStatus == ConnectionStatus.Connected {
        
            printLog(self, "centralManager:didDisconnectPeripheral", "unexpected disconnect while connected")
            
            //return to main view
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.respondToUnexpectedDisconnect()
            })
        }
            
            // Disconnected while connecting
        else if connectionStatus == ConnectionStatus.Connecting {
            
            abortConnection()
            
            printLog(self, "centralManager:didDisconnectPeripheral", "unexpected disconnect while connecting")
            
            //return to main view
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.respondToUnexpectedDisconnect()
            })
            
        }
        
        connectionStatus = ConnectionStatus.Idle
        connectionMode = ConnectionMode.None
        currentPeripheral = nil
        
        // Dereference mode controllers
//        dereferenceModeController()
        
        self.dataDelegate.btConnectionChanged(false);
        
    }
    
    
    func centralManager(central: CBCentralManager!, didFailToConnectPeripheral peripheral: CBPeripheral!, error: NSError!) {
//        
//        if (delegate != nil) {
//            delegate!.onDeviceConnectionChange(peripheral)
//        }
        
    }
    
    
    func respondToUnexpectedDisconnect() {
        
//        self.navController.popToRootViewControllerAnimated(true)
        
        //display disconnect alert
        let alert = UIAlertView(title:"Disconnected",
            message:"BlE device disconnected",
            delegate:self,
            cancelButtonTitle:"OK")
        
        let note = UILocalNotification()
        note.fireDate = NSDate().dateByAddingTimeInterval(0.0)
        note.alertBody = "BLE device disconnected"
        note.soundName =  UILocalNotificationDefaultSoundName
        UIApplication.sharedApplication().scheduleLocalNotification(note)
        
        alert.show()
        
        startScan()
        
    }
    
//    
//    func dereferenceModeController() {
//        
//        pinIoViewController = nil
//        uartViewController = nil
//        deviceInfoViewController = nil
//        controllerViewController = nil
//        dfuViewController = nil
//    }
//    
    
//    func isModuleController(anObject:AnyObject)->Bool{
//        
//        var verdict = false
//        if     anObject.isMemberOfClass(PinIOViewController)
//            || anObject.isMemberOfClass(UARTViewController)
//            || anObject.isMemberOfClass(DeviceInfoViewController)
//            || anObject.isMemberOfClass(ControllerViewController)
//            || anObject.isMemberOfClass(DFUViewController)
//            || (anObject.title == "Control Pad")
//            || (anObject.title == "Color Picker") {
//                verdict = true
//        }
//        
//        //all controllers are modules except BLEMainViewController - weak
//        //        var verdict = true
//        //        if anObject.isMemberOfClass(BLEMainViewController) {
//        //            verdict = false
//        //        }
//        
//        return verdict
//        
//    }
    
    
    //MARK: BLEPeripheralDelegate methods
    
    func connectionFinalized() {
        
        //Bail if we aren't in the process of connecting
        if connectionStatus != ConnectionStatus.Connecting {
            printLog(self, "connectionFinalized", "with incorrect state")
            return
        }
        
        if (currentPeripheral == nil) {
            printLog(self, "connectionFinalized", "Unable to start info w nil currentPeripheral")
            return
        }
        
        //stop time out timer
        connectionTimer?.invalidate()
        
        connectionStatus = ConnectionStatus.Connected
        
        // Check if automatic update should be presented to the user
//        if (firmwareUpdater != nil && connectionMode != .DFU) {
//            // Wait till an updates are checked
//            printLog(self, "connectionFinalized", "Check if updates are available")
//            firmwareUpdater!.checkUpdatesForPeripheral(currentPeripheral!.currentPeripheral, delegate: self)
//        }
//        else {
//            // Automatic updates not enabled. Just go to the mode selected by the user
//            launchViewControllerForSelectedMode()
//        }
        
    }
    
//    func launchViewControllerForSelectedMode() {
//        //Push appropriate viewcontroller onto the navcontroller
//        var vc:UIViewController? = nil
//        switch connectionMode {
//        case ConnectionMode.PinIO:
//            pinIoViewController = PinIOViewController(delegate: self)
//            pinIoViewController.didConnect()
//            vc = pinIoViewController
//            break
//        case ConnectionMode.UART:
//            uartViewController = UARTViewController(aDelegate: self)
//            uartViewController.didConnect()
//            vc = uartViewController
//            break
//        case ConnectionMode.Info:
//            deviceInfoViewController = DeviceInfoViewController(cbPeripheral: currentPeripheral!.currentPeripheral, delegate: self)
//            vc = deviceInfoViewController
//            break
//        case ConnectionMode.Controller:
//            controllerViewController = ControllerViewController(aDelegate: self)
//            vc = controllerViewController
//        case ConnectionMode.DFU:
//            printLog(self, (__FUNCTION__), "DFU mode")
//        default:
//            printLog(self, (__FUNCTION__), "No connection mode set")
//            break
//        }
//        
//        if (vc != nil) {
//            vc?.navigationItem.rightBarButtonItem = infoBarButton
//            dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                self.pushViewController(vc!)
//            })
//        }
//    }
    
    
    func launchDFU(peripheral:CBPeripheral){
        
        printLog(self, (__FUNCTION__), self.description)
        
//        connectionMode = ConnectionMode.DFU
//        dfuViewController = DFUViewController()
//        dfuViewController.peripheral = peripheral
//        //        dfuViewController.navigationItem.rightBarButtonItem = infoBarButton
//        
//        dispatch_async(dispatch_get_main_queue(), { () -> Void in
//            self.pushViewController(self.dfuViewController!)
//        })
        
    }
    
    
    func uartDidEncounterError(error: NSString) {
        
        //Dismiss "scanning …" alert view if shown
        if (currentAlertView != nil) {
            currentAlertView?.dismissViewControllerAnimated(true, completion: { () -> Void in
                self.alertDismissedOnError()
            })
        }
        
        //Display error alert
        let alert = UIAlertController(title: "Error", message: error as String, preferredStyle: UIAlertControllerStyle.Alert)
        let aaOK = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        alert.addAction(aaOK)
//        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    func didReceiveData(newData: NSData) {
        
        //Data incoming from UART peripheral, forward to current view controller
        
        printLog(self, "didReceiveData", "\(newData.stringRepresentation())")

        self.dataDelegate.didReceiveData(newData)
        
//        let str = "new data"
//        let data = str.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)

//        self.sendData(data!)
        
        if (connectionStatus == ConnectionStatus.Connected ) {
            //UART
            if (connectionMode == ConnectionMode.UART) {
                //send data to UART Controller
//                uartViewController.receiveData(newData)
            }
                
                //Pin I/O
            else if (connectionMode == ConnectionMode.PinIO) {
                //send data to PIN IO Controller
//                pinIoViewController.receiveData(newData)
            }
        }
        else {
            printLog(self, "didReceiveData", "Received data without connection")
        }
        
    }
    
    
    func peripheralDidDisconnect() {
        
        //respond to device disconnecting
        
        printLog(self, "peripheralDidDisconnect", "")
        
        //if we were in the process of scanning/connecting, dismiss alert
        if (currentAlertView != nil) {
            uartDidEncounterError("Peripheral disconnected")
        }
        
        //if status was connected, then disconnect was unexpected by the user, show alert
//        let topVC = navController.topViewController
//        if  connectionStatus == ConnectionStatus.Connected && isModuleController(topVC) {
        if  connectionStatus == ConnectionStatus.Connected {
            
            printLog(self, "peripheralDidDisconnect", "unexpected disconnect while connected")
            
            //return to main view
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.respondToUnexpectedDisconnect()
            })
        }
        
        connectionStatus = ConnectionStatus.Idle
        connectionMode = ConnectionMode.None
        currentPeripheral = nil
        
        // Dereference mode controllers
//        dereferenceModeController()
        
    }
    
    
    func alertBluetoothPowerOff() {
        
        //Respond to system's bluetooth disabled
        
        let title = "Bluetooth Power"
        let message = "You must turn on Bluetooth in Settings in order to connect to a device"
        let alertView = UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: "OK")
        alertView.show()
    }
    
    
    func alertFailedConnection() {
        
        //Respond to unsuccessful connection
        
        let title = "Unable to connect"
        let message = "Please check power & wiring,\nthen reset your Arduino"
        let alertView = UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: "OK")
        alertView.show()
        
    }
    
    
    //MARK: UartViewControllerDelegate / PinIOViewControllerDelegate methods
    
    func sendData(newData: NSData) {
        
        //Output data to UART peripheral
        
        let hexString = newData.hexRepresentationWithSpaces(true)
        
        printLog(self, "sendData", "\(hexString)")
        
        
        if currentPeripheral == nil {
            printLog(self, "sendData", "No current peripheral found, unable to send data")
            return
        }
        
        currentPeripheral!.writeRawData(newData)
        
    }
    
    //MARK: other methods
    
    func connectionTimedOut(timer:NSTimer) {
        
        if connectionStatus != ConnectionStatus.Connecting {
            return
        }
        
        //dismiss "Connecting" alert view
        if currentAlertView != nil {
            currentAlertView?.dismissViewControllerAnimated(true, completion: nil)
            currentAlertView = nil
        }
        
        //Cancel current connection
        abortConnection()
        
        //Notify user that connection timed out
        let alert = UIAlertController(title: "Connection timed out", message: "No response from peripheral", preferredStyle: UIAlertControllerStyle.Alert)
        let aaOk = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel) { (aa:UIAlertAction!) -> Void in }
        alert.addAction(aaOk)
//        self.presentViewController(alert, animated: true) { () -> Void in }
        
    }
    
    
    func abortConnection() {
        
        connectionTimer?.invalidate()
        
        cm?.cancelPeripheralConnection(currentPeripheral?.currentPeripheral)
        
        currentPeripheral = nil
        
        connectionMode = ConnectionMode.None
        connectionStatus = ConnectionStatus.Idle
    }
    
    
    func disconnect() {
        
        printLog(self, (__FUNCTION__), "")
        
//        if connectionMode == ConnectionMode.DFU && dfuPeripheral != nil{
//            cm!.cancelPeripheralConnection(dfuPeripheral)
//            dfuPeripheral = nil
//            return
//        }
//        
        if cm == nil {
            printLog(self, (__FUNCTION__), "No central Manager found, unable to disconnect peripheral")
            return
        }
            
        else if currentPeripheral == nil {
            printLog(self, (__FUNCTION__), "No current peripheral found, unable to disconnect peripheral")
            return
        }
        
        //Cancel any current or pending connection to the peripheral
        let peripheral = currentPeripheral!.currentPeripheral
        if peripheral.state == CBPeripheralState.Connected || peripheral.state == CBPeripheralState.Connecting {
            cm!.cancelPeripheralConnection(peripheral)
        }
        
    }
    
    func alertDismissedOnError() {
        
        //        if buttonIndex == 77 {
        //            currentAlertView = nil
        //        }
        
        if (connectionStatus == ConnectionStatus.Connected) {
            disconnect()
        }
        else if (connectionStatus == ConnectionStatus.Scanning){
            
            if cm == nil {
                printLog(self, "alertView clickedButtonAtIndex", "No central Manager found, unable to stop scan")
                return
            }
            
            stopScan()
        }
        
        connectionStatus = ConnectionStatus.Idle
        connectionMode = ConnectionMode.None
        
        currentAlertView = nil
        
        //alert dismisses automatically @ return
        
    }
    
    func toggleScan(sender:UIBarButtonItem?){
        
        // Stop scan
        if connectionStatus == ConnectionStatus.Scanning {
            stopScan()
        }
            
            // Start scan
        else {
            startScan()
        }
        
    }
    
    
    func stopScan(){
        
        if (connectionMode == ConnectionMode.None) {
            cm?.stopScan()
//            scanIndicator?.stopAnimating()
            
            //If scan indicator is in toolbar items, remove it
//            let count:Int = deviceListViewController.toolbarItems!.count
//            var index = -1
//            for i in 0...(count-1) {
//                if deviceListViewController.toolbarItems?[i] === scanIndicatorItem {
//                    deviceListViewController.toolbarItems?.removeAtIndex(i)
//                    break
//                }
//            }
//            
            connectionStatus = ConnectionStatus.Idle
//            scanButtonItem?.title = "Scan for peripherals"
        }
        
        
        //        else if (connectionMode == ConnectionMode.UART) {
        //
        //        }
        
    }
    
    
    func startScan() {
        //Check if Bluetooth is enabled
        if cm?.state == CBCentralManagerState.PoweredOff {
            onBluetoothDisabled()
            return
        }
        
        println("starting scan");
        
        cm!.scanForPeripheralsWithServices(nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        //Check if scan indicator is in toolbar items
//        var indicatorShown = false
//        for i in deviceListViewController.toolbarItems! {
//            if i === scanIndicatorItem {
//                indicatorShown = true
//            }
//        }
        //Insert scan indicator if not already in toolbar items
//        if indicatorShown == false {
//            deviceListViewController.toolbarItems?.insert(scanIndicatorItem!, atIndex: 1)
//        }
        
//        scanIndicator?.startAnimating()
        connectionStatus = ConnectionStatus.Scanning
//        scanButtonItem?.title = "Scanning"
    }
    
    
    func onBluetoothDisabled(){
        
        //Show alert to enable bluetooth
        let alert = UIAlertController(title: "Bluetooth disabled", message: "Enable Bluetooth in system settings", preferredStyle: UIAlertControllerStyle.Alert)
        let aaOK = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        alert.addAction(aaOK)
        self.delegate.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    
    func connectPeripheral(peripheral:CBPeripheral, mode:ConnectionMode) {
        
        //Check if Bluetooth is enabled
        if cm?.state == CBCentralManagerState.PoweredOff {
            onBluetoothDisabled()
            return
        }
        
        printLog(self, "connectPeripheral", "")
        
        connectionTimer?.invalidate()
        
        if cm == nil {
            //            println(self.description)
            printLog(self, (__FUNCTION__), "No central Manager found, unable to connect peripheral")
            return
        }
        
        stopScan()
        
        //Show connection activity alert view
        let alert = UIAlertController(title: "Connecting …", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        //        let aaCancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler:{ (aa:UIAlertAction!) -> Void in
        //            self.currentAlertView = nil
        //            self.abortConnection()
        //        })
        //        alert.addAction(aaCancel)
        currentAlertView = alert
        self.delegate.presentViewController(alert, animated: true, completion: nil)
        
        //Cancel any current or pending connection to the peripheral
        if peripheral.state == CBPeripheralState.Connected || peripheral.state == CBPeripheralState.Connecting {
            cm!.cancelPeripheralConnection(peripheral)
        }
        
        //Connect
        currentPeripheral = BLEPeripheral(peripheral: peripheral, delegate: self)
        cm!.connectPeripheral(peripheral, options: [CBConnectPeripheralOptionNotifyOnDisconnectionKey: NSNumber(bool:true)])
        
        connectionMode = mode
        connectionStatus = ConnectionStatus.Connecting
        
        // Start connection timeout timer
        connectionTimer = NSTimer.scheduledTimerWithTimeInterval(connectionTimeOutIntvl, target: self, selector: Selector("connectionTimedOut:"), userInfo: nil, repeats: false)
    }
    
    

}
