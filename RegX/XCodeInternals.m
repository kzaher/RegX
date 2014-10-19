//
//  XCodeInternals.m
//  RegX
//
//  Created by Krunoslav Zaher on 10/18/14.
//  Copyright (c) 2014 Krunoslav Zaher. All rights reserved.
//

#import "XCodeInternals.h"

id                           RegX_performSelector(id object, NSString *selector) {
    SEL selectorObject = NSSelectorFromString(selector);
    id (*method)(id, SEL) = (void*)[object methodForSelector:selectorObject];
    if (method == nil) {
        return nil;
    }
    
    id result = method(object, selectorObject);
    
    return result;
}

void                        RegX_replaceSelectedText(IDESourceCodeDocument *document, NSRange range, NSString *text) {
    DVTSourceTextStorage *textStorage = document.textStorage;
    [textStorage beginEditing];
    [textStorage replaceCharactersInRange:range withString:text withUndoManager:document.undoManager];
    [textStorage endEditing];
}

NSRange                     RegX_fixRange(IDESourceCodeDocument *document, NSRange range) {
    DVTSourceTextStorage *textStorage = document.textStorage;

    NSRange lineRange = [textStorage lineRangeForCharacterRange:range];
	NSRange characterRange = [textStorage characterRangeForLineRange:lineRange];
    
    return characterRange;
}

#if LOGIC_TESTS
long long                   RegX_tabWidth() {
    assert(false);
}
#else
long long                   RegX_tabWidth() {
    return DVTTextPreferences.preferences.tabWidth;
}
#endif