//
//  RegularForm.swift
//  RegX
//
//  Created by Krunoslav Zaher on 10/18/14.
//  Copyright (c) 2014 Krunoslav Zaher. All rights reserved.
//

import Foundation

struct RegularForm  {
    let name : String
    let pattern : String
    let shortcut : String
    
    func alignColumns(text: String) -> String {
        var error : NSError?
        let regularExpression =
        NSRegularExpression(pattern: pattern,
                            options: NSRegularExpressionOptions.AllowCommentsAndWhitespace,
                              error: &error)
        
        return Regularizer.regularize(text, regularExpression: regularExpression!)
    }
}
