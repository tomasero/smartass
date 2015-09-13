//
//  FeedbackViewController.h
//  SmartAss
//
//  Created by Tomas Vega on 9/13/15.
//  Copyright (c) 2015 Tomas Vega. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CellView.h"

#import "SmartAss-Swift.h"

@interface FeedbackViewController : UIViewController <BLEDelegate>


@property (nonatomic, strong) UIView *grid;
@property (nonatomic, strong) CellView *cell1;
@property (nonatomic, strong) CellView *cell2;
@property (nonatomic, strong) CellView *cell3;
@property (nonatomic, strong) CellView *cell4;

- (void) calibrateButtonClick: (id) sender;
- (void) calibrateButtonRelease: (id) sender;
@property (nonatomic, strong) BLEController *ble;

@end
