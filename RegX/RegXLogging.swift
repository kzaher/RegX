//
//  Logging.swift
//  RegX
//
//  Created by Krunoslav Zaher on 10/18/14.
//  Copyright (c) 2014 Krunoslav Zaher. All rights reserved.
//

import Cocoa

#if DEBUG = 1
    public let Log = NSLog
#else
    public let Log = NilLogger
#endif

func  NilLogger(_ format: String, args: CVarArg...) {
    
}

protocol ErrorPresenter {
    func showError(errorText: String)
}

class AlertErrorPresenter: ErrorPresenter {
    func showError(errorText: String) {
        let alert = NSAlert()
        alert.messageText = errorText
        alert.addButton(withTitle: "OK")
        
        NSLog(errorText)
        alert.runModal()
    }
}
