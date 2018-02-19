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
    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
    let client:OnkyoClient = OnkyoClient(address: AppDelegate.Config.OnkyoClient.address, port: (Int32)(AppDelegate.Config.OnkyoClient.port)!)

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        powerButton.title = AppDelegate.Config.PowerButton.nameOff
        localButton.title = AppDelegate.Config.LocalButton.name
        button1.title = AppDelegate.Config.Button1.name
        button2.title = AppDelegate.Config.Button2.name
        button3.title = AppDelegate.Config.Button3.name
        volume.maxValue = (Double)(AppDelegate.Config.Volume.maxVol)!
        volume.doubleValue = (Double)(AppDelegate.Config.Volume.defaultVol)!
        // Automatic connection
        var log:String = "Connecting...\n"
        switch client.connect(timeout: (Int)(AppDelegate.Config.OnkyoClient.timeout)!) {
        case .success:
            log.append("Client connected")
        case .failure(let error):
            log.append(String(describing: error))
        }
        NSLog("Debug: '%@'", log)
        setVolume(volume, val: Int(volume.doubleValue))

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
                NSLog("Debug: '%@'", line)
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
                NSLog("Debug: '%@'", line)
            }
        }
    }

    
    @IBAction func power(_ sender: NSButton) {
        var log:String = ""
        var error: Result?
        stoplocalradio()
        if (powerButton.title == AppDelegate.Config.PowerButton.nameOn) {
            log.append("Powering Off...\n")
            powerButton.title = AppDelegate.Config.PowerButton.nameOff
            powerButton.state = NSControl.StateValue.off
            localButton.state = NSControl.StateValue.off
            button1.state = NSControl.StateValue.off
            button2.state = NSControl.StateValue.off
            button3.state = NSControl.StateValue.off
            error = client.sendcmd(command: AppDelegate.Config.PowerButton.commandOff as NSString)
        } else {
            log.append("Powering On...\n")
            powerButton.title = AppDelegate.Config.PowerButton.nameOn
            powerButton.state = NSControl.StateValue.on
            error = client.sendcmd(command: AppDelegate.Config.PowerButton.commandOn as NSString)
        }
        if (error?.isFailure)! {
            powerButton.state = NSControl.StateValue.off
            localButton.state = NSControl.StateValue.off
            button1.state = NSControl.StateValue.off
            button2.state = NSControl.StateValue.off
            button3.state = NSControl.StateValue.off
            powerButton.title = AppDelegate.Config.PowerButton.nameOff
        }
        stoplocalradio()
        log.append("Stopping icecast & darkice...\n")
        log.append(String(describing: error))
        NSLog("Debug: '%@'", log)
    }

    func sendcmd (command : String) -> Bool {
        for name in command.components(separatedBy: ",") {
            if (name=="") {
                sleep(1)
            } else if (name=="icecast") {
                startlocalradio()
                NSLog("Debug: '%@'", "Starting icecast & darkice")
            } else if (name=="exit") {
                NSLog("Debug: '%@'", "Stopping...")
                stoplocalradio()
                var error: Result?
                error = client.sendcmd(command: AppDelegate.Config.PowerButton.commandOff as NSString)
                NSLog("Debug: '%@'", "Sending command : "+AppDelegate.Config.PowerButton.commandOff)
                if (error?.isFailure)! {
                    NSLog("Error: '%@'", "String(describing: error)")
                    return false
                }
                NSApp.terminate(self)
            } else {
                powerButton.title = AppDelegate.Config.PowerButton.nameOn
                powerButton.state = NSControl.StateValue.on
                var error: Result?
                error = client.sendcmd(command: name as NSString)
                NSLog("Debug: '%@'", "Sending command : "+name)
                if (error?.isFailure)! {
                    NSLog("Error: '%@'", "String(describing: error)")
                    return false
                }
            }
        }
        return true
    }
    
    @IBAction func local(_ sender: NSButton) {
        NSLog("Debug: '%@'", "Connecting to "+AppDelegate.Config.LocalButton.name+"...")
        stoplocalradio()
        button1.state = NSControl.StateValue.off
        button2.state = NSControl.StateValue.off
        button3.state = NSControl.StateValue.off
        if (sendcmd(command: AppDelegate.Config.LocalButton.command)==false) {
            localButton.state = NSControl.StateValue.off
        }
    }

    @objc func menu1(_ sender: AnyObject) {
        let val: Int = sender.representedObject as! Int
        NSLog("Debug: '%@'", "Connecting to "+AppDelegate.Config.Button1.name+" ("+AppDelegate.Config.Button1.menulist[val-1].name+")...")
        if (AppDelegate.Config.Button1.menulist[val-1].command.contains("SL")) { stoplocalradio() }
        sendcmd(command: AppDelegate.Config.Button1.menulist[val-1].command)
    }

    @IBAction func button1(_ sender: NSButton) {
        localButton.state = NSControl.StateValue.off
        button2.state = NSControl.StateValue.off
        button3.state = NSControl.StateValue.off
        if (AppDelegate.Config.Button1.menuItems=="0") {
            NSLog("Debug: '%@'", "Connecting to "+AppDelegate.Config.Button1.name+"...")
            if (AppDelegate.Config.Button1.command.contains("SL")) { stoplocalradio() }
            if (sendcmd(command: AppDelegate.Config.Button1.command)==false) {
                button1.state = NSControl.StateValue.off
            }
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
        NSLog("Debug: '%@'", "Connecting to "+AppDelegate.Config.Button1.name+" ("+AppDelegate.Config.Button2.menulist[val-1].name+")...")
        if (AppDelegate.Config.Button2.menulist[val-1].command.contains("SL")) { stoplocalradio() }
        sendcmd(command: AppDelegate.Config.Button2.menulist[val-1].command)
    }
    
    @IBAction func button2(_ sender: NSButton) {
        localButton.state = NSControl.StateValue.off
        button1.state = NSControl.StateValue.off
        button3.state = NSControl.StateValue.off
        if (AppDelegate.Config.Button2.menuItems=="0") {
            NSLog("Debug: '%@'", "Connecting to "+AppDelegate.Config.Button2.name+"...")
            if (AppDelegate.Config.Button2.command.contains("SL")) { stoplocalradio() }
            if (sendcmd(command: AppDelegate.Config.Button2.command)==false) {
                button2.state = NSControl.StateValue.off
            }
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
        NSLog("Debug: '%@'", "Connecting to "+AppDelegate.Config.Button3.name+" ("+AppDelegate.Config.Button3.menulist[val-1].name+")...")
        if (AppDelegate.Config.Button3.menulist[val-1].command.contains("SL")) { stoplocalradio() }
        sendcmd(command: AppDelegate.Config.Button3.menulist[val-1].command)
    }
    
   @IBAction func button3(_ sender: NSButton) {
        localButton.state = NSControl.StateValue.off
        button1.state = NSControl.StateValue.off
        button2.state = NSControl.StateValue.off
        if (AppDelegate.Config.Button3.menuItems=="0") {
            NSLog("Debug: '%@'", "Connecting to "+AppDelegate.Config.Button3.name+"...")
            if (AppDelegate.Config.Button3.command.contains("SL")) { stoplocalradio() }
            if (sendcmd(command: AppDelegate.Config.Button3.command)==false) {
                button3.state = NSControl.StateValue.off
            }
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
    
    func setVolume(_ sender: NSSlider, val: Int)
    {
        let st = NSString(format:AppDelegate.Config.Volume.command as NSString, val)
        var error: Result?
        error = client.sendcmd(command: st)
        if (error?.isFailure)! {
            sender.integerValue = 0
        }

    }

    @IBAction func volume(_ sender: NSSlider) {
        var log:String = "Changing volume to "
        let val = sender.integerValue
        log.append(String(describing: val))
        setVolume(sender, val: val)
        NSLog("Debug: '%@'", log)
    }
    
}

