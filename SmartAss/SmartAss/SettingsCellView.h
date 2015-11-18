//
//  SettingsCellView.h
//  SmartAss
//
//  Created by Tomas Vega on 9/13/15.
//  Copyright (c) 2015 Tomas Vega. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsCellView : UIView

@property (nonatomic, strong) UILabel *label;
@property (retain, nonatomic) UISwitch *cellSwitch;

- (void) setCellName: (NSString *) name;

@end
