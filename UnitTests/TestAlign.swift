//
//  TestAlign.swift
//  RegX
//
//  Created by Krunoslav Zaher on 10/15/14.
//  Copyright (c) 2014 Krunoslav Zaher. All rights reserved.
//

import Foundation
import XCTest

class TestAlign: XCTestCase {
    // https://www.debuggex.com/ <- use it
    let nonterminatedVariable = "((?:\\s)*) (?# this is type declaration ->) ([^\\s](?:[^\\*]|(?:(?:(?<=/)\\*|\\*(?=/))))*\\s)  (?# this is variable declaration ->)    (?:\\s*)((?:(?<!/)(?!/)\\**)\\s*(?:\\w|\\d|_|-)+\\s*(?:;)?\\s*)"
    
    let macroRegex = "^" +
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
    
    var propertyRegex : String = ""
    var variableRegex : String = ""
    var variableWithInitializer : String = ""
    
    override func setUp() {
        variableRegex = "^\(nonterminatedVariable)$"
        propertyRegex = "^(\\s*@property\\s*)(\\([^\\)]*)?(\\))?\\s" + nonterminatedVariable + "$"
        variableWithInitializer = "^\(variableRegex)$"
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    private func compareResult(result: String, test: String) {
        var indexResult = result.startIndex
        var indexTest = test.startIndex
        for i in 0..<min(result.utf16Count, test.utf16Count) {
            var firstChar = result[indexResult]
            var secondChar = test[indexTest]
            if firstChar != secondChar {
                println("First difference at \(i):\n\(result.substringFromIndex(indexResult))\n\nwhat should be there:\n\(test.substringFromIndex(indexTest))")
                break
            }
            
            indexResult = indexResult.successor()
            indexTest = indexTest.successor()
        }
        XCTAssert(result == test)
    }
    
    private func testOriginal(original: String, target: String, regex regexText: String) {
        println("regex = \(regexText)")
        
        var error : NSError?
        let regex = NSRegularExpression(pattern: regexText, options: NSRegularExpressionOptions.AllowCommentsAndWhitespace, error: &error)
       
        //let settings : [RegularExpressionGroupSettings] = RegularExpressionGroupSettings(needsSpaceAtTheEnd:false)
        let result : String = Regularizer.regularize(original, regularExpression: regex!)
        
        println("result \n\(result)")
        compareResult(result, test:target)
    }

    func objCTestAlignmentForVariables() {
        testOriginal(
            "       NSString *hello;\n" +
            "       id<NSObject> *hello2;\n" +
            "       id<NSObject>/**/    hello2;\n",
            target:
            "        NSString            *hello; \n" +
            "        id<NSObject>        *hello2;\n" +
            "        id<NSObject>/**/    hello2; \n",
            regex: variableRegex)
    }
    
    
    func testObjCAlignmentForDefines1() {
        testOriginal(
            "#define A  1000\n" +
            "#define B()  4000\n" +
            "#define C (,,,er)  3000 + s\n",
            target:
            "#define A           1000    \n" +
            "#define B()         4000    \n" +
            "#define C (,,,er)   3000 + s\n",
            regex:macroRegex)
    }
    
    func testObjCAlignmentForDefines2() {
        testOriginal(
                "#if CHERRY && VINE\n" +
                "#   elif CHERRY2 && VINE2\n" +
                "# else BERRY\n" +
            "#endif\n"
            ,
            target:
                "#if         CHERRY && VINE  \n" +
                "#   elif    CHERRY2 && VINE2\n" +
                "# else      BERRY           \n" +
            "#endif\n",
            regex:macroRegex)
    }
    
    func testPropertyRegex() {
        testOriginal(
            "   @property (nonatomic, assign) id<WhatEver>/*some description*/ variable;\n" +
            "   @property (nonatomic, strong, readonly) NSNumber *variable;\n" +
            "   @property (nonatomic, weak, copy) Fan variable;\n" +
            ""
            ,
            target:
            "   @property    (nonatomic, assign          )   id<WhatEver>/*some description*/    variable;   \n" +
            "   @property    (nonatomic, strong, readonly)   NSNumber                            *variable;  \n" +
            "   @property    (nonatomic, weak, copy      )   Fan                                 variable;   \n" +
            "",
            regex:propertyRegex)
    }
}
