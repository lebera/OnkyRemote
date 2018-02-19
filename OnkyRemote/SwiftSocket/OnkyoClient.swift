//
//  OnkyoClient.swift
//  Onkyo
//
//  Created by lebera on 30/12/2017.
//  Copyright © 2017 lebera. All rights reserved.
//

import Foundation

class OnkyoClient : TCPClient {
    open func sendcmd(command: NSString) -> Result {
        var data = Data()
        data.append("ISCP", count: 4)
        data.append(0)
        data.append(0)
        data.append(0)
        data.append(16)
        data.append(0)
        data.append(0)
        data.append(0)
        data.append(UInt8(command.length))
        data.append(1)
        data.append(0)
        data.append(0)
        data.append(0)
        var buff = [UInt8]()
        var str:String = command as String
        buff += str.utf8
        data.append(buff, count: command.length)
        data.append(13)
        return send(data: data)
    }
}
