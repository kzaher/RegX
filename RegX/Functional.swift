//
//  Functional.swift
//  RegX
//
//  Created by Krunoslav Zaher on 10/19/14.
//  Copyright (c) 2014 Krunoslav Zaher. All rights reserved.
//

// this is because of accessing privately defined members
enum OptionalReflection {
    case Failure(AnyObject!, String)
    case Success(AnyObject!)

    var hasValue : Bool {
        get {
            switch (self) {
            case .Success(let object) : return object != nil;
            default: return false;
            }
        }
    }
    
    var value : AnyObject {
        get {
            switch (self) {
            case .Success(let result) : return result
            default: assert(false)
            }
        }
    }
    
    var description : String {
        get {
            switch self {
            case .Success(let object) : return "\(object)"
            case .Failure(let object, let selectors) : return "\(object):\(selectors)"
            }
        }
    }
}

infix operator .. { associativity left precedence 160 }
postfix operator !! { }
func .. (object: OptionalReflection, selector: String) -> OptionalReflection {
    switch(object) {
    case .Failure(_, _): return object;
    case .Success(let object):
        let result : AnyObject! = RegX_performSelector(object, selector);
        return result != nil
            ? OptionalReflection.Success(result)
            : OptionalReflection.Failure(object, selector)
    }
}

func .. (object: AnyObject!, selector: String) -> OptionalReflection {
    if object == nil {
        return .Failure(nil, selector)
    }
    
    let result : AnyObject! = RegX_performSelector(object, selector);
    
    if result == nil {
        return .Failure(object!, selector)
    }
    
    return .Success(result)
}

func .. (object: OptionalReflection, selectors: [String]) -> OptionalReflection {
    switch object {
    case .Failure(_, _): return object
    default: break
    }
    
    for selector in selectors {
        var result = object .. selector
        
        switch result {
        case .Success(_):return result
        default:break
        }
    }
    
    return .Failure(object.value, "\(selectors)")
}

// this is not the most performant implementation, but it's good enough
func sequence<T>(range: Range<T>) -> [T] {
    var result : [T] = []
    for i in range {
        result.append(i)
    }
    
    return result
}

// From Haskell

func zip<T1, T2>(list1: [T1], list2: [T2]) -> [(T1, T2)] {
    var result : [(T1, T2)] = []
    
    for var it1 = list1.startIndex, it2 = list2.startIndex;
        it1 < list1.endIndex && it2 < list2.endIndex;
        it1 = it1.successor(), it2 = it2.successor() {
            result.append(list1[it1], list2[it2])
    }
    
    return result
}