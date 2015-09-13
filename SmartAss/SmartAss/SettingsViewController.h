//
//  SettingsViewController.h
//  SmartAss
//
//  Created by Tomas Vega on 9/13/15.
//  Copyright (c) 2015 Tomas Vega. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FeedbackViewController.h"

@interface SettingsViewController : UIViewController

@property (nonatomic, strong) FeedbackViewController *feedbackVC;
@property (assign) int notificationState;
@property (assign) int activeResponseState;
@property (assign) int juggleModeState;

@end
