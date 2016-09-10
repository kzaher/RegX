//
//  Regularize.swift
//  RegX
//
//  Created by Krunoslav Zaher on 10/15/14.
//  Copyright (c) 2014 Krunoslav Zaher. All rights reserved.
//

import Foundation

public class Regularizer  {
    let tabWidth : Int
    
    init (tabWidth : Int) {
        self.tabWidth = tabWidth
    }
    
    private enum ParsedLineResult {
        case Raw(String)
        case Sections([String])
        
        func description() -> String {
            switch (self) {
            case .Raw(let line):return line
            case .Sections(let columns):return columns.joined(separator: "|")
            }
        }
        
        var numberOfColumns : Int {
            switch (self) {
            case .Raw:
                assert(false)
                return 0
            case .Sections(let columns):
                return columns.count
            }
        }
    }
    
    private class func maxColumnWidth(parsedLines : [ParsedLineResult], index: Int) -> Int {
        return parsedLines.reduce(0) { max, line -> Int in
            switch line {
            case .Raw(_):
                return max
            case .Sections(let columns):
                if columns.count > index {
                    let column = columns[index]
                    let length = column.count()
                    return length > max ? length : max
                }
                else {
                    return max
                }
            }
        }
    }
    
    private class func paddColumnToWidths(parsedLines : [ParsedLineResult], widths: [Int]) -> [ParsedLineResult] {
        return parsedLines.map { line in
            switch (line) {
            case .Sections(let columns):
                let transformed = zip(columns, widths).map {
                    ($0 as NSString).padding(toLength: $1, withPad: " ", startingAt: 0)
                }
                return .Sections(transformed)
            default:
                return line
            }
        }
    }

    private class func isWhitespace(char: Character) -> Bool {
        // other solutions is swift were too compicated
        // this was good enough
        return char == " " || char == "\n" || char == "\t"
    }
    
    private class func trimStartWhitespace(string: String) -> String {
        for i in 0 ..< string.characters.count {
            let char = string.character(i)
            if !Regularizer.isWhitespace(char: char) {
                let range = string.index(at: i) ..< string.endIndex
                return string.substring(with: range)
            }
        }
        
        return ""
    }
    
    private class func trimEndWhitespace(string: String) -> String {
        for i in (0 ..< string.characters.count).reversed() {
            let char = string.character(i)
            if !Regularizer.isWhitespace(char: char) {
                let range = string.startIndex ..< string.index(at: i + 1)
                return string.substring(with: range)
            }
        }
        
        return ""
    }

    private class func trim(string: String, start: Bool, end: Bool) -> String {
        let str1 = start ? Regularizer.trimStartWhitespace(string: string) : string
        let str2 = end ? Regularizer.trimEndWhitespace(string: str1) : str1
        
        return str2
    }
    
    private func finalColumnWidth(startWidth: Int) -> Int {
        let minimalTargetWidth = startWidth
        
        let tabWidth = self.tabWidth > 0 ? self.tabWidth: 4
        
        return minimalTargetWidth % tabWidth == 0
                ? minimalTargetWidth
                : ((minimalTargetWidth / tabWidth) + 1) * tabWidth
    }
    
    func regularize(text: String,
                settings:[GroupSettings],
        regularExpression: NSRegularExpression) -> String {
        let lines = text.components(separatedBy: "\n")
        
        let parsedLines : [ParsedLineResult] = lines.map { line -> ParsedLineResult in
            if (line.count() == 0) {
                return ParsedLineResult.Raw(line)
            }
            
            let range = NSMakeRange(0, line.count())
            let matches = regularExpression.matches(in: line, options: NSRegularExpression.MatchingOptions(), range:range)
            
            if (matches.count == 0) {
                return ParsedLineResult.Raw(line)
            }
            
            let match : NSTextCheckingResult = matches[0]
            var tokens : [String] = []
            
            var widthGroup = 0
            for i in 1..<match.numberOfRanges {
                let range : NSRange = match.rangeAt(i)
                if range.location == NSNotFound {
                    continue
                }
                let substring = (line as NSString).substring(with: range)
                
                let settings = settings[i - 1]

                let paddingBefore = settings.paddingBefore != nil ? settings.paddingBefore! : 0
                let paddingBeforeString = "".padding(toLength: paddingBefore, withPad: " ", startingAt: 0)
                
                let paddingAfter = settings.paddingAfter != nil ? settings.paddingAfter! : 0
                let paddingAfterString  = "".padding(toLength: paddingAfter, withPad: " ", startingAt: 0)
                
                let trimmedString = Regularizer.trim(string: substring, start: settings.paddingBefore != nil, end: settings.paddingAfter != nil)
                
                tokens.append(paddingBeforeString + trimmedString + paddingAfterString)

                widthGroup += 1
            }

            return ParsedLineResult.Sections(tokens)
        }
        
        let maxNumColumns = parsedLines.reduce(0) {
            switch ($1) {
            case .Sections(let sections):
                return $0 > sections.count ? $0 : sections.count
            default:
                return $0
            }
        }
        
        var resultColumns = parsedLines
        let widths = (0..<maxNumColumns).map {
            self.finalColumnWidth(startWidth: Regularizer.maxColumnWidth(parsedLines: parsedLines, index: $0))
        }
        
        resultColumns = Regularizer.paddColumnToWidths(parsedLines: resultColumns, widths: widths)
        
        let linesWithJoinedLineContent = resultColumns.map { line -> String in
            switch (line) {
            case .Sections(let columns):
                return Regularizer.trimEndWhitespace(string: columns.joined(separator: ""))
            case .Raw(let content):
                return content
            }
        }
      
        return linesWithJoinedLineContent.joined(separator: "\n")
    }
}
