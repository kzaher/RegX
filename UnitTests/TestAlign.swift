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

    override func setUp() {
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
                println("First difference at \(i): \(result.substringFromIndex(indexResult))")
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
            // https://www.debuggex.com/ <- use it
            regex: "^((?:\\s)*) (?# this is type declaration ->) ([^\\s](?:[^\\*]|(?:(?:(?<=/)\\*|\\*(?=/))))*\\s)  (?# this is variable declaration ->)    (?:\\s*)((?:(?<!/)(?!/)\\**)\\s*(?:\\w|\\d|_|-)+\\s*(?:;)?\\s*)$")
    }
    
    
    func testObjCAlignmentForDefines() {
        testOriginal(
            "#define A  1000\n" +
            "#define B()  4000\n" +
            "#define C (,,,er)  3000 + s\n" +
            "#if CHERRY && VINE\n" +
            "#  elif CHERRY2 && VINE2\n" +
            "# else BERRY\n" +
            "#endif\n"
            ,
            target:
            "#define     A          1000\n" +
            "#define     B()        4000\n" +
            "#define     C (,,,er)  3000 + s\n" +
            "#if         CHERRY && VINE\n" +
            "#   elif    CHERRY2 && VINE2\n" +
            "# else      BERRY\n" +
            "#endif\n",
            // https://www.debuggex.com/ <- use it
            regex: "^" +
                "(?: (?# this is define declaration ->)  (#\\s*define\\s) (?:\\s*) (\\S+\\s* (?#:\\([^\\)]*\\))\\s  " +
                "(?# space between macro value) (?:\\s*) (?# macro value) (\\S.+) )" +
                //"|" +
                //"(?# other declarations ->)  (#\\s*\\S+\\s)(?:\\s+)(\\S.+)  )" +
            "$")
    }
}
