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
    
    public struct Patterns {
        // https://www.debuggex.com/ <- use it
        static let nonterminatedVariable = "((?:\\s)*) (?# this is type declaration ->) ([^\\s](?:[^\\*]|(?:(?:(?<=/)\\*|\\*(?=/))))*\\s)  (?# this is variable declaration ->)    (?:\\s*)((?:(?<!/)(?!/)\\**)\\s*(?:\\w|\\d|_|-)+\\s*(?:;)?\\s*)"
        
         static let macroRegex = "^" +
            "(?: " +
            "(?# this is define declaration ->)  " +
            "(\\#\\s*define\\s) " +
            "(?:\\s*) " +
            "(?# macro name) " +
            "(\\S+(?:\\s*\\([^\\)]*\\))?)\\s  " +
            "(?# space)" +
            "(?:\\s*) " +
            "(?# macro value) (\\S.+) \\s*" +
            ")" +
            "|" +
            "(?:" +
            "(?# other declarations ->) " +
            "(\\#\\s*\\S+\\s) (?:\\s*) (\\S*.*) " +
            ")$" +
        "";
        
        static var variableRegex : String = ""
        static var propertyRegex : String = ""
        static var variableWithInitializer : String = ""
    }

    
    public override class func initialize() {
        // no static variables so far
        Patterns.propertyRegex = "^(\\s*@property\\s*)(\\([^\\)]*)?(\\))?\\s" + Patterns.nonterminatedVariable + "$"
        Patterns.variableRegex = "^\(Patterns.nonterminatedVariable)$"
        Patterns.variableWithInitializer = "^\(Patterns.variableRegex)$"
    }
    
    
    public class func pluginDidLoad(plugin: NSBundle) {
        Log("RegXPlugin Loaded")
        
        let sharedApplication = NSApplication.sharedApplication()
        let errorPresenter = AlertErrorPresenter()
        let textPreferences = DVTTextPreferences()
        
        let formats = [
            RegularForm(name: "Variables",
                     pattern: Patterns.variableWithInitializer,
                     shortcut: ""),
            RegularForm(name: "ObjC Property",
                     pattern: Patterns.propertyRegex,
                     shortcut: ""),
            RegularForm(name: "Macros",
                     pattern: Patterns.macroRegex,
                     shortcut: ""),
                        ]
        
        Instances.service = XCodeService(xcodeApp:sharedApplication,
            textPreferences:textPreferences,
            notificationCenter: NSNotificationCenter.defaultCenter(),
            errorPresenter:errorPresenter,
            forms: formats)
    }
}
