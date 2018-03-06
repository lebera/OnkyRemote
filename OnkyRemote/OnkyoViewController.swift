//
//  OnkyoViewController.swift
//  OnkyRemote
//
//  Created by lebera on 02/01/2018.
//  Copyright © 2018 Onkyo. All rights reserved.
//
import Cocoa

class OnkyoViewController: NSViewController {

    @IBOutlet var powerButton: NSButton!
    @IBOutlet var localButton: NSButton!
    @IBOutlet var button1: NSButton!
    @IBOutlet var button2: NSButton!
    @IBOutlet var button3: NSButton!
    @IBOutlet var volume: NSSlider!
    @IBOutlet var Name: NSTextFieldCell!
    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
    let client:OnkyoClient = OnkyoClient(address: AppDelegate.Config.OnkyoClient.address, port: (Int32)(AppDelegate.Config.OnkyoClient.port)!)

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        Name.stringValue = AppDelegate.Config.OnkyoClient.name
        powerButton.title = AppDelegate.Config.PowerButton.nameOff
        localButton.title = AppDelegate.Config.LocalButton.name
        button1.title = AppDelegate.Config.Button1.name
        button2.title = AppDelegate.Config.Button2.name
        button3.title = AppDelegate.Config.Button3.name
        volume.maxValue = (Double)(AppDelegate.Config.Volume.maxVol)!
        volume.doubleValue = (Double)(AppDelegate.Config.Volume.defaultVol)!
}
    
    
}

extension OnkyoViewController {
    // MARK: Storyboard instantiation
    static func freshController() -> OnkyoViewController {
        //1.
        let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
        //2.
        let identifier = NSStoryboard.SceneIdentifier(rawValue: "OnkyoViewController")
        //3.
        guard let viewcontroller = storyboard.instantiateController(withIdentifier: identifier) as? OnkyoViewController else {
            fatalError("OnkyRemote App is corrupted")
        }
        return viewcontroller
    }
    
    func clientConnect() {
        switch client.connect(timeout: (Int)(AppDelegate.Config.OnkyoClient.timeout)!) {
        case .success:
            Name.stringValue = AppDelegate.Config.OnkyoClient.name
            powerButton.title = AppDelegate.Config.PowerButton.nameOn
            powerButton.state = NSControl.StateValue.on
            NSLog("Debug: Client is connected to %@:%@",AppDelegate.Config.OnkyoClient.address,AppDelegate.Config.OnkyoClient.port)
            sendcmd(command: AppDelegate.Config.PowerButton.commandOn)
            readVolumeStatus()
            readButtonStatus()
        case .failure(let error):
            Name.stringValue = "ERROR"
            powerButton.title = AppDelegate.Config.PowerButton.nameOff
            powerButton.state = NSControl.StateValue.off
            localButton.state = NSControl.StateValue.off
            button1.state = NSControl.StateValue.off
            button2.state = NSControl.StateValue.off
            button3.state = NSControl.StateValue.off
            volume.doubleValue = (Double)(AppDelegate.Config.Volume.defaultVol)!
            NSLog("Error: Client connection failure to %@:%@ : '%@'", AppDelegate.Config.OnkyoClient.address,AppDelegate.Config.OnkyoClient.port,String(describing: error))
       }
    }
    
    func clientClose() {
        sendcmd(command: AppDelegate.Config.PowerButton.commandOff)
        client.close()
        stoplocalradio()
        powerButton.title = AppDelegate.Config.PowerButton.nameOff
        powerButton.state = NSControl.StateValue.off
        localButton.state = NSControl.StateValue.off
        button1.state = NSControl.StateValue.off
        button2.state = NSControl.StateValue.off
        button3.state = NSControl.StateValue.off
        volume.doubleValue = (Double)(AppDelegate.Config.Volume.defaultVol)!
        NSLog("Debug: Client is disconnected")
    }
        
    func readVolumeStatus() {
        sendcmd(command: AppDelegate.Config.Volume.command+"QSTN")
        var txt = client.read(1024, timeout: (Int)(AppDelegate.Config.OnkyoClient.timeout)!)
        while (txt != nil) {
                let str = String(bytes: txt!, encoding: String.Encoding.ascii)!
                let NSstr = str as NSString
                if (NSstr.contains(AppDelegate.Config.Volume.command)) { // Capture Volume Status
                    let spi = NSstr.range(of: AppDelegate.Config.Volume.command)
                    let volhex = NSstr.substring(with: NSRange(location: spi.location + AppDelegate.Config.Volume.command.lengthOfBytes(using: String.Encoding.ascii), length: 2))
                    let voldec = Int(volhex, radix: 16)
                    NSLog("Debug: Reading Volume status <- value '%@'", String(describing: voldec))
                    volume.doubleValue = (Double)(voldec!)
                    txt = nil
                } else {
                    txt = client.read(1024, timeout: 1)
                }
       }
    }

