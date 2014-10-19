//
//  RegularForm.swift
//  RegX
//
//  Created by Krunoslav Zaher on 10/18/14.
//  Copyright (c) 2014 Krunoslav Zaher. All rights reserved.
//

import Foundation
import AppKit

struct RegularForm  {
    let name : String
    let pattern : String
    let shortcut : String
    let modifier : NSEventModifierFlags
    let minSpaces : [Int]
    
    func alignColumns(text: String, tabWidth: Int) -> String {
        var error : NSError?
        let regularExpression =
        NSRegularExpression(pattern: pattern,
                            options: NSRegularExpressionOptions.AllowCommentsAndWhitespace,
                              error: &error)
        
        return Regularizer(tabWidth: tabWidth).regularize(text, minSpaces: minSpaces, regularExpression: regularExpression!)
    }
}
