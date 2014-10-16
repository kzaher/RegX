//
//  Regularize.swift
//  RegX
//
//  Created by Krunoslav Zaher on 10/15/14.
//  Copyright (c) 2014 Krunoslav Zaher. All rights reserved.
//

import Foundation

public class Regularizer  {

    public enum ParsedLineResult {
        case Raw(String)
        case Sections([String])
        
        func description() -> String {
            switch (self) {
            case .Raw(let line):return line
            case .Sections(let columns):return "|".join(columns)
            }
        }
    }
    
    private class func forEachLineLongEnough(parsedLines : [ParsedLineResult], onIndex: Int, action:ParsedLineResult -> ParsedLineResult) -> [ParsedLineResult] {
        return map(parsedLines) { (parsedResult) -> ParsedLineResult in
            switch (parsedResult) {
                case .Sections(let columns):
                    if (onIndex < columns.count) {
                        return action(parsedResult)
                    }
                default:break
            }
            return parsedResult
        }
    }
    
    private class func maxColumnWidth(parsedLines : [ParsedLineResult], onIndex: Int) -> Int {
        var maxWidth = 0
        forEachLineLongEnough(parsedLines, onIndex: onIndex) { parsedLine in
            switch (parsedLine) {
            case .Sections(let columns):
                let length = columns[onIndex].utf16Count
                if length > maxWidth {
                    maxWidth = length
                }
            default:break
            }
            
            return parsedLine
        }
        return maxWidth
    }
    
    private class func paddColumnToLength(parsedLines : [ParsedLineResult], onIndex: Int, length: Int) -> [ParsedLineResult] {
        return forEachLineLongEnough(parsedLines, onIndex: onIndex) { parsedLine in
            switch (parsedLine) {
            case .Sections(let columns):
                var transformedColumns = columns
             
                let text = transformedColumns[onIndex]
                let startIndex = 0//text.utf16Count
                let transformedText = text.stringByPaddingToLength(length, withString: " ", startingAtIndex: startIndex)
                transformedColumns[onIndex] = transformedText
                return .Sections(transformedColumns)
            default:break
            }
            return parsedLine
        }
    }
    
    public class func regularize(text: String, regularExpression: NSRegularExpression) -> String {
        let lines = text.componentsSeparatedByString("\n")
        
        let parsedLines : [ParsedLineResult] = lines.map { line -> ParsedLineResult in
            if (line.utf16Count == 0) {
                return ParsedLineResult.Raw(line)
            }
            
            let range = NSMakeRange(0, line.utf16Count)
            let matches = regularExpression.matchesInString(line, options:NSMatchingOptions.allZeros, range:range)
            
            if (matches.count == 0) {
                return ParsedLineResult.Raw(line)
            }
            
            let match : NSTextCheckingResult = matches[0] as NSTextCheckingResult
            var tokens : [String] = []
            
            //assert(match.numberOfRanges - 1 == settings.count)
            
            for i in 1..<match.numberOfRanges {
                let range : NSRange = match.rangeAtIndex(i)
                if range.location == NSNotFound {
                    continue
                }
                let substring = (line as NSString).substringWithRange(range)
                //let trimmedString = substring.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                let resultString = substring
                //trimmedString.utf16Count > 0
                  //  ? trimmedString
                  //  : substring
                tokens.append(resultString)
            }

            println("split \(tokens)")
            
            return ParsedLineResult.Sections(tokens)
        }
        
        var maxLineLength = reduce(parsedLines, 0) {
            switch ($1) {
            case .Sections(let sections):
                return $0 > sections.count ? $0 : sections.count
            default:
                return $0
            }
        }
        
        var resultColumns = parsedLines
        for i in 0..<maxLineLength {
            let maxWidth = maxColumnWidth(parsedLines, onIndex: i)
            if (maxWidth == 0) {
                continue
            }

            let minimalTargetWidth = maxWidth//+ (settings[i].needsSpaceAtThenEnd ? 1 : 0)// because of adding additional space
            
            // align to multiple of 4
            let targetWidth = minimalTargetWidth % 4 == 0
                    ? minimalTargetWidth
                    : ((minimalTargetWidth / 4) + 1) * 4
            
            resultColumns = paddColumnToLength(resultColumns, onIndex: i, length: targetWidth)
            println("columns \(map(resultColumns) { $0.description() })\n")
        }
       
        let linesWithJoinedLineContent = resultColumns.map { line -> String in
            switch (line) {
            case .Sections(let columns):
                return "".join(columns)
            case .Raw(let content):
                return content
            }
        }
      
        return "\n".join(linesWithJoinedLineContent)
    }
}
