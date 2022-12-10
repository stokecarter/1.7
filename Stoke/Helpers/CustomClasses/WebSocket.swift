//
//  WebSocket.swift
//  STOKE
//
//  Created by Arpit Srivastava on 19/04/21.
//  Copyright © 2021 Appinventiv. All rights reserved.
//

import Foundation
import Starscream
import SocketIO
import SwiftyJSON


struct Environment {
    
    static var socketUrl:String{
        switch server {
        case .dev:
            return "http://chatroomsdevapi.appskeeper.in:7151"
        case .qa:
            return "http://chatroomsqaapi.appskeeper.in:7152"
        case .staging:
            return "http://chatroomsstgapi.appskeeper.in:7153"
        case .pre_pod:
            return "https://preprodapi.stokeapp.live/"
        default:
            return "https://api.stokeapp.live/"
        }
    }
}


import Foundation
import SocketIO


enum EventListnerKeys : String {
    case joinRoom = "join_chatroom"
    case commnet  = "comment"
    case commentReaction = "comment_reaction"
    case didConnect = "connect"
    case didDisConnect = "disconnect"
    case reportedCommnet = "reported_comments"
    case approveComment = "approve_comment"
}

class SocketIOManager: NSObject {
    
    var socket: SocketIOClient?
    var manager: SocketManager?
    
    override init() {
        
        super.init()
        self.initializeSocket()
    }
    
    func initializeSocket(){
        
        let accessToken = UserModel.main.accessToken
        let param:JSONDictionary = ["authorization": accessToken]
        self.manager = SocketManager(socketURL: URL(string: Environment.socketUrl)!, config: [.log(true), .forcePolling(false), .connectParams(param),.reconnects(true)])
        
        self.socket = manager?.defaultSocket
    }
    
    static let instance = SocketIOManager()
    
    fileprivate var socketHandlerArr = [((()->Void))]()
    typealias ObjBlock = @convention(block) () -> ()
    
    func connectSocket(handler:(()->Void)? = nil){
        
        if self.socket?.status == .connected{
            handler?()
            return
        }else{
            if let handlr = handler{
                if !self.socketHandlerArr.contains(where: { (handle) -> Bool in
                    let obj1 = unsafeBitCast(handle as ObjBlock, to: AnyObject.self)
                    let obj2 = unsafeBitCast(handlr as ObjBlock, to: AnyObject.self)
                    return obj1 === obj2
                }){
                    self.socketHandlerArr.append(handlr)
                }
            }
            
            if self.socket?.status != .connecting{
                self.socket?.connect()
            }
        }
        
        self.socket?.on(EventListnerKeys.didConnect.rawValue) { data, ack in
            for handler in self.socketHandlerArr{
                handler()
//                break
            }
            self.socketHandlerArr = []
        }
        
        self.socket?.on(EventListnerKeys.didDisConnect.rawValue) { data, ack in
            self.initializeSocket()
        }
    }
    
    
    func closeConnection() {
        socket?.disconnect()
    }
    
    //MARK:- Emit
    func emit(with event: EventListnerKeys , _ params : JSONDictionary?){
        if self.socket?.status != .connected{
            self.connectSocket(handler: {
                self.emitWithACK(withTimeoutAfter: 15, event: event, params: params, array: nil)
            })
        } else {
            self.emitWithACK(withTimeoutAfter: 15, event: event, params: params, array: nil)
        }
    }
    
    func emitArray(with event: EventListnerKeys , _ array : [String]){
        
        if self.socket?.status != .connected{
            self.connectSocket(handler: {
                self.emitWithACK(withTimeoutAfter: 15, event: event, params: nil, array: nil)
            })
        } else {
            self.emitWithACK(withTimeoutAfter: 15, event: event, params: nil, array : array)
        }
    }
    
    private func emitWithACK(withTimeoutAfter seconds: Double, event: EventListnerKeys, params : JSONDictionary?, array:[Any]?){
        
        var ack : OnAckCallback? = nil
        
        if let tempParams = params{
            
            ack = self.socket?.emitWithAck(event.rawValue, tempParams)
        }else if let tempArray = array{
            
            ack = self.socket?.emitWithAck(event.rawValue, tempArray)
        }else{
            
            ack = self.socket?.emitWithAck(event.rawValue)
        }
        
        ack?.timingOut(after: seconds, callback: { (data) in
            
        })
    }
    
    func listenSocket(_ event:EventListnerKeys, callBack: @escaping ([Any]) -> () ){
        socket?.on(event.rawValue, callback: { (data, emiter) in
            callBack(data)
        })
    }
    
    func offTheEvent(_ event:EventListnerKeys) {
        socket?.off(event.rawValue)
    }
}
