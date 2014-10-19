//
//  Configuration.swift
//  RegX
//
//  Created by Krunoslav Zaher on 10/19/14.
//  Copyright (c) 2014 Krunoslav Zaher. All rights reserved.
//

struct Configuration {
   
    struct Patterns {
        // https://www.debuggex.com/ <- use it
        static let nonterminatedVariable = "(\\s*(?# this is type declaration ->) (?:[^\\s](?:[^\\*=]|(?:(?:(?<=/)\\*|\\*(?=/))))*) )  (?# this is variable declaration ->)    (?:\\s*)((?:(?<!/)(?!/)\\**)\\s*)((?<!(?:\\w|\\d|_))(?:\\w|\\d|_|-)+\\s*(?:(?:;\\s*)|(?=\\s*\\=))\\s*)"
        
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
        
        static let initializer = "(?# Initializer) (?: (\\s*) (\\=\\s*) ([^;]*;\\s*))?"
        
        static var variableRegex : String {
            get {
                return "^\(nonterminatedVariable)$"
            }
        }
        static var propertyRegex : String {
            get {
                return "^(\\s*@property\\s*)(\\([^\\)]*)?(\\))?\\s*" + nonterminatedVariable + "$"
            }
        }
        static var variableWithInitializer : String {
            get {
                return "^\(nonterminatedVariable)(?:\\s*) \(initializer)$"
            }
        }
    }
    
    static var forms : [RegularForm] {
        return [
            RegularForm(name: "Macros",
                     pattern: Patterns.macroRegex,
                    shortcut: String(UnicodeScalar(NSF1FunctionKey)),
                    modifier: NSEventModifierFlags.CommandKeyMask,
                   minSpaces: [4, 4, 0]),
            RegularForm(name: "ObjC Property",
                     pattern: Patterns.propertyRegex,
                    shortcut: String(UnicodeScalar(NSF2FunctionKey)),
                    modifier: NSEventModifierFlags.CommandKeyMask,
                   minSpaces: [1, 0, 1, 2, 0, 0, 1, 1, 0]),
            RegularForm(name: "Variables",
                     pattern: Patterns.variableWithInitializer,
                    shortcut: String(UnicodeScalar(NSF3FunctionKey)),
                    modifier: NSEventModifierFlags.CommandKeyMask,
                   minSpaces: [2, 0, 0, 1, 1, 0]),
                        ]
    }
}
