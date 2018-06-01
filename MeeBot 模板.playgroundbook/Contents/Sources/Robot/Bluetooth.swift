//
//  BLE.swift
//  BLE
//
//  Created by WG on 2016/11/3.
//  Copyright © 2016年 WG. All rights reserved.
//
/*
 1.可同时连接多个设备并同时进行通信
 2.同时只存在一个请求，高优先级的优先，同优先级的遵守FIFO规则
 3.运行和回调在同一个指定的队列，如果指定队列为空，则会调整到main队列
 4.方法scanning和connected仅在指定队列安全可靠
 5.除读写数据格式错误之外的故障发生时，会自动断开连接
 */
import Foundation
import CoreBluetooth

import PlaygroundBluetooth

import os

class Bluetooth: NSObject {
    
    required init(serviceUuid:CBUUID, queue: DispatchQueue? = nil) {
        super.init()
        _dispatchQueue = queue != nil ? queue! : DispatchQueue.main
//        manager=CBCentralManager.init(delegate: self, queue: _dispatchQueue)
        
        playgroundCentralManager = PlaygroundBluetoothCentralManager(services: nil, queue: _dispatchQueue)
//        playgroundCentralManager = PlaygroundBluetoothCentralManager(services: [serviceUuid], allowsMultipleConnections: false, queue: _dispatchQueue)
        playgroundCentralManager.delegate = self
        if playgroundCentralManager.state == .poweredOn {
            playgroundCentralManager.connectToLastConnectedPeripheral()
        }
    }
    
    
    //interface
    public weak var delegate:BluetoothProtocol?
    //仅在指定线程安全
    // TODO CHANGE THIS GETTER AND SETTER TO JUST USE playgroundCentralManager
    public var scanning:Bool{
        get{
            if #available(iOS 9.0, *) {
                _scanning = playgroundCentralManager.scanning
            }
            return _scanning
        }
    }
    
    public var dispatchQueue:DispatchQueue{get{return _dispatchQueue}}
    public var identifierIndex:Int!
    public var serviceUuid:CBUUID!
    public var readCharacteristicUuid:CBUUID!
    public var writeCharacteristicUuid:CBUUID!
    public var writeDataFormatCheck:((Data)->Bool)!
    public var readDataFormatCheck:((Data)->Bool)!
    public var nameFilter:((String)->Bool)?
    public var devidePackage:((Data)->[Data]?)!
    
    public func update(){
        dispatchQueue.async {
            self.checkState()
        }
    }
    
    public func scan(){
        dispatchQueue.async {
            print(self.playgroundCentralManager.state.rawValue)
            if (self.playgroundCentralManager.state == .poweredOn){
                self.playgroundCentralManager.scanning = true
            }
            self._scanning = true
        }
    }
    
    public func stopScan(){
        dispatchQueue.async {
            self.playgroundCentralManager.scanning = false
            self._scanning = false
        }
    }
    
    public func connect(_ uuid:UUID){
        // TODO: if we call this connect() function when we already have another connection, it would call the callback provided in the call and will also call the "didFailToConnect" delegate, since we specified that we don't support multi connections.  So we need to keep track of if we are already currently connected to another device before we call this.
        dispatchQueue.async {
            self.playgroundCentralManager.connect(toPeripheralWithUUID: uuid, timeout: 5, callback: nil)
        }
    }
    
    public func disconnect(_ uuid:UUID){
        dispatchQueue.async {
            // TODO: We need to figure out if we still need this function after the UI is changed to the Apple one
            
            
            if let peripheral = (self.playgroundCentralManager.connectedPeripherals.first { $0.identifier == uuid }) {
            
                // connectedPeripherals
                self.playgroundCentralManager.disconnect(from: peripheral)
            }
        }
    }
    
    //仅在指定线程安全
    public func connectState(_ uuid:UUID)->ConnectState{
        // TODO: We need to figure out if we still need this function after the UI is changed to the Apple one
        
        
        
        var res:ConnectState = .disconnected

         // TODO: replace peripheral with _ if not needed
        if let peripheral = (self.playgroundCentralManager.connectedPeripherals.first { $0.identifier == uuid }) {
            
            // connectedPeripherals
            res = .connected
        }

        return res
        
        
        
        
//        var res:ConnectState = .disconnected
//        if let p = self.manager.retrievePeripherals(withIdentifiers: [uuid]).first{
//            switch p.state {
//            case .disconnected:
//                res = .disconnected
//            case .connecting:
//                res = .connecting
//            case .connected:
//                if context[uuid]?.characteristic != nil{
//                    res = .connected
//                }else{
//                    res = .connecting
//                }
//            default:Void()
//            }
//        }
//        return res
    }
    
    public func write(_ uuid:UUID, data:Data, priority:WritePriority = .normal){
        dispatchQueue.async {
            // TODO: WE SHOULD SAVE THE peripheral SO THAT WE DON'T NEED TO KEEP SEARCHING FOR IT
            if self.writeDataFormatCheck(data){
                
                if let peripheral = (self.playgroundCentralManager.connectedPeripherals.first { $0.identifier == uuid }) {
                    var res = false
                    if peripheral.state == .connected{
                        if let tuple = self.context[uuid]{
                            if tuple.characteristic != nil{
                                res = true
                                self.context[uuid]!.data.append((data:data, priority:priority))
                                liveLog("enqueue cmd = \(data[self.identifierIndex])")
                                self.tryWriting(peripheral)
                            }
                        }
                    }
                    if !res{
                        self.delegate?.bluetoothDidReceive(uuid, response:nil, error:.unconnected, moreCammands: false)
                    }
                } else {
                    self.delegate?.bluetoothDidReceive(uuid, response:nil, error:.unexisting, moreCammands: false)
                }
            }else{
                
                self.delegate?.bluetoothDidReceive(uuid, response:nil, error: .badWrite, moreCammands: false)
                
            }
        }
    }
    
    public func cancelAllWriting(_ uuid:UUID) {
        dispatchQueue.async {
            print("cancelAllWriting \(uuid)")
            self.context[uuid]?.data = []
            self.delegate?.bluetoothDidCancelWriting(uuid)
        }
    }
    
    //inner only
