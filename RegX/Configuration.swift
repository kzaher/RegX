//
//  Configuration.swift
//  RegX
//
//  Created by Krunoslav Zaher on 10/19/14.
//  Copyright (c) 2014 Krunoslav Zaher. All rights reserved.
//

struct Configuration {
   
    struct Patterns {
        //
        // https://www.debuggex.com/ <- use it
        // Unit test will print concatenated pattern in console.
        // The printed pattern has comments and '#' and that breaks the tool,
        // so unit tests print expression that has no comments and '#' so it's
        // suitable for pasting into the browser.
        
        static func nonterminatedVariable(preserveStartSpace: Bool) -> String {
            let preserveStartSpacePattern = preserveStartSpace ? "\\s*" : ""
            return "" +
            "   (?# type declaration GROUP)   " +
            "       (" + preserveStartSpacePattern + "" +
            "           (?:[^\\s]  " +
            "               (?: [^\\*=/] | (?:(?<=/)\\*) | (?:\\*(?=/)) | (?:/(?!/)) )*" +
            "           )" +
            "       )" +
            "   (?# space GROUP)   " +
            "       (?:\\s*)" +
            "   (?# pointer GROUP)   " +
            "       ((?:(?<!/)(?!/)\\**)\\s*)" +
            "   (?# identifier GROUP)   " +
            "           ((?<!(?:\\w|\\d|_))(?:\\w|\\d|_|-)+" +
            "       (?# space)   " +
            "           \\s* " +
            "       (?# it can be ; or next is initializer declaration = )   " +
            "           (?:(?:;\\s*)|(?=\\s*\\=))" +
            "       \\s*)"
        }
        
         static let macroRegex = "^" +
            "(?: " +
            "   (?# this is define declaration GROUP)  " +
            "       (\\#\\s*define\\s) " +
            "   (?# space)  " +
            "       (?:\\s*) " +
            "   (?# macro name GROUP) " +
            "       ((?:[^\\s(])*   (?:  \\s*   \\( [^\\)]* \\) )?    )\\s  " +
            "   (?# space)" +
            "       (?:\\s*) " +
            "   (?# rest of line GROUP) " +
            "       ( (?:[^/] | (?:/(?!/)) )* )? " +
            "   (?# comments ) " +
            "       (//.*)? " +
            ")" +
            "|" +
            "(?:" +
            "   (?# definition name GROUP) " +
            "       (\\#\\s*\\w+\\s) " +
            "   (?# space) " +
            "       (?:\\s*)" +
            "   (?# rest of line GROUP) " +
            "       ( (?:[^/] |  (?:/(?!/)) )* )? " +
            "   (?# dummy empty GROUP to align with declaration comments) " +
            "       ([^/])? " +
            "   (?# comments ) " +
            "       (//.*)? " +
            ")$" +
        "";
        
        static let initializer =
            "(?# Initializer) " +
            "(?:" +
            "   (?# = and space GROUP )" +
            "       (\\=) \\s*" +
            "   (?# = until ; GROUP )" +
            "       ([^;]*;\\s*)" +
            ")? " +
            "(?# comments GROUP)" +
            "(//.*)??"

        static let assignments = "^" +
        "   (?# lvalue GROUP)" +
        "       ([^=]*)" +
        "   (?# = GROUP)" +
        "       (\\=) " +
        "   (?# expression GROUP)" +
        "       ((?:[^/] | (?:/(?!/)) )*)" +
        "   (?# comments GROUP)" +
        "       (//.*)?" +
        "$"
        
        
        static var propertyRegex : String {
            get {
                return "^" +
                "(?# property GROUP)" +
                "   (\\s*@property\\s*)" +
                "   (?# + everything until last bracket)" +
                "       (\\([^\\)]*)?" +
                "(?# last bracket GROUP)" +
                "   (\\))?" +
                "(?# space after)" +
                "\\s*\(nonterminatedVariable(false))(?:\\s*) \(initializer)$"
            }
        }

        static var bigMacro: String {
            get {
                return "^" +
                    "([^\\\\]*)" +
                    "(\\\\)" +
                "$"
            }
        }

        static var variableWithInitializer : String {
            get {
                return "^\(nonterminatedVariable(true))(?:\\s*) \(initializer)$"
            }
        }
    }
    
    static var forms : [RegularForm] {
        return [
            RegularForm(name: "Macros",
                     pattern: Patterns.macroRegex,
                    shortcut: String(UnicodeScalar(NSF1FunctionKey)),
                    modifier: NSEventModifierFlags.Command,
                    settings: [
                        GroupSettings(nil, 1),
                        GroupSettings(nil, 4),
                        GroupSettings(nil, 1),
                        GroupSettings(nil, 0),
                        // identical because of two branches
                        GroupSettings(nil, 1),
                        GroupSettings(nil, 4),
                        GroupSettings(nil, 1),
                        GroupSettings(nil, 0),
                ]
            ),
            RegularForm(name: "ObjC Property",
                     pattern: Patterns.propertyRegex,
                    shortcut: String(UnicodeScalar(NSF2FunctionKey)),
                    modifier: NSEventModifierFlags.Command,
                    settings: [
                        GroupSettings(nil, 1),
                        GroupSettings(nil, 0),
                        GroupSettings(nil, 1),
                        GroupSettings(nil, 2),
                        GroupSettings(nil, 0),
                        GroupSettings(nil, 0),
                        GroupSettings(1,   1),
                        GroupSettings(nil, 0),
                        GroupSettings(1,   0),
                ]
            ),
            RegularForm(name: "Variables",
                     pattern: Patterns.variableWithInitializer,
                    shortcut: String(UnicodeScalar(NSF3FunctionKey)),
                    modifier: NSEventModifierFlags.Command,
                    settings: [
                        GroupSettings(nil, 2),
                        GroupSettings(nil, 0),
                        GroupSettings(nil, 0),
                        GroupSettings(1,   1),
                        GroupSettings(nil, 0),
                        GroupSettings(1,   0),
                ]
            ),
            RegularForm(name: "Assignments",
                pattern: Patterns.assignments,
                shortcut: String(UnicodeScalar(NSF4FunctionKey)),
                modifier: NSEventModifierFlags.Command,
                settings: [
                    GroupSettings(nil, 0),
                    GroupSettings(1,   1),
                    GroupSettings(0,   0),
                    GroupSettings(1,   0),
                ]
            ),
            RegularForm(name: "Big ObjC macro",
                pattern: Patterns.bigMacro,
                shortcut: String(UnicodeScalar(NSF5FunctionKey)),
                modifier: NSEventModifierFlags.Command,
                settings: [
                    GroupSettings(nil, 0),
                    GroupSettings(1,   0)
                ]
            ),
        ]
    }
}
