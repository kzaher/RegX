//
//  RegXPlugin.swift
//  RegX
//
//  Created by Krunoslav Zaher on 10/18/14.
//  Copyright (c) 2014 Krunoslav Zaher. All rights reserved.
//

import Foundation

var service : XCodeService? = nil

public class RegXPlugin: NSObject {
    private struct Instances {
        static var service : XCodeService? = nil
    }
    
    public class func pluginDidLoad(plugin: Bundle) {
        Log("RegXPlugin Loaded")
        
        let sharedApplication = NSApplication.shared()
        let errorPresenter = AlertErrorPresenter()
        
        let tabWidth = { 1 } // { return Int(RegX_tabWidth()) }
        
        Instances.service = XCodeService(xcodeApp:sharedApplication,
            tabWidth: tabWidth,
            notificationCenter: NotificationCenter.default,
            errorPresenter: errorPresenter,
            forms: Configuration.forms)
    }
}