//    var manager:CBCentralManager!
    public var playgroundCentralManager:PlaygroundBluetoothCentralManager!
    lazy var scannedPeers:Set<CBPeripheral> = Set()//被扫描过的，元素只增不减，防止连接和断开时的系统错误
    lazy var context = Dictionary<UUID, ContextItem>()//连接过的
    lazy var initializing = false
    lazy var _scanning = false
    var _dispatchQueue:DispatchQueue!
    
    func tryWriting(_ peripheral:CBPeripheral) {
        var res = false
        if peripheral.state == .connected{
            if var tuple = context[peripheral.identifier]{
                if tuple.characteristic != nil{
                    res = true
                    if tuple.identifier == nil && tuple.data.count>0{
                        var idx = 0
                        for (i, e) in tuple.data.enumerated(){
                            if e.priority.rawValue > tuple.data[idx].priority.rawValue{
                                idx = i
                            }
                        }
                        let e = tuple.data[idx]
                        tuple.data.remove(at: idx)
                        peripheral.writeValue(e.data, for: tuple.characteristic!, type: tuple.characteristic!.properties.contains(.write) ? .withResponse : .withoutResponse)
                        context[peripheral.identifier] = ContextItem(identifier:e.data[identifierIndex], time:CFAbsoluteTimeGetCurrent(), characteristic:tuple.characteristic, data:tuple.data)
                        print("did write cmd = \(e.data[self.identifierIndex]) data = \(e.data.string)")
                        liveLog("did write cmd = \(e.data[self.identifierIndex]) data = \(e.data.string)")
                    }
                }
            }
        }
        if !res{
            context[peripheral.identifier] = ContextItem(identifier:nil, time:0, characteristic:nil, data:[])
            delegate?.bluetoothDidReceive(peripheral.identifier, response:nil, error: .unconnected, moreCammands: false)
        }
    }
    
    func checkState() {
        print("manager state:\(playgroundCentralManager.state.rawValue)")
        switch playgroundCentralManager.state {
        case .unsupported:
            delegate?.bluetoothDidUpdate(error: .unsupported)
        case .poweredOn:
            delegate?.bluetoothDidUpdate(error: nil)
//            if _scanning{
//                manager.scanForPeripherals(withServices: nil)
//            }
        case .unauthorized:
            delegate?.bluetoothDidUpdate(error:.unauthorized)
        case .poweredOff:
            delegate?.bluetoothDidUpdate(error:.powerOff)
        default: Void()
        }
    }
}