    func readButtonStatus() {
        sendcmd(command: AppDelegate.Config.OnkyoClient.command+"QSTN")
        var txt = client.read(1024, timeout: (Int)(AppDelegate.Config.OnkyoClient.timeout)!)
        while (txt != nil) {
            let str = String(bytes: txt!, encoding: String.Encoding.ascii)!
            let NSstr = str as NSString
            if (NSstr.contains(AppDelegate.Config.OnkyoClient.command)) { // Capture Command Status
                let spi = NSstr.range(of: AppDelegate.Config.OnkyoClient.command)
                let val = NSstr.substring(with: NSRange(location: spi.location, length: AppDelegate.Config.OnkyoClient.command.lengthOfBytes(using: String.Encoding.ascii) + 2))
                NSLog("Debug: Reading command status <- value '%@'", val)
                if (AppDelegate.Config.Button1.command.contains(val)) {
                    button1.state = NSControl.StateValue.on
                } else if (AppDelegate.Config.Button2.command.contains(val)) {
                    button2.state = NSControl.StateValue.on
                } else if (AppDelegate.Config.Button3.command.contains(val)) {
                    button3.state = NSControl.StateValue.on
                }
                txt = nil
            } else {
                txt = client.read(1024, timeout: 1)
            }
        }
    }

    func startlocalradio () {
        let startres = Bundle.main.url(forResource: "start", withExtension: "sh", subdirectory: "castSW")
        let task = Process()
        task.launchPath = startres?.path
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        let outHandle = pipe.fileHandleForReading
        
        task.launch()
        
        outHandle.readabilityHandler = { pipe in
            if let line = String(data: pipe.availableData, encoding: String.Encoding.utf8) {
                if (line != "") { NSLog("Debug: castSW/start.sh script '%@'", line) }
            }
        }
    }

    func stoplocalradio () {
        let stopres = Bundle.main.url(forResource: "stop", withExtension: "sh", subdirectory: "castSW")
        let task = Process()
        task.launchPath = stopres?.path
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        let outHandle = pipe.fileHandleForReading
        
        task.launch()
        
        outHandle.readabilityHandler = { pipe in
            if let line = String(data: pipe.availableData, encoding: String.Encoding.utf8) {
                if (line != "") { NSLog("Debug: castSW/stop.sh script '%@'", line) }
            }
        }
    }

    
    @IBAction func power(_ sender: NSButton) {
        if (powerButton.state == NSControl.StateValue.off) {
            NSLog("Debug: Powering Off ...")
            clientClose()
        } else {
            NSLog("Debug: Powering On ...")
            clientConnect()
        }
    }

    func sendcmd (command : String) -> Bool {
        for name in command.components(separatedBy: ",") {
            if (name=="") {
                sleep(1)
            } else if (name=="cast") {
                startlocalradio()
                NSLog("Debug: Starting icecast & darkice ...")
            } else if (name=="nocast") {
                stoplocalradio()
                NSLog("Debug: Stopping icecast & darkice ...")
            } else if (name=="exit") {
                NSLog("Debug: Stopping App '%@'", "...")
                clientClose()
                NSApp.terminate(self)
            } else {
                powerButton.title = AppDelegate.Config.PowerButton.nameOn
                powerButton.state = NSControl.StateValue.on
                var error: Result?
                error = client.sendcmd(command: name as NSString)
                NSLog("Debug: Sending command -> '%@'", name)
                if (error?.isFailure)! {
                    NSLog("Error: Sending command -> '%@' : %@", name,String(describing: error))
                    powerButton.title = AppDelegate.Config.PowerButton.nameOff
                    powerButton.state = NSControl.StateValue.off
                    return false
                }
            }
        }
        return true
    }
    
    @IBAction func local(_ sender: NSButton) {
        if ((powerButton.state == NSControl.StateValue.off) && (AppDelegate.Config.LocalButton.command != "exit")){
            localButton.state = NSControl.StateValue.off
            return
        }
        NSLog("Debug: Connecting to "+AppDelegate.Config.LocalButton.name+" ...")
        button1.state = NSControl.StateValue.off
        button2.state = NSControl.StateValue.off
        button3.state = NSControl.StateValue.off
        if (sendcmd(command: AppDelegate.Config.LocalButton.command)==false) {
            localButton.state = NSControl.StateValue.off
        }
        localButton.state = NSControl.StateValue.on
    }

    @objc func menu1(_ sender: AnyObject) {
        let val: Int = sender.representedObject as! Int
        NSLog("Debug: Connecting to "+AppDelegate.Config.Button1.name+" ("+AppDelegate.Config.Button1.menulist[val-1].name+") ...")
        sendcmd(command: AppDelegate.Config.Button1.menulist[val-1].command)
    }

