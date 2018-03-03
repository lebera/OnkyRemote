//
//  OnkyoUDPClient.swift
//  OnkyRemote
//
//  Created by lebera on 02/03/2018.
//  Copyright © 2018 Onkyo. All rights reserved.
//

import Foundation

class OnkyoUDPClient : UDPClient {
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
    open func autodetect(name: String,ip: String,tmout: Int) -> [String] {
        var ret:[String] = [name, ip]
        self.enableBroadcast()
        let error = self.sendcmd(command: "!xECNQSTN")
        NSLog("Debug: Sending command -> '%@'", "!xECNQSTN")
        if (error.isFailure) {
            NSLog("Error: Sending command -> '%@' : %@", "!xECNQSTN",String(describing: error))
            ret[0] = "UNDEFINED"
            return ret
        }
        let val = self.recv(1024,tmout)
        if (name == "") { // Onkyo name auto detection
            if (val.0 != nil) {
                let str = String(bytes: val.0!, encoding: String.Encoding.ascii)!
                let NSstr = str as NSString
                if (NSstr.contains("!1ECN") && NSstr.contains("/")) {
                    let spi1 = NSstr.range(of: "!1ECN")
                    let spi2 = NSstr.range(of: "/")
                    let oname = NSstr.substring(with: NSRange(location: spi1.location+5, length: (spi2.location-spi1.location-5)))
                    ret[0] = oname
                    NSLog("Debug: Reading command status <- auto detecting Onkyo name '%@'", ret[0])
                } else {
                    NSLog("Error: Reading command status <- incorrect value '%@'",NSstr)
                    ret[0] = "UNDEFINED"
                }
            } else {
                NSLog("Error: Reading command status <- no (name) value")
                ret[0] = "UNDEFINED"
            }
        } else  {
            NSLog("Debug: Forcing Onkyo name '%@'",ret[0])
        }
        if (ip == "0.0.0.0") { // Onkyo name auto detection
            if (val.1 != "0.0.0.0") {
                ret[1] = val.1
                NSLog("Debug: Reading command status <- auto detecting Onkyo ip adrress '%@'", ret[1])
            } else {
                NSLog("Error: Reading command status <- no (ip) value")
                ret[0] = "ERROR"
            }
        } else  {
            NSLog("Debug: Forcing Onkyo ip address '%@'",ret[1])
        }
        return ret
    }
}
