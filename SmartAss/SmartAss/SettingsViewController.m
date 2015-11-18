//
//  SettingsViewController.m
//  SmartAss
//
//  Created by Tomas Vega on 9/13/15.
//  Copyright (c) 2015 Tomas Vega. All rights reserved.
//

#import "SettingsViewController.h"
#import "SettingsCellView.h"
#import "AppDelegate.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    self.feedbackVC = appDelegate.feedbackVC;
    self.notificationState = 0;
    self.activeResponseState = 0;
    self.juggleModeState = 0;
    [self setUI];
    // Do any additional setup after loading the view.
}

- (void) setUI {
    int topOffset = 60;
    int spaceBetween = 10;
    int settingCellHeight = 40;
    
    
    
    SettingsCellView *notificationCell = [[SettingsCellView alloc] initWithFrame:
                                CGRectMake(
                                           0,
                                           topOffset,
                                           self.view.frame.size.width,
                                           settingCellHeight
                                           )
                                ];
    [notificationCell setCellName:@"Notifications"];
    
    SettingsCellView *activeResponseCell = [[SettingsCellView alloc] initWithFrame:
                                                CGRectMake(
                                                           0,
                                                           110,
                                                           self.view.frame.size.width,
                                                           40
                                                           )
                                                ];
    
    [activeResponseCell setCellName:@"Active Response"];
    
//    activeResponseCell.cellSwitch.userInteractionEnabled = YES;
//    activeResponseCell.cellSwitch.enabled = YES;
    
    SettingsCellView *juggleModeCell = [[SettingsCellView alloc] initWithFrame:
                                          CGRectMake(
                                                     0,
                                                     160,
                                                     self.view.frame.size.width,
                                                    40
                                                     )
                                          ];
    [juggleModeCell setCellName:@"Juggle Mode"];
    
    [notificationCell.cellSwitch addTarget:self
                                    action:@selector(notificationToggle:)
                          forControlEvents:UIControlEventValueChanged];

    [activeResponseCell.cellSwitch addTarget:self
                                    action:@selector(activeResponseToggle:)
                          forControlEvents:UIControlEventValueChanged];

    [juggleModeCell.cellSwitch addTarget:self
                                    action:@selector(juggleModeToggle:)
                          forControlEvents:UIControlEventValueChanged];

    UIButton *calibrateButton = [UIButton buttonWithType:UIButtonTypeCustom];
    calibrateButton.frame = CGRectMake(
                                       (self.view.frame.size.width - 120)/2,
                                       310,
                                       120,
                                       50);
    [calibrateButton setBackgroundColor:[UIColor purpleColor]];
    [calibrateButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [calibrateButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [calibrateButton setTitle:@"Calibrate" forState:UIControlStateNormal];
    calibrateButton.layer.cornerRadius = 5;
    calibrateButton.layer.masksToBounds = YES;
    [self.view addSubview:calibrateButton];
    
    [calibrateButton addTarget:self.feedbackVC
                    action:@selector(calibrateButtonClick:)
                    forControlEvents:UIControlEventTouchDown];

    [calibrateButton addTarget:self.feedbackVC
                        action:@selector(calibrateButtonRelease:)
              forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:notificationCell];
    [self.view addSubview:activeResponseCell];
    [self.view addSubview:juggleModeCell];
}



- (void) notificationToggle: (id) sender {
    UISwitch *mySwitch = (UISwitch *)sender;
    if ([mySwitch isOn]) {
        self.notificationState = 1;
    } else {
        self.notificationState = 0;
    }
}

- (void) activeResponseToggle: (id) sender {
    UISwitch *mySwitch = (UISwitch *)sender;
    if ([mySwitch isOn]) {
        self.activeResponseState = 1;
    } else {
        self.activeResponseState = 0;
    }
}

- (void) juggleModeToggle: (id) sender {
    UISwitch *mySwitch = (UISwitch *)sender;
    if ([mySwitch isOn]) {
        self.juggleModeState = 1;
    } else {
        self.juggleModeState = 0;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
