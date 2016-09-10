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
    
    let notificationCenter : NotificationCenter
    let xcodeApp : NSApplication
    let tabWidth : () -> Int
    let errorPresenter : ErrorPresenter
    let forms : [RegularForm]
    
    init(xcodeApp: NSApplication,
        tabWidth: @escaping () -> Int,
        notificationCenter: NotificationCenter,
        errorPresenter: ErrorPresenter,
        forms: [RegularForm]) {
            
        self.xcodeApp           = xcodeApp
        self.tabWidth           = tabWidth
        self.notificationCenter = notificationCenter
        self.errorPresenter     = errorPresenter
        self.forms              = forms
            
        super.init()
            
        self.notificationCenter.addObserver(self, selector: #selector(NSApplicationDelegate.applicationDidFinishLaunching(_:)), name: NSNotification.Name.NSApplicationDidFinishLaunching, object: nil)
    }
    
    func showError(error: String) {
        self.errorPresenter.showError(errorText: error)
    }
    
    func registerItemsAndShortcuts() {
        let refactorItem = self.xcodeApp.mainMenu?.item(withTitle: "Edit")?.submenu?.item(withTitle: "Refactor")
        
        if refactorItem == nil {
            showError(error: "Can't find refactor menu")
            return;
        }
        
        let regXMenuItem = NSMenuItem(title: "RegX", action:nil, keyEquivalent: "R")
        let mask
            = NSEventModifierFlags.command
            .union(NSEventModifierFlags.option)
        regXMenuItem.keyEquivalentModifierMask = mask
        
        let indexToInsert = refactorItem!.menu!.index(of: refactorItem!) + 1
        
        refactorItem!.menu!.insertItem(regXMenuItem, at: indexToInsert)
        
        let regXMenu = NSMenu(title:"RegX")
        
        var index = 0
        for form in self.forms {
            let formItem = NSMenuItem(title: form.name,
                                     action: #selector(XCodeService.regularizeCommand(_:)),
                              keyEquivalent: form.shortcut)
            formItem.keyEquivalentModifierMask = form.modifier
                
            formItem.target = self
            formItem.representedObject = index
            regXMenu.addItem(formItem)
            
            index += 1
        }

        regXMenuItem.submenu = regXMenu
    }
    
    func regularizeCommand(_ item: NSMenuItem) {
        let index : Int = item.representedObject as! Int
        let form = forms[index]
        
        changeSelectedText { (selectedText) -> String in
            return form.alignColumns(text: selectedText, tabWidth:self.tabWidth())
        }
    }
    
    func applicationDidFinishLaunching(_ notification: NSNotification) {
        Log("Application did Finish Launching")
        registerItemsAndShortcuts()
    }
    
    class func substring(string: String, range: NSRange) -> String {
        let start = string.index(at: Int(range.location))
        let end = string.index(at: Int(range.location + range.length))
        let range = Range(uncheckedBounds: (lower: start, upper: end))
        return string.substring(with: range)
    }
    
    class func paragraphRange(string: NSString, range: NSRange) -> NSRange {
        let emptyLineRegex = try! NSRegularExpression(pattern: "^\\s*$", options: NSRegularExpression.Options.anchorsMatchLines)
        
        let lineMatches = emptyLineRegex.matches(in: string as String, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, string.length))
        
        let lineStartIndexes : [Int] = lineMatches.map {
            let location = $0.range.location
            return location != NSNotFound ? location : 0
        }
        
        let rangeEnd = range.location + range.length
        
        let paragraphSeparatorBeforeRange = lineStartIndexes.filter { $0 < range.location }.last
        let paragraphSeparatorAfterRange  = lineStartIndexes.filter { $0 > rangeEnd }.first

        let startIndex = paragraphSeparatorBeforeRange != nil ? paragraphSeparatorBeforeRange! : 0
        let endIndex   = paragraphSeparatorAfterRange != nil ? paragraphSeparatorAfterRange! : string.length
        
        return NSMakeRange(startIndex, endIndex - startIndex)
    }
    
    func changeSelectedText(_ changeAction: (_ selectedText : String) -> String) {
        let controller              = self.xcodeApp .. "keyWindow" .. "windowController"
        let editor                  = controller .. "editorArea" .. "lastActiveEditorContext" .. "editor"
        let currentDocumentOptional = editor .. ["sourceCodeDocument", "primaryDocument"]
        let currentTextViewOptional = editor .. ["textView", "keyTextView"]

        if !currentTextViewOptional.hasValue || !currentDocumentOptional.hasValue {
            errorPresenter.showError(errorText: "Invalid context. Aligning only works in source code windows. \(currentTextViewOptional.description)")
            return
        }
        
        let currentTextView = currentTextViewOptional.value as? NSTextView
       
        let firstRange = currentTextView!.selectedRanges.first
        
        if firstRange == nil {
            errorPresenter.showError(errorText: "Please select range.")
            return
        }
        
        let code = currentTextView!.textStorage?.string
        
        if code == nil {
            errorPresenter.showError(errorText: "Can't fetch code.")
            return
        }
        
        let firstRangeValue = firstRange!.rangeValue
        
        let range = firstRangeValue.length == 0
            ? XCodeService.paragraphRange(string: code! as NSString, range: firstRangeValue)
            : RegX_fixRange(currentDocumentOptional.value, firstRangeValue)
        
        let selectedCode = XCodeService.substring(string: code!, range:range)
        
        let resultSelectedCode = changeAction(selectedCode)
        
        RegX_replaceSelectedText(currentDocumentOptional.value, range, resultSelectedCode)
    }
    
    deinit {
        self.notificationCenter.removeObserver(self)
    }
}