public enum ConnectState:Int{
    case disconnected = 1
    case connecting
    case connected
    case checking   //service & characteristic
    case handShaking
    case ready
    //    @available(iOS 9.0, *)
    //    case disconnecting
}

public enum WritePriority:Int/*,Comparable*/{
    case low = 1
    case normal
    case high
    case highest
}

public enum PhoneStateError:Int{
    case unsupported    = 1
    case unauthorized
    case powerOff
}

public enum ConnectError:Int{
    case unexisting = 1
    case serviceUnsupported
    case characteristicsUnsupported
    case systemError
}

public enum DisconnectError:Int{
    case systemError    = 1
}

public enum TransmissionError:Int{
    case unexisting = 1
    case unconnected
    case badWrite
    case systemTransmissionError
    case badResponse
    case systemResponseError
}

protocol BluetoothProtocol: NSObjectProtocol{
    func bluetoothDidUpdate(error:PhoneStateError?)
    func bluetoothDidScan(_ uuid:UUID, name:String)
    func bluetoothDidConnect(_ uuid:UUID, error:ConnectError?)
    func bluetoothDidReceive(_ uuid:UUID, response:Data?, error:TransmissionError?, moreCammands:Bool)
    func bluetoothDidCancelWriting(_ uuid:UUID)
    func bluetoothDidDisconnect(_ uuid:UUID, error:DisconnectError?)
    func connect(_ uuid:UUID)
}

extension Bluetooth:PlaygroundBluetoothCentralManagerDelegate {
    func centralManagerStateDidChange(_ central: PlaygroundBluetoothCentralManager) {
        checkState()
        // TODO: if user turns off their bluttooch on iPad, this will be called.
        if central.state == .poweredOn {
            central.connectToLastConnectedPeripheral()
        }
    }
    
    
    func centralManager(_ centralManager: PlaygroundBluetoothCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        withAdvertisementData advertisementData: [String: Any]?,
                        rssi: Double) {
        
        
        // TODO: ADD name filter into the connection view filter
        if let name = peripheral.name {
            print("didDiscover \(name)")
            
            if nameFilter == nil || nameFilter!(name) {
                scannedPeers.insert(peripheral)
                delegate?.bluetoothDidScan(peripheral.identifier, name: name)
            }
        }
        
    }
    
    
    func centralManager(_ centralManager: PlaygroundBluetoothCentralManager,
                        willConnectTo peripheral: CBPeripheral){
        
        DispatchQueue.main.async {
            if let name = peripheral.name {
                liveLog("centralManager willConnectTo \(name)")
                self.delegate?.connect(peripheral.identifier)
            }
        }
    }
    
    func centralManager(_ centralManager: PlaygroundBluetoothCentralManager, didConnectTo peripheral: CBPeripheral) {
        if let name = peripheral.name {
            liveLog("didConnect \(name)")
        }
        
        peripheral.delegate = self
        var res = false
        let uuid = peripheral.identifier
        if let tuple = self.context[uuid]{
            if tuple.characteristic != nil{
                self.delegate?.bluetoothDidConnect(uuid, error:nil)
                res = true
            }
        }
        liveLog("\(self.serviceUuid)")
        if !res{
            peripheral.discoverServices([self.serviceUuid])
        }
    }
    
    
    func centralManager(_ centralManager: PlaygroundBluetoothCentralManager,
                        didFailToConnectTo peripheral: CBPeripheral,
                        error: Error?) {
        // TODO: check if context is still needed after this change
        liveLog("didFailToConnect \(peripheral.state == .connected)" )
        context[peripheral.identifier] = nil
        delegate?.bluetoothDidConnect(peripheral.identifier, error: .systemError)
    }
    
    
    public func centralManager(_ centralManager: PlaygroundBluetoothCentralManager, didDisconnectFrom peripheral: CBPeripheral, error: Error?) {
        // TODO: check if context is still needed after this change
        liveLog("didDisconnectPeripheral \(peripheral.state == .connected)" )
        context[peripheral.identifier] = nil
        delegate?.bluetoothDidDisconnect(peripheral.identifier, error: error == nil ? nil : .systemError)
    }
}


