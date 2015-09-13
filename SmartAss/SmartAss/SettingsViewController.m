//
//  SettingsViewController.m
//  SmartAss
//
//  Created by Tomas Vega on 9/13/15.
//  Copyright (c) 2015 Tomas Vega. All rights reserved.
//

#import "SettingsViewController.h"
#import "SettingsCellView.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
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
                                                           topOffset + settingCellHeight + spaceBetween,
                                                           self.view.frame.size.width,
                                                           settingCellHeight
                                                           )
                                                ];
    
    [activeResponseCell setCellName:@"Active Response"];
    
    SettingsCellView *juggleModeCell = [[SettingsCellView alloc] initWithFrame:
                                          CGRectMake(
                                                     0,
                                                     topOffset + (settingCellHeight + spaceBetween)*2,
                                                     self.view.frame.size.width,
                                                     settingCellHeight
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

    [self.view addSubview:notificationCell];
    [self.view addSubview:activeResponseCell];
    [self.view addSubview:juggleModeCell];
}

- (void) notificationToggle: (id) sender {
    UISwitch *mySwitch = (UISwitch *)sender;
    if ([mySwitch isOn]) {
        //activate notifications
    } else {
        //off
    }
}

- (void) activeResponseToggle: (id) sender {
    NSLog(@"%@", sender);
}

- (void) juggleModeToggle: (id) sender {
    NSLog(@"%@", sender);
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
