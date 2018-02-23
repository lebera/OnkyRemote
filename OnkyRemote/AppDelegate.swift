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
            Config.OnkyoClient.address = configfile.sections["OnkyoClient"]!["address"]!
            Config.OnkyoClient.port = configfile.sections["OnkyoClient"]!["port"]!
            Config.OnkyoClient.timeout = configfile.sections["OnkyoClient"]!["timeout"]!
            Config.PowerButton.nameOn = configfile.sections["PowerButton"]!["nameOn"]!
            Config.PowerButton.nameOff = configfile.sections["PowerButton"]!["nameOff"]!
            Config.PowerButton.commandOn = configfile.sections["PowerButton"]!["commandOn"]!
            Config.PowerButton.commandOff = configfile.sections["PowerButton"]!["commandOff"]!
            Config.LocalButton.name = configfile.sections["LocalButton"]!["name"]!
            Config.LocalButton.command = configfile.sections["LocalButton"]!["command"]!
            Config.Volume.maxVol = configfile.sections["Volume"]!["maxVol"]!
            Config.Volume.defaultVol = configfile.sections["Volume"]!["defaultVol"]!
            Config.Volume.command = configfile.sections["Volume"]!["command"]!
            Config.Button1.name = configfile.sections["Button1"]!["name"]!
            Config.Button1.command = configfile.sections["Button1"]!["command"]!
            Config.Button1.menuItems = configfile.sections["Button1"]!["menu"]!
            if ((Int)(Config.Button1.menuItems) as! Int != 0) {
                for i in 1 ... (Int)(Config.Button1.menuItems)! {
                        Config.Button1.menulist.append(MenuList(name : configfile.sections["Button1"]![NSString(format:"menu_name_%002d",i) as String]!, command : configfile.sections["Button1"]![NSString(format:"menu_command_%002d",i) as String]!))
                }
            }
            Config.Button2.name = configfile.sections["Button2"]!["name"]!
            Config.Button2.command = configfile.sections["Button2"]!["command"]!
            Config.Button2.menuItems = configfile.sections["Button2"]!["menu"]!
            if ((Int)(Config.Button2.menuItems) as! Int != 0) {
                for i in 1 ... (Int)(Config.Button2.menuItems)! {
                    Config.Button2.menulist.append(MenuList(name : configfile.sections["Button2"]![NSString(format:"menu_name_%002d",i) as String]!, command : configfile.sections["Button2"]![NSString(format:"menu_command_%002d",i) as String]!))
                }
            }
            Config.Button3.name = configfile.sections["Button3"]!["name"]!
            Config.Button3.command = configfile.sections["Button3"]!["command"]!
            Config.Button3.menuItems = configfile.sections["Button3"]!["menu"]!
           if ((Int)(Config.Button3.menuItems) as! Int != 0) {
                for i in 1 ... (Int)(Config.Button3.menuItems)! {
                    Config.Button3.menulist.append(MenuList(name : configfile.sections["Button3"]![NSString(format:"menu_name_%002d",i) as String]!, command : configfile.sections["Button3"]![NSString(format:"menu_command_%002d",i) as String]!))
                }
            }
        }catch ( _) {
            fatalError("OnkyoConfig.ini file missing or incorrect - Check it")
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

