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
        super.tearDown()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    private func compareResult(result: String, test: String) {

        let minCount = min(result.count(), test.count())
        for i in 0 ..<  minCount {
            let indexResult = result.index(at: i)
            let indexTest = test.index(at: i)

            let firstChar = result[indexResult]
            let secondChar = test[indexTest]

            if firstChar != secondChar {
                print("First difference at \(i):\n\(result.substring(from: indexResult))\n\nwhat should be there:\n\(test.substring(from: indexTest))")
                break
            }
        }
        XCTAssert(result == test)
    }

    // https://www.debuggex.com has problems with comments and '#'
    // This function removes (?# .... ) constructs and '#' from pattern
    private func escapeForVisualization(pattern: String) -> String {
        let stripCommentsRegex = try! NSRegularExpression(pattern:"\\(\\?#[^\\)]*\\)", options: NSRegularExpression.Options())
        
        let range = NSMakeRange(0, pattern.count())
        
        let nsPattern : NSString = pattern as NSString
        let mutableNsPattern : NSMutableString = nsPattern.mutableCopy() as! NSMutableString
        
        stripCommentsRegex.replaceMatches(in: mutableNsPattern, options: NSRegularExpression.MatchingOptions(), range:range, withTemplate: "")
        
        let hashless = mutableNsPattern.replacingOccurrences(of: "#", with: "<hash>")
        
        return hashless
    }
    
    private func testOriginal(original: String, target: String, specifier: RegularForm) {
        let result : String = specifier.alignColumns(text: original, tabWidth:1)
        if result != target {
            print("RegEx pattern: \n\(specifier.pattern)")
            print("RegEx to debug on https://www.debuggex.com/ (choose PCRE and ignore spaces option):\n\(escapeForVisualization(pattern: specifier.pattern))")
            print("result: \n\(result)")
        }
        compareResult(result: result, test:target)
    }

    func testObjCTestAlignmentForVariables() {
        testOriginal(
            original:
            "       NSString* wrong;\n" +
            "       NSString *hello;\n" +
            "       id<NSObject> *hello2;\n" +
            "       id<NSObject>/**/    hello2;\n",
            target:
            "       NSString          *wrong;\n" +
            "       NSString          *hello;\n" +
            "       id<NSObject>      *hello2;\n" +
            "       id<NSObject>/**/   hello2;\n",
            specifier: Configuration.forms[2])
    }
    
    func testObjCTestAlignmentForVariablesAndComments() {
        testOriginal(
            original:
            "       NSString* wrong; // *a;\n" +
            "       NSString *hello; // 12310238193* sdfs = 34;\n" +
            "       id<NSObject> *hello2;\n" +
            "       id<NSObject>/**/    hello2;\n",
            target:
            "       NSString          *wrong;  // *a;\n" +
            "       NSString          *hello;  // 12310238193* sdfs = 34;\n" +
            "       id<NSObject>      *hello2;\n" +
            "       id<NSObject>/**/   hello2;\n",
            specifier: Configuration.forms[2])
    }
    
    func testObjCTestAlignmentForVariablesWithInitializers() {
        testOriginal(
            original:
            "       NSString* wrong = [something there];\n" +
            "       NSString *hello =     adaa();\n" +
            "       id<NSObject> *hello2 = 34 * lj;\n" +
            "       id<NSObject>/**/    hello2 = nil;\n",
            target:
            "       NSString          *wrong  = [something there];\n" +
            "       NSString          *hello  = adaa();\n" +
            "       id<NSObject>      *hello2 = 34 * lj;\n" +
            "       id<NSObject>/**/   hello2 = nil;\n",
            specifier: Configuration.forms[2])
    }

    func testObjCTestAlignmentForVariablesWithInitializersAndComments() {
        testOriginal(
            original:
            "       NSString* wrong = [something there]; // a\n" +
            "       NSString *hello =     adaa(); // * dsds\n" +
            "       id<NSObject> *hello2 = 34 * lj;  // = 23\n" +
            "       id<NSObject>/**/    hello2 = nil; // * sds = 34343\n",
            target:
            "       NSString          *wrong  = [something there]; // a\n" +
            "       NSString          *hello  = adaa();            // * dsds\n" +
            "       id<NSObject>      *hello2 = 34 * lj;           // = 23\n" +
            "       id<NSObject>/**/   hello2 = nil;               // * sds = 34343\n",
            specifier: Configuration.forms[2])
    }
    
    func testObjCAlignmentForDefines1() {
        testOriginal(
            original:
            "#define A  1000\n" +
            "#define B()  4000\n" +
            "#define C (,,,er)  3000 + s\n",
            target:
            "#define A            1000\n" +
            "#define B()          4000\n" +
            "#define C (,,,er)    3000 + s\n",
            specifier: Configuration.forms[0])
    }
    
    func testObjCAlignmentForDefines2() {
        testOriginal(
            original:
                "#if CHERRY && VINE\n" +
                "#   elif CHERRY2 && VINE2\n" +
                "# else BERRY\n" +
                "#endif\n"
            ,
            target:
                "#if      CHERRY && VINE\n" +
                "#   elif CHERRY2 && VINE2\n" +
                "# else   BERRY\n" +
                "#endif\n",
            specifier: Configuration.forms[0])
    }
    
    
    func testObjCAlignmentForDefinesWithComments() {
        testOriginal(
            original:
            "#if CHERRY && VINE // () comment define 1\n" +
                "#   elif CHERRY2 && VINE2 // # else\n" +
                "# else BERRY // * this is a normal comment\n" +
            "#endif // comment end\n"
            ,
            target:
            "#if      CHERRY && VINE      // () comment define 1\n" +
            "#   elif CHERRY2 && VINE2    // # else\n" +
            "# else   BERRY               // * this is a normal comment\n" +
            "#endif                       // comment end\n",
            specifier: Configuration.forms[0])
    }
    
    func testObjCAlignmentForDefinesWithComments2() {
        testOriginal(
            original:
            "#define TEXPECT(ocmock)                             (__typeof(ocmock))([(OCMockObject*)(ocmock) expect]) // first * ()\n" +
            "#define STUB_IGNORING_NON_OBJECT_ARGS(ocmock)       [[(OCMockObject*)(ocmock) stub] // hi ()\n" +
            "#define STUB_IGNORING_NON_OBJECT_ARGS(ocmock)       [[(OCMockObject*)(ocmock) stub]\n" +
            ""
            ,
            target:
            "#define TEXPECT(ocmock)                          (__typeof(ocmock))([(OCMockObject*)(ocmock) expect]) // first * ()\n" +
            "#define STUB_IGNORING_NON_OBJECT_ARGS(ocmock)    [[(OCMockObject*)(ocmock) stub]                      // hi ()\n" +
            "#define STUB_IGNORING_NON_OBJECT_ARGS(ocmock)    [[(OCMockObject*)(ocmock) stub]\n" +
            "",
            specifier: Configuration.forms[0])
    }
    
    func testPropertyRegex() {
        testOriginal(
            original:
            "   @property (nonatomic, strong) NSMutableDictionary*stationSessions;\n" +
            "   @property (nonatomic, assign) id<WhatEver>/*some description*/ variable;\n" +
            "   @property (nonatomic, strong, readonly) NSNumber *variable;\n" +
            "   @property (nonatomic, weak, copy) Fan variable;\n" +
            ""
            ,
            target:
            "   @property (nonatomic, strong          ) NSMutableDictionary               *stationSessions;\n" +
            "   @property (nonatomic, assign          ) id<WhatEver>/*some description*/   variable;\n" +
            "   @property (nonatomic, strong, readonly) NSNumber                          *variable;\n" +
            "   @property (nonatomic, weak, copy      ) Fan                                variable;\n" +
            "",
            specifier: Configuration.forms[1])
    }
    
    func testPropertiesWithComments() {
        testOriginal(
            original:
            "   @property (nonatomic, strong) NSMutableDictionary*stationSessions; // a *dasda;\n" +
            "   @property (nonatomic, assign) id<WhatEver>/*some description*/ variable; // @property\n" +
            "   @property (nonatomic, strong, readonly) NSNumber *variable; // normal comment\n" +
            "   @property (nonatomic, weak, copy) Fan variable; // ^)(*__)(&%@%$@\n" +
            ""
            ,
            target:
            "   @property (nonatomic, strong          ) NSMutableDictionary               *stationSessions; // a *dasda;\n" +
            "   @property (nonatomic, assign          ) id<WhatEver>/*some description*/   variable;        // @property\n" +
            "   @property (nonatomic, strong, readonly) NSNumber                          *variable;        // normal comment\n" +
            "   @property (nonatomic, weak, copy      ) Fan                                variable;        // ^)(*__)(&%@%$@\n" +
            "",
            specifier: Configuration.forms[1])
    }
    
    func testAssignments() {
        testOriginal(
            original:
            "   aas01312[23] = seven<sds> / 23 // comment;\n" +
            "   *(aas01312[23] + 1) = [self sendMessage:@\"hello\"] + 23;\n" +
            "   _variable = sum(square(34); // third comment = sum\n" +
            ""
            ,
            target:
            "   aas01312[23]        = seven<sds> / 23                   // comment;\n" +
            "   *(aas01312[23] + 1) = [self sendMessage:@\"hello\"] + 23;\n" +
            "   _variable           = sum(square(34);                   // third comment = sum\n" +
            "",
            specifier: Configuration.forms[3])
    }

    func testBigMacro() {
        testOriginal(
            original:
            "  something1 \\\n" +
            "  something1 adsakjda \\\n" +
            "  something1 \\\n" +
            "",
            target:
            "  something1          \\\n" +
            "  something1 adsakjda \\\n" +
            "  something1          \\\n" +
            "",
            specifier: Configuration.forms[4])
    }
}
