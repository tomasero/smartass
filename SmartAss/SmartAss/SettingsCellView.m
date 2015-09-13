//
//  SettingsCellView.m
//  SmartAss
//
//  Created by Tomas Vega on 9/13/15.
//  Copyright (c) 2015 Tomas Vega. All rights reserved.
//

#import "SettingsCellView.h"

@implementation SettingsCellView


-  (id)initWithFrame:(CGRect)aRect
{
    self = [super initWithFrame:aRect];
    
    if (self)
    {
        [self setUI];
    }
    return self;
}

- (void) setUI {
    int labelHeight = 30;
    
    self.label = [[UILabel alloc] initWithFrame:CGRectMake(
                                                      self.frame.origin.x,
                                                      (self.frame.origin.y - labelHeight)/2,
                                                      self.frame.size.width/2,
                                                      labelHeight
                                                      )];
    self.label.textAlignment = NSTextAlignmentRight;
    self.label.textColor = [UIColor grayColor];
    [self addSubview:self.label];
    
    self.cellSwitch = [[UISwitch alloc] init];
    self.cellSwitch.onTintColor = [UIColor purpleColor];
    UIView *switchView = [[UIView alloc] initWithFrame:CGRectMake(
        self.frame.origin.x + (self.frame.size.width/2) + (self.frame.size.width/2 - self.cellSwitch.frame.size.width)/2,
        (self.frame.origin.y - self.cellSwitch.frame.size.height)/2,
        self.frame.size.width/2,
        self.cellSwitch.frame.size.height
        )];
    self.label.userInteractionEnabled = YES;
    switchView.userInteractionEnabled = YES;
    self.cellSwitch.userInteractionEnabled = YES;
    [switchView addSubview:self.cellSwitch];
    [self addSubview:switchView];
}

- (void) setCellName: (NSString *) name {
    self.label.text = name;
}



@end
