//
//  RegXPlugin.m
//  RegX
//
//  Created by Krunoslav Zaher on 9/10/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

#import "RegXPlugin.h"
#import "RegX-Swift.h"

@implementation RegXPlugin

+ (void) load{
    NSBundle* app = [NSBundle mainBundle];
    NSString* identifier = [app bundleIdentifier];

    // Load only into Xcode
    if( ![identifier isEqualToString:@"com.apple.dt.Xcode"] ){
        return;
    }

    [self pluginDidLoadWithPlugin:app];
}

@end
