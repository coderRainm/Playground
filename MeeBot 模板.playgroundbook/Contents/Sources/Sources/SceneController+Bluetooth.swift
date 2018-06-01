//
//  SceneController.swift
//  JimuPlaygroundBook
//
//  Created by hechao on 2016/12/26.
//  Copyright © 2016年 UBTech Inc. All rights reserved.
//

import UIKit
import PlaygroundSupport
import CoreBluetooth
import PlaygroundBluetooth

var connectState = ConnectState.disconnected
var hasError = false

extension SceneController:RobotProtocol{
    func robotDidUpdate(error:PhoneStateError?){
    }
    func robotDidScan(_ uuid:UUID, name:String){
    }
    func robotWillConnect(_ uuid:UUID){
        connectState = .connecting
        hasError = false
        if let p = Meebot.shared.getCentralManager().connectedPeripherals.first(where:{$0.identifier == uuid}){
            playgroundBluetoothConnectionView.setIcon(smallSpinningImage(), forPeripheral:p)
        }
        loadingView.isHidden = false
    }
    func robotDidConnect(_ uuid:UUID, error:ConnectError?){
        if let _ = error {
            connectState = .checking
            connecting = false
            loadingView.isHidden = true
            tryStarting()
        }else{
            connectState = .disconnected
            loadingView.isHidden = false
        }
        
        if let p = Meebot.shared.getCentralManager().connectedPeripherals.first(where:{$0.identifier == uuid}){
            if let _ = error {
                if let icon = UIImage(named:"Images/bluetooth_not_connect") {
                    playgroundBluetoothConnectionView.setIcon(icon, forPeripheral:p)
                }
            }else{
                playgroundBluetoothConnectionView.setIcon(smallSpinningImage(), forPeripheral:p)
            }
        }
    }
    func robotDidReceive(_ uuid:UUID?, response:Data?, error:TransmissionError?){
    }
    func robotDidCancelAllWriting(_ uuid:UUID?){
    }
    func robotDidDisconnect(_ uuid:UUID?, error:DisconnectError?){
        connectState = .disconnected
        loadingView.isHidden = true
        if let p = Meebot.shared.getCentralManager().connectedPeripherals.first(where:{$0.identifier == uuid}){
            if let _ = error {
                if let icon = UIImage(named:"Images/bluetooth_not_connect") {
                    playgroundBluetoothConnectionView.setIcon(icon, forPeripheral:p)
                }
            }
        }
    }
    
    func robotDidHandShake(_ uuid:UUID){   //1，8，5命令回复正常
        connectState = .ready
        connecting = false
        loadingView.isHidden = true
        tryStarting()
        if let p = Meebot.shared.getCentralManager().connectedPeripherals.first(where:{$0.identifier == uuid}){
            if let icon = UIImage(named: "Images/bluetooth_connectted") {
                playgroundBluetoothConnectionView.setIcon(icon, forPeripheral:p)
            }
        }
    }
    func robotDidUpdateDevice(_ uuid:UUID, info:DeviceInfo){
        guard let p = Meebot.shared.getCentralManager().connectedPeripherals.first(where:{$0.identifier == uuid}) else {
            return
        }

        var power:Double?
        if let pw = info.power?.percent{
            power = max((Double(pw) - 0.25), 0)/0.75
        }
        playgroundBluetoothConnectionView.setBatteryLevel(power, forPeripheral:p)
        
        if info.error.hasError || info.servo?.count ?? 6 != 6 {
            hasError = true
            connecting = false
            loadingView.isHidden = true
            tryStarting()
            if info.error.servo.contains(.version){
                playgroundBluetoothConnectionView.setFirmwareStatus(.outOfDate, forPeripheral:p)
            }
            if let icon = UIImage(named: "Images/connect_issue") {
                playgroundBluetoothConnectionView.setIcon(icon, forPeripheral:p)
            }
        }
    }
    
    fileprivate func smallSpinningImage()->UIImage{
        var arr = [UIImage]()
        for i in 0..<18 {
            if let img = UIImage(named: "Images/spin_small/spin_small_\(i)") {
                arr.append(img)
            }
        }
        return UIImage.animatedImage(with: arr, duration: 1) ?? UIImage(named: "Images/spin_small/spin_small_0")!
    }
}

extension SceneController:PlaygroundBluetoothConnectionViewDelegate, PlaygroundBluetoothConnectionViewDataSource {
    public func connectionView(_ connectionView: PlaygroundBluetoothConnectionView, itemForPeripheral peripheral: CBPeripheral, withAdvertisementData advertisementData: [String : Any]?) -> PlaygroundBluetoothConnectionView.Item {
        print("withAdvertisementData")
        
        let name = peripheral.name ?? "Unknown Device"
        var img:UIImage
        if hasError {
            img = UIImage(named:"Images/connect_issue")!
        }else if connectState == .disconnected {
            img = UIImage(named: "Images/bluetooth_not_connect")!
        }else{
            img = smallSpinningImage()
        }
        liveLog("\(hasError)  \(connectState)")
        return PlaygroundBluetoothConnectionView.Item(name: name, icon: img, issueIcon: UIImage(named:"Images/connect_issue")!)
    }

    public func connectionView(_ connectionView: PlaygroundBluetoothConnectionView, titleFor state: PlaygroundBluetoothConnectionView.State) -> String {
        liveLog(state)
 
        var title = NSLocalizedString("Error", comment:"Default Bluetooth UI Hint")
        
        switch state {
        case .noConnection:
            title = NSLocalizedString("Connect MeeBot", comment:"Bluetooth UI")
            break
        case .connecting:
            title = NSLocalizedString("Connecting MeeBot", comment:"Bluetooth UI")
            break
        case .searchingForPeripherals:
            title = NSLocalizedString("Searching for MeeBot", comment:"Bluetooth UI")
            break
        case .selectingPeripherals:
            title = NSLocalizedString("Select a MeeBot", comment:"Bluetooth UI")
            break
        case .connectedPeripheralFirmwareOutOfDate:
            
            title = NSLocalizedString("Firmware out of date", comment:"Bluetooth UI")
            break
        default:
            break
        }
        
        return title
    }
    
    public func connectionView(_ connectionView: PlaygroundBluetoothConnectionView, firmwareUpdateInstructionsFor peripheral: CBPeripheral) -> String {
        return NSLocalizedString("### Please update firmware.\n1. Search and download the Jimu app from app store.\n2. Connect to MeeBot via Bluetooth in the Jimu app and follow the instructions in the app to update firmware in MeeBot.", comment:"Bluetooth UI")
    }
    
    private func nameFilter(_ name:String)->Bool{
        return name.lowercased().contains("jimu")
    }
    func connectionView(_ connectionView: PlaygroundBluetoothConnectionView,
                        shouldDisplayDiscovered peripheral: CBPeripheral,
                        withAdvertisementData advertisementData: [String: Any]?,
                        rssi: Double) -> Bool {
        if let name = peripheral.name, nameFilter(name) {
            return true
        }
        return false
    }

    func connectionView(_ connectionView: PlaygroundBluetoothConnectionView,
                        shouldConnectTo peripheral: CBPeripheral,
                        withAdvertisementData advertisementData: [String: Any]?,
                        rssi: Double) -> Bool {
        return true
    }
    func connectionView(_ connectionView: PlaygroundBluetoothConnectionView,
                        willDisconnectFrom peripheral: CBPeripheral) {
    }
    
}