    @IBAction func button1(_ sender: NSButton) {
        if (powerButton.state == NSControl.StateValue.off) {
            button1.state = NSControl.StateValue.off
            return
        }
        localButton.state = NSControl.StateValue.off
        button2.state = NSControl.StateValue.off
        button3.state = NSControl.StateValue.off
        if (AppDelegate.Config.Button1.menuItems=="0") {
            NSLog("Debug: '%@'", "Connecting to "+AppDelegate.Config.Button1.name+" ...")
            if (sendcmd(command: AppDelegate.Config.Button1.command)==false) {
                button1.state = NSControl.StateValue.off
            }
            button1.state = NSControl.StateValue.on
        } else {
            let menu = NSMenu()
            var item = NSMenuItem()
            for i in 1 ... (Int)(AppDelegate.Config.Button1.menuItems)! {
                item = NSMenuItem(title: AppDelegate.Config.Button1.menulist[i-1].name, action: #selector(OnkyoViewController.menu1(_:)), keyEquivalent: "")
                item.representedObject = i
                menu.addItem(item)
            }
            let p = NSPoint(x: 0, y: sender.frame.height)
            menu.popUp(positioning: nil, at: p, in: sender)
            button1.state = NSControl.StateValue.off
        }
    }

    @objc func menu2(_ sender: AnyObject) {
        let val: Int = sender.representedObject as! Int
        NSLog("Debug: Connecting to "+AppDelegate.Config.Button1.name+" ("+AppDelegate.Config.Button2.menulist[val-1].name+") ...")
        sendcmd(command: AppDelegate.Config.Button2.menulist[val-1].command)
    }
    
    @IBAction func button2(_ sender: NSButton) {
        if (powerButton.state == NSControl.StateValue.off) {
            button2.state = NSControl.StateValue.off
            return
        }
        localButton.state = NSControl.StateValue.off
        button1.state = NSControl.StateValue.off
        button3.state = NSControl.StateValue.off
        if (AppDelegate.Config.Button2.menuItems=="0") {
            NSLog("Debug: Connecting to "+AppDelegate.Config.Button2.name+" ...")
            if (sendcmd(command: AppDelegate.Config.Button2.command)==false) {
                button2.state = NSControl.StateValue.off
            }
            button2.state = NSControl.StateValue.on
        } else {
            let menu = NSMenu()
            var item = NSMenuItem()
            for i in 1 ... (Int)(AppDelegate.Config.Button2.menuItems)! {
                item = NSMenuItem(title: AppDelegate.Config.Button2.menulist[i-1].name, action: #selector(OnkyoViewController.menu2(_:)), keyEquivalent: "")
                item.representedObject = i
                menu.addItem(item)
            }
            let p = NSPoint(x: 0, y: sender.frame.height)
            menu.popUp(positioning: nil, at: p, in: sender)
            button2.state = NSControl.StateValue.off
        }
    }
    
    @objc func menu3(_ sender: AnyObject) {
        let val: Int = sender.representedObject as! Int
        NSLog("Debug: Connecting to "+AppDelegate.Config.Button3.name+" ("+AppDelegate.Config.Button3.menulist[val-1].name+") ...")
        sendcmd(command: AppDelegate.Config.Button3.menulist[val-1].command)
    }
    
   @IBAction func button3(_ sender: NSButton) {
        if (powerButton.state == NSControl.StateValue.off) {
            button3.state = NSControl.StateValue.off
            return
        }
        localButton.state = NSControl.StateValue.off
        button1.state = NSControl.StateValue.off
        button2.state = NSControl.StateValue.off
        if (AppDelegate.Config.Button3.menuItems=="0") {
            NSLog("Debug: Connecting to "+AppDelegate.Config.Button3.name+" ...")
            if (sendcmd(command: AppDelegate.Config.Button3.command)==false) {
                button3.state = NSControl.StateValue.off
            }
            button3.state = NSControl.StateValue.on
       } else {
            let menu = NSMenu()
            var item = NSMenuItem()
            for i in 1 ... (Int)(AppDelegate.Config.Button3.menuItems)! {
                item = NSMenuItem(title: AppDelegate.Config.Button3.menulist[i-1].name, action: #selector(OnkyoViewController.menu3(_:)), keyEquivalent: "")
                item.representedObject = i
                menu.addItem(item)
            }
            let p = NSPoint(x: 0, y: sender.frame.height)
            menu.popUp(positioning: nil, at: p, in: sender)
            button3.state = NSControl.StateValue.off
        }
    }
    
    @IBAction func volume(_ sender: NSSlider) {
        if (powerButton.state == NSControl.StateValue.off) {
            sender.integerValue = (Int)(AppDelegate.Config.Volume.defaultVol)!
            return
        }
        let val = sender.integerValue
        let cmd = AppDelegate.Config.Volume.command + "%002X"
        let st = NSString(format:cmd as NSString, val)
        if (sendcmd(command: st as String)==false) {
            sender.integerValue = (Int)(AppDelegate.Config.Volume.defaultVol)!
        }
    }
    
}

