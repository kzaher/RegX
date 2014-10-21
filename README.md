RegX
====

Prettify plugin for Xcode. It enables alignment of specific source code elements and makes code easier to read and understand.

![How does it work](/../content/images/demo.gif?raw=true "How does it work?")

# Installation

1. `$ git clone git@github.com:kzaher/RegX.git`
2. Build in Xcode. (building will automagically install it)
3. Restart Xcode and that should be it.

If it doesn't work, please check messages in console (`Console.app`) while starting Xcode and look for error messages. There is a possibility that you have Xcode version whose DVTPlugInCompatibilityUUID hasn't been specified in Info.plist. To resolve the issue, add your DVTPlugInCompatibilityUUID to Info.plist

# How does it work?

RegX uses regular expressions to group text in columns and align those columns.
Every regular expression group creates one vertically aligned column.
Additional settings for columns can be specified.

# Customization

All of the regular expressions and settings for them are defined in a file called 'Configuration.swift'.

e.g.

```swift
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
```

```swift
RegularForm(name: "Assignments",                            // name in Edit -> RegX menu
         pattern: Patterns.assignments,                     // grouping regular expression
        shortcut: String(UnicodeScalar(NSF4FunctionKey)),   // shortcut key
        modifier: NSEventModifierFlags.CommandKeyMask,      // shortcut modifier
        settings: [                                         // each setting controls start and end padding
                GroupSettings(nil, 0),                      // nil means keep existing padding
                GroupSettings(1,   1),                      // value means ensure padding
                GroupSettings(0,   0),
                GroupSettings(1,   0),
            ]
        )
```
