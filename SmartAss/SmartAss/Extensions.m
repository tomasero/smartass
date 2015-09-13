//
//  Extensions.m
//  SmartAss
//
//  Created by Pierre Karashchuk on 9/13/15.
//  Copyright (c) 2015 Tomas Vega. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString (JRStringAdditions)

- (BOOL)containsString:(NSString *)string;
- (BOOL)containsString:(NSString *)string
               options:(NSStringCompareOptions)options;

@end

@implementation NSString (JRStringAdditions)

- (BOOL)containsString:(NSString *)string
               options:(NSStringCompareOptions)options {
    NSRange rng = [self rangeOfString:string options:options];
    return rng.location != NSNotFound;
}

- (BOOL)containsString:(NSString *)string {
    return [self containsString:string options:0];
}

@end