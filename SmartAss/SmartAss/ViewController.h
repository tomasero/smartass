//
//  ViewController.h
//  SmartAss
//
//  Created by Tomas Vega on 9/12/15.
//  Copyright (c) 2015 Tomas Vega. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CellView.h"

#import "SmartAss-Swift.h"

@interface ViewController : UIViewController <BLEDelegate>

@property (nonatomic, strong) UIView *grid;
@property (nonatomic, strong) CellView *cell1;
@property (nonatomic, strong) CellView *cell2;
@property (nonatomic, strong) CellView *cell3;
@property (nonatomic, strong) CellView *cell4;

@property (nonatomic, strong) BLEController *ble;

@end