extension Bluetooth:CBPeripheralDelegate
{
    // TODO: we need to figure out what UIAlert or error prompt that we should show to users if we encounter write errors to our robots
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        liveLog("didDiscoverServices")
        if error == nil{
            var res = false
            if let arr = peripheral.services{
                if let i = arr.index(where: {$0.uuid == serviceUuid}){
                    peripheral.discoverCharacteristics([readCharacteristicUuid, writeCharacteristicUuid], for: arr[i])
                    res = true
                    liveLog("service \(peripheral.name)    \(peripheral.services![i].uuid)")
                }
            }
            if !res{
                context[peripheral.identifier] = nil
                delegate?.bluetoothDidConnect(peripheral.identifier, error: .serviceUnsupported)
                playgroundCentralManager.disconnect(from: peripheral)
//                manager.cancelPeripheralConnection(peripheral)
            }
        }else{
            context[peripheral.identifier] = nil
            delegate?.bluetoothDidConnect(peripheral.identifier, error: .systemError)
            playgroundCentralManager.disconnect(from: peripheral)
//            manager.cancelPeripheralConnection(peripheral)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        liveLog("didDiscoverCharacteristicsFor \(peripheral.name)")
        var read:CBCharacteristic?, write:CBCharacteristic?
        if service.characteristics != nil{
            service.characteristics?.forEach({
                if $0.uuid == readCharacteristicUuid {
                    read = $0
                }else if $0.uuid == writeCharacteristicUuid{
                    write = $0
                }
            })
        }
        if read != nil && write != nil{
            peripheral.setNotifyValue(true, for: read!)
            context[peripheral.identifier] = ContextItem(identifier:nil, time:0, characteristic:write, data:[])
            delegate?.bluetoothDidConnect(peripheral.identifier, error:nil)
            tryWriting(peripheral)
        }else{
            context[peripheral.identifier] = nil
            delegate?.bluetoothDidConnect(peripheral.identifier, error: .characteristicsUnsupported)
            playgroundCentralManager.disconnect(from: peripheral)
//            manager.cancelPeripheralConnection(peripheral)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        print("didWriteValueFor \(peripheral.state == .connected), error: \(error != nil)" )

        if error != nil{
            context[peripheral.identifier] = nil
            delegate?.bluetoothDidReceive(peripheral.identifier, response:nil, error: .systemTransmissionError, moreCammands: false)
            playgroundCentralManager.disconnect(from: peripheral)
//            manager.cancelPeripheralConnection(peripheral)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        let tuple = context[peripheral.identifier]
        print("read = \(characteristic.value?.string) cmd = \(tuple?.identifier) time = \(CFAbsoluteTimeGetCurrent() - (tuple?.time ?? 0))) error = \(error)")
        liveLog("read cmd = \(tuple?.identifier) time = \(CFAbsoluteTimeGetCurrent() - (tuple?.time ?? 0))) error = \(error)")
        if error == nil{
            var res = false
            let more = tuple?.data.count ?? 0 > 0
            if let data = characteristic.value{
                if let arr = devidePackage(data) {
                    for sub in arr {
                        res = true
                        delegate?.bluetoothDidReceive(peripheral.identifier, response: sub, error:nil, moreCammands: more)
                        if tuple?.identifier == data[identifierIndex]{
                            context[peripheral.identifier]?.identifier = nil
                            tryWriting(peripheral)
                        }
                    }
                }
            }
            if !res{
                //补快速换连收到00的漏洞
                if characteristic.value ==  Data(bytes:[0]) {
                    delegate?.bluetoothDidReceive(peripheral.identifier, response: Data(bytes:[0]), error:nil, moreCammands: more)
                }else {
                    //                context[peripheral.identifier] = nil //TODO:frank
                    delegate?.bluetoothDidReceive(peripheral.identifier, response:nil, error: .badResponse, moreCammands: more)
                    //                manager.cancelPeripheralConnection(peripheral)
                }
            }
        }else{
            context[peripheral.identifier]?.data.removeAll()
            delegate?.bluetoothDidReceive(peripheral.identifier, response:nil, error: .systemResponseError, moreCammands: false)
            playgroundCentralManager.disconnect(from: peripheral)
//            manager.cancelPeripheralConnection(peripheral)
        }
    }
}

struct ContextItem {
    var identifier:UInt8?
    var time:Double = 0
    var characteristic:CBCharacteristic?
    var data:[(data:Data, priority:WritePriority)] = []
}
