//
//  AppDelegate.swift
//  OnkyRemote
//
//  Created by lebera on 02/01/2018.
//  Copyright © 2018 Onkyo. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
    let popover = NSPopover()
    struct MenuList {
        var name = ""
        var command = ""
    }
    struct Config {
        struct OnkyoClient {
            static var name = ""
            static var address = ""
            static var port = ""
            static var timeout = ""
        }
        struct PowerButton {
            static var nameOn = ""
            static var nameOff = ""
            static var commandOn = ""
            static var commandOff = ""
        }
        struct LocalButton {
            static var name = ""
            static var command = ""
        }
        struct Button1 {
            static var name = ""
            static var command = ""
            static var menuItems = ""
            static var menulist: [MenuList] = [MenuList]()
        }
        struct Button2 {
            static var name = ""
            static var command = ""
            static var menuItems = ""
            static var menulist: [MenuList] = [MenuList]()
        }
        struct Button3 {
            static var name = ""
            static var command = ""
            static var menuItems = ""
            static var menulist: [MenuList] = [MenuList]()
        }
        struct Volume {
            static var maxVol = ""
            static var defaultVol = ""
            static var command = ""
        }
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        do {
            let configres = Bundle.main.url(forResource: "OnkyoConfig", withExtension:"ini")
            let configfile = try INIParser((configres?.path)!)
            
            if (configfile.sections["OnkyoClient"]!["name"] == nil) {
                NSLog("Warning: OnkyoConfig.ini file : 'no name defined in [OnkyoClient] section - auto detection activated'")
                Config.OnkyoClient.name = ""
            } else {
                Config.OnkyoClient.name = configfile.sections["OnkyoClient"]!["name"]!
            }
           if (configfile.sections["OnkyoClient"]!["address"] == nil) {
                NSLog("Warning: OnkyoConfig.ini file : 'no address defined in [OnkyoClient] section - auto detection activated'")
                Config.OnkyoClient.address = "0.0.0.0"
            } else {
                Config.OnkyoClient.address = configfile.sections["OnkyoClient"]!["address"]!
            }
            if (configfile.sections["OnkyoClient"]!["port"] == nil) {
                NSLog("Error: OnkyoConfig.ini file incorrect : 'no port defined in [OnkyoClient] section'")
                Config.OnkyoClient.port = ""
            } else {
                Config.OnkyoClient.port = configfile.sections["OnkyoClient"]!["port"]!
            }
            if (configfile.sections["OnkyoClient"]!["timeout"] == nil) {
                NSLog("Error: OnkyoConfig.ini file incorrect : 'no timeout defined in [OnkyoClient] section'")
                Config.OnkyoClient.timeout = "5"
            } else {
                Config.OnkyoClient.timeout = configfile.sections["OnkyoClient"]!["timeout"]!
            }
            if (configfile.sections["PowerButton"]!["nameOn"] == nil) {
                NSLog("Error: OnkyoConfig.ini file incorrect : 'no nameOn defined in [PowerButton] section'")
                Config.PowerButton.nameOn = "ON"
            } else {
                Config.PowerButton.nameOn = configfile.sections["PowerButton"]!["nameOn"]!
            }
            if (configfile.sections["PowerButton"]!["nameOff"] == nil) {
                NSLog("Error: OnkyoConfig.ini file incorrect : 'no nameOff defined in [PowerButton] section'")
                Config.PowerButton.nameOff = "OFF"
            } else {
                Config.PowerButton.nameOff = configfile.sections["PowerButton"]!["nameOff"]!
            }
            if (configfile.sections["PowerButton"]!["commandOn"] == nil) {
                NSLog("Error: OnkyoConfig.ini file incorrect : 'no commandOn defined in [PowerButton] section'")
                Config.PowerButton.commandOn = ""
            } else {
                Config.PowerButton.commandOn = configfile.sections["PowerButton"]!["commandOn"]!
            }
            if (configfile.sections["PowerButton"]!["commandOff"] == nil) {
                NSLog("Error: OnkyoConfig.ini file incorrect : 'no commandOff defined in [PowerButton] section'")
                Config.PowerButton.commandOff = ""
            } else {
                Config.PowerButton.commandOff = configfile.sections["PowerButton"]!["commandOff"]!
            }
            if (configfile.sections["LocalButton"]!["name"] == nil) {
                NSLog("Error: OnkyoConfig.ini file incorrect : 'no name defined in [LocalButton] section'")
                Config.LocalButton.name = ""
            } else {
                Config.LocalButton.name = configfile.sections["LocalButton"]!["name"]!
            }
            if (configfile.sections["LocalButton"]!["command"] == nil) {
                NSLog("Error: OnkyoConfig.ini file incorrect : 'no command defined in [LocalButton] section'")
                Config.LocalButton.command = ""
            } else {
                Config.LocalButton.command = configfile.sections["LocalButton"]!["command"]!
            }
            if (configfile.sections["Volume"]!["maxVol"] == nil) {
                NSLog("Error: OnkyoConfig.ini file incorrect : 'no maxVol defined in [Volume] section'")
                Config.Volume.maxVol = "0"
            } else {
                Config.Volume.maxVol = configfile.sections["Volume"]!["maxVol"]!
            }
            if (configfile.sections["Volume"]!["defaultVol"] == nil) {
                NSLog("Error: OnkyoConfig.ini file incorrect : 'no defaultVol defined in [Volume] section'")
                Config.Volume.defaultVol = "0"
            } else {
                Config.Volume.defaultVol = configfile.sections["Volume"]!["defaultVol"]!
            }
            if (configfile.sections["Volume"]!["command"] == nil) {
                NSLog("Error: OnkyoConfig.ini file incorrect : 'no command defined in [Volume] section'")
                Config.Volume.command = ""
            } else {
                Config.Volume.command = configfile.sections["Volume"]!["command"]!
            }
            if (configfile.sections["Button1"]!["name"] == nil) {
                NSLog("Error: OnkyoConfig.ini file incorrect : 'no name defined in [Button1] section'")
                Config.Button1.name = ""
            } else {
                Config.Button1.name = configfile.sections["Button1"]!["name"]!
            }
            if (configfile.sections["Button1"]!["command"] == nil) {
                NSLog("Error: OnkyoConfig.ini file incorrect : 'no command defined in [Button1] section'")
                Config.Button1.command = ""
                
            } else {
                Config.Button1.command = configfile.sections["Button1"]!["command"]!
            }
            if (configfile.sections["Button1"]!["menu"] == nil) {
                NSLog("Error: OnkyoConfig.ini file incorrect : 'no menu defined in [Button1] section'")
                Config.Button1.menuItems = "0"
            } else {
                Config.Button1.menuItems = configfile.sections["Button1"]!["menu"]!
            }
            if ((Int)(Config.Button1.menuItems) as! Int != 0) {
                for i in 1 ... (Int)(Config.Button1.menuItems)! {
                    if ((configfile.sections["Button1"]![NSString(format:"menu_name_%002d",i) as String] == nil) || (configfile.sections["Button1"]![NSString(format:"menu_command_%002d",i) as String] == nil)) {
                        NSLog("Error: OnkyoConfig.ini file incorrect : 'error in submenus defined in [Button1] section'")
                        Config.Button1.menuItems = "0"
                    } else {
                        Config.Button1.menulist.append(MenuList(name : configfile.sections["Button1"]![NSString(format:"menu_name_%002d",i) as String]!, command : configfile.sections["Button1"]![NSString(format:"menu_command_%002d",i) as String]!))
                    }
                }
            }
            if (configfile.sections["Button2"]!["name"] == nil) {
                NSLog("Error: OnkyoConfig.ini file incorrect : 'no name defined in [Button2] section'")
                Config.Button2.name = ""
            } else {
                Config.Button2.name = configfile.sections["Button2"]!["name"]!
            }
            if (configfile.sections["Button2"]!["command"] == nil) {
                NSLog("Error: OnkyoConfig.ini file incorrect : 'no command defined in [Button2] section'")
                Config.Button2.command = ""
            } else {
                Config.Button2.command = configfile.sections["Button2"]!["command"]!
            }
            if (configfile.sections["Button2"]!["menu"] == nil) {
                NSLog("Error: OnkyoConfig.ini file incorrect : 'no menu defined in [Button2] section'")
                Config.Button2.menuItems = "0"
            } else {
                Config.Button2.menuItems = configfile.sections["Button2"]!["menu"]!
            }
            if ((Int)(Config.Button2.menuItems) as! Int != 0) {
                for i in 1 ... (Int)(Config.Button2.menuItems)! {
                    if ((configfile.sections["Button2"]![NSString(format:"menu_name_%002d",i) as String] == nil) || (configfile.sections["Button2"]![NSString(format:"menu_command_%002d",i) as String] == nil)) {
                        NSLog("Error: OnkyoConfig.ini file incorrect : 'error in submenus defined in [Button2] section'")
                        Config.Button2.menuItems = "0"
                    } else {
                        Config.Button2.menulist.append(MenuList(name : configfile.sections["Button2"]![NSString(format:"menu_name_%002d",i) as String]!, command : configfile.sections["Button2"]![NSString(format:"menu_command_%002d",i) as String]!))
                    }
                }
            }
            if (configfile.sections["Button3"]!["name"] == nil) {
                NSLog("Error: OnkyoConfig.ini file incorrect : 'no name defined in [Button3] section'")
                Config.Button3.name = ""
            } else {
                Config.Button3.name = configfile.sections["Button3"]!["name"]!
            }
            if (configfile.sections["Button3"]!["command"] == nil) {
                NSLog("Error: OnkyoConfig.ini file incorrect : 'no command defined in [Button3] section'")
                Config.Button3.command = ""
            } else {
                Config.Button3.command = configfile.sections["Button3"]!["command"]!
            }
            if (configfile.sections["Button3"]!["menu"] == nil) {
                NSLog("Error: OnkyoConfig.ini file incorrect : 'no menu defined in [Button3] section'")
                Config.Button3.menuItems = "0"
            } else {
                Config.Button3.menuItems = configfile.sections["Button3"]!["menu"]!
            }
            if ((Int)(Config.Button3.menuItems) as! Int != 0) {
                for i in 1 ... (Int)(Config.Button3.menuItems)! {
                    if ((configfile.sections["Button3"]![NSString(format:"menu_name_%002d",i) as String] == nil) || (configfile.sections["Button3"]![NSString(format:"menu_command_%002d",i) as String] == nil)) {
                        NSLog("Error: OnkyoConfig.ini file incorrect : 'error in submenus defined in [Button3] section'")
                        Config.Button3.menuItems = "0"
                    } else {
                        Config.Button3.menulist.append(MenuList(name : configfile.sections["Button3"]![NSString(format:"menu_name_%002d",i) as String]!, command : configfile.sections["Button3"]![NSString(format:"menu_command_%002d",i) as String]!))
                    }
                }
            }
        } catch ( _) {
            fatalError("OnkyoConfig.ini file missing or incorrect - Check it")
        }
        
        if ((Config.OnkyoClient.address=="0.0.0.0")||(Config.OnkyoClient.name=="")) {
            NSLog("Warning: Forcing Onkyo receiver auto detection")
            let udp:OnkyoUDPClient = OnkyoUDPClient(address: "255.255.255.255", port: (Int32)(AppDelegate.Config.OnkyoClient.port)!)
            let ret = udp.autodetect(name: Config.OnkyoClient.name, ip:Config.OnkyoClient.address, tmout: Int(Config.OnkyoClient.timeout)!)
            Config.OnkyoClient.name = ret[0]
            Config.OnkyoClient.address = ret[1]
            udp.close()
        }

         if let button = statusItem.button {
            button.image = NSImage(named:NSImage.Name("StatusBarButtonImage"))
            button.action = #selector(togglePopover(_:))
        }
 
        popover.contentViewController = OnkyoViewController.freshController()

    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    @objc func togglePopover(_ sender: Any?) {
        if popover.isShown {
            closePopover(sender: sender)
        } else {
            showPopover(sender: sender)
        }
    }
    
    func showPopover(sender: Any?) {
        if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
        }
    }
    
    func closePopover(sender: Any?) {
        popover.performClose(sender)
    }

}

