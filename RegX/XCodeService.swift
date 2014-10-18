//
//  XCodeService.swift
//  RegX
//
//  Created by Krunoslav Zaher on 10/18/14.
//  Copyright (c) 2014 Krunoslav Zaher. All rights reserved.
//

import Foundation
import AppKit

class XCodeService : NSObject {
    
    let notificationCenter : NSNotificationCenter
    let xcodeApp : NSApplication
    let textPreferences : DVTTextPreferences
    let errorPresenter : ErrorPresenter
    let forms : [RegularForm]
    
    init(xcodeApp: NSApplication,
        textPreferences: DVTTextPreferences,
        notificationCenter: NSNotificationCenter,
        errorPresenter: ErrorPresenter,
        forms: [RegularForm]) {
            
        self.notificationCenter = notificationCenter
        self.xcodeApp = xcodeApp
        self.textPreferences = textPreferences
        self.errorPresenter = errorPresenter
        self.forms = forms
            
        super.init()
            
        self.notificationCenter.addObserver(self, selector: "applicationDidFinishLaunching:", name: NSApplicationDidFinishLaunchingNotification, object: nil)
    }
    
    var currentEditor : AnyObject! {
        get {
            let window : NSWindow? = NSApp.keyWindow?
            let controller : AnyObject? = window?.windowController()
            let currentWindowController = controller as? IDEWorkspaceWindowController
    
            if currentWindowController == nil {
                return nil
            }
            
            return currentWindowController?.editorArea()?.lastActiveEditorContext()?.editor()
        }
    }
    
    var currentTextView : NSTextView! {
        get {
            let currentEditor : AnyObject! = self.currentEditor
            
            let sourceCodeEditor = currentEditor as? IDESourceCodeEditor
            
            if sourceCodeEditor != nil {
                return sourceCodeEditor?.textView
            }
            
            return nil;
        }
    }
    
    var currentSourceCodeDocument : IDESourceCodeDocument! {
        get {
            let currentEditor : AnyObject! = self.currentEditor
            
            let sourceCodeEditor = currentEditor as? IDESourceCodeEditor
            
            if sourceCodeEditor != nil {
                return sourceCodeEditor?.sourceCodeDocument()
            }
        
            return nil
        }
    }
    
    func showError(error: String) {
        self.errorPresenter.showError(error)
    }
    
    func registerItemsAndShortcuts() {
        let refactorItem = self.xcodeApp.mainMenu?.itemWithTitle("Edit")?.submenu?.itemWithTitle("Refactor")
        
        if refactorItem == nil {
            showError("Can't find refactor menu")
            return;
        }
        
        let regXMenuItem = NSMenuItem(title: "RegX", action:nil, keyEquivalent: "ALT+F")
        
        let indexToInsert = refactorItem!.menu!.indexOfItem(refactorItem!) + 1
        
        refactorItem!.menu!.insertItem(regXMenuItem, atIndex: indexToInsert)
        
        let regXMenu = NSMenu(title:"RegX")
        
        var index = 0
        for form in self.forms {
            let formItem = NSMenuItem(title: form.name,
                                     action: "regularizeCommand:",
                              keyEquivalent: form.shortcut)
            formItem.target = self
            formItem.representedObject = index
            regXMenu.addItem(formItem)
            
            index++
        }

        regXMenuItem.submenu = regXMenu
    }
    
    func regularizeCommand(item: NSMenuItem) {
        let index : Int = item.representedObject as Int
        let form = forms[index]
        
        changeSelectedText { (selectedText) -> String in
            return form.alignColumns(selectedText)
        }
    }
    
    func applicationDidFinishLaunching(notification: NSNotification) {
        Log("Application did Finish Launching")
        registerItemsAndShortcuts()
    }
    
    class func substring(string: String, range:NSRange) -> String {
        let start = advance(string.startIndex, range.location)
        let end = advance(start, range.length)
        
        return string.substringWithRange(Range(start:start, end:end))
    }
    
    func changeSelectedText(changeAction: (selectedText : String) -> String) {
        let currentTextView = self.currentTextView
        let currentDocument = self.currentSourceCodeDocument
        
        if currentTextView == nil || currentDocument == nil {
            errorPresenter.showError("Invalid context. Aligning only works in source code windows. \(self.currentEditor)")
            return
        }
       
        let firstRange : NSValue! = currentTextView.selectedRanges.first as? NSValue!
        
        if firstRange == nil {
            errorPresenter.showError("Please select range.")
            return
        }
        
        let range = firstRange.rangeValue
        
        let code = currentTextView.textStorage?.string
        
        if code == nil {
            errorPresenter.showError("Can't fetch code.")
            return
        }
        
        let selectedCode = XCodeService.substring(code!, range:range)
        
        changeAction(selectedText: selectedCode)
    }
    
    deinit {
        self.notificationCenter.removeObserver(self)
    }
}
