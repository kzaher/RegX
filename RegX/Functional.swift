//
//  Functional.swift
//  RegX
//
//  Created by Krunoslav Zaher on 10/19/14.
//  Copyright (c) 2014 Krunoslav Zaher. All rights reserved.
//

// this is because of accessing privately defined members
enum OptionalReflection {
    case Failure(AnyObject?, String)
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
            default: fatalError("Doesn't have value")
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

precedencegroup VeryLowPrecedence {
    associativity: left
    lowerThan: AssignmentPrecedence
}

infix operator .. : VeryLowPrecedence
postfix operator !!
func .. (object: OptionalReflection, selector: String) -> OptionalReflection {
    switch(object) {
    case .Failure(_, _): return object;
    case .Success(let object):
        let result : AnyObject! = RegX_performSelector(object, selector) as AnyObject;
        return result != nil
            ? OptionalReflection.Success(result)
            : OptionalReflection.Failure(object, selector)
    }
}

func .. (object: AnyObject!, selector: String) -> OptionalReflection {
    if object == nil {
        return .Failure(nil, selector)
    }
    
    let result : AnyObject! = RegX_performSelector(object, selector) as AnyObject;
    
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
        let result = object .. selector
        
        switch result {
        case .Success(_):return result
        default:break
        }
    }
    
    return .Failure(object.value, "\(selectors)")
}
