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
    let tabWidth : () -> Int
    let errorPresenter : ErrorPresenter
    let forms : [RegularForm]
    
    init(xcodeApp: NSApplication,
        tabWidth: () -> Int,
        notificationCenter: NSNotificationCenter,
        errorPresenter: ErrorPresenter,
        forms: [RegularForm]) {
            
        self.xcodeApp           = xcodeApp
        self.tabWidth           = tabWidth
        self.notificationCenter = notificationCenter
        self.errorPresenter     = errorPresenter
        self.forms              = forms
            
        super.init()
            
        self.notificationCenter.addObserver(self, selector: "applicationDidFinishLaunching:", name: NSApplicationDidFinishLaunchingNotification, object: nil)
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
        
        let regXMenuItem = NSMenuItem(title: "RegX", action:nil, keyEquivalent: "R")
        let mask
            = NSEventModifierFlags.CommandKeyMask
            | NSEventModifierFlags.AlternateKeyMask
        regXMenuItem.keyEquivalentModifierMask = Int(mask.rawValue)
        
        let indexToInsert = refactorItem!.menu!.indexOfItem(refactorItem!) + 1
        
        refactorItem!.menu!.insertItem(regXMenuItem, atIndex: indexToInsert)
        
        let regXMenu = NSMenu(title:"RegX")
        
        var index = 0
        for form in self.forms {
            let formItem = NSMenuItem(title: form.name,
                                     action: "regularizeCommand:",
                              keyEquivalent: form.shortcut)
            formItem.keyEquivalentModifierMask = Int(form.modifier.rawValue)
                
            formItem.target = self
            formItem.representedObject = index
            regXMenu.addItem(formItem)
            
            index++
        }

        regXMenuItem.submenu = regXMenu
    }
    
    func regularizeCommand(item: NSMenuItem) {
        let index : Int = item.representedObject as! Int
        let form = forms[index]
        
        changeSelectedText { (selectedText) -> String in
            return form.alignColumns(selectedText, tabWidth:self.tabWidth())
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
    
    class func paragraphRange(string: NSString, range: NSRange) -> NSRange {
        let emptyLineRegex = NSRegularExpression(pattern: "^\\s*$", options: NSRegularExpressionOptions.AnchorsMatchLines, error: nil)
        
        let lineMatches = emptyLineRegex!.matchesInString(string as String, options: NSMatchingOptions.allZeros, range: NSMakeRange(0, string.length))
        
        let lineStartIndexes : [Int] = map(lineMatches) {
            let location = ($0 as! NSTextCheckingResult).range.location
            return location != NSNotFound ? location : 0
        }
        
        let rangeEnd = range.location + range.length
        
        let paragraphSeparatorBeforeRange = lineStartIndexes.filter { $0 < range.location }.last
        let paragraphSeparatorAfterRange  = lineStartIndexes.filter { $0 > rangeEnd }.first

        let startIndex = paragraphSeparatorBeforeRange != nil ? paragraphSeparatorBeforeRange! : 0
        let endIndex   = paragraphSeparatorAfterRange != nil ? paragraphSeparatorAfterRange! : string.length
        
        return NSMakeRange(startIndex, endIndex - startIndex)
    }
    
    func changeSelectedText(changeAction: (selectedText : String) -> String) {
        let controller              = self.xcodeApp .. "keyWindow" .. "windowController"
        let editor                  = controller .. "editorArea" .. "lastActiveEditorContext" .. "editor"
        let currentDocumentOptional = editor .. ["sourceCodeDocument", "primaryDocument"]
        let currentTextViewOptional = editor .. ["textView", "keyTextView"]

        if !currentTextViewOptional.hasValue || !currentDocumentOptional.hasValue {
            errorPresenter.showError("Invalid context. Aligning only works in source code windows. \(currentTextViewOptional.description)")
            return
        }
        
        let currentTextView = currentTextViewOptional.value as? NSTextView
       
        let firstRange : NSValue! = currentTextView!.selectedRanges.first as? NSValue!
        
        if firstRange == nil {
            errorPresenter.showError("Please select range.")
            return
        }
        
        let code = currentTextView!.textStorage?.string
        
        if code == nil {
            errorPresenter.showError("Can't fetch code.")
            return
        }
        
        let firstRangeValue = firstRange.rangeValue
        
        let range = firstRangeValue.length == 0
            ? XCodeService.paragraphRange(code!, range: firstRangeValue)
            : RegX_fixRange(currentDocumentOptional.value, firstRangeValue)
        
        let selectedCode = XCodeService.substring(code!, range:range)
        
        let resultSelectedCode = changeAction(selectedText: selectedCode)
        
        RegX_replaceSelectedText(currentDocumentOptional.value, range, resultSelectedCode)
    }
    
    deinit {
        self.notificationCenter.removeObserver(self)
    }
}
