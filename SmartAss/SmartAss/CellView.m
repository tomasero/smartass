//
//  CellView.m
//  SmartAss
//
//  Created by Tomas Vega on 9/12/15.
//  Copyright (c) 2015 Tomas Vega. All rights reserved.
//

#import "CellView.h"

@implementation CellView

-  (id)initWithFrame:(CGRect)aRect
{
    self = [super initWithFrame:aRect];
    
    if (self)
    {
        
    }
    
    return self;
}

//- (void) drawRect: (CGRect) rect {
//    [super drawRect:rect];
////    self.backgroundColor = [UIColor whiteColor];
////    CGRect rectangle = rect;
////    CGContextRef context = UIGraphicsGetCurrentContext();
////    CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
////    CGContextFillRect(context, rectangle);
//}

- (void) updatePressure: (NSNumber *) percentage {
    UIColor *pressureColor = [UIColor colorWithRed:1.0
    green:0.0
    blue:0.0
    alpha:(float)[percentage floatValue]/100];
//    NSLog(@"%f",[percentage floatValue]/100);
    self.backgroundColor = pressureColor;
    [self setNeedsDisplay];
    [self.superview setNeedsDisplay];
    
}

//- (void)drawRect:(CGRect)rect {
//    [super drawRect:rect];
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGPathRef path = CGPathCreateWithRect(rect, NULL);
//    CGContextSetRGBFillColor(context, 1.0, 0.0, 0.0, 1.0);
//    CGContextSetRGBStrokeColor(context, 0.0, 1.0, 2.0, 1.0);
//    CGContextAddPath(context, path);
//    CGContextDrawPath(context, kCGPathFillStroke);
//    CGPathRelease(path);
//}

@end
