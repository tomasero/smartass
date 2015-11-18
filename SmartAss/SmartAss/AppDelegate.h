//
//  AppDelegate.h
//  SmartAss
//
//  Created by Tomas Vega on 9/12/15.
//  Copyright (c) 2015 Tomas Vega. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FeedbackViewController.h"
#import "SettingsViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, strong) FeedbackViewController* feedbackVC;
@property (nonatomic, strong) SettingsViewController* settingsVC;


@end

