//
//  FeedbackViewController.m
//  SmartAss
//
//  Created by Tomas Vega on 9/13/15.
//  Copyright (c) 2015 Tomas Vega. All rights reserved.
//

#import "FeedbackViewController.h"
#import "AFNetworking.h"
#import "Extensions.m"


@interface FeedbackViewController ()

@end

@implementation FeedbackViewController

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self setUI];
    
//    [NSTimer scheduledTimerWithTimeInterval:.25
//                                     target:self
//                                   selector:@selector(getPressure)
//                                   userInfo:nil
//                                    repeats:YES];
    
    self.ble = [[BLEController alloc] initWithUIdelegate:self dataDelegate:self];
}

- (void) setUI {
    int space_between = 15;
    int label_height = 30;
    
    
    
    self.grid = [[UIView alloc] initWithFrame:
                 CGRectMake(
                            0,
                            (self.view.frame.size.height - self.view.frame.size.width)/2,
                            self.view.frame.size.width,
                            self.view.frame.size.width
                            )
                 ];
    
    int height =  (self.grid.frame.size.height-space_between*2)/2;
    int width = (self.grid.frame.size.width-space_between*3)/2;
    UILabel *label;
    
    [self.grid setBackgroundColor: [UIColor whiteColor]];
    
    self.cell1 = [[CellView alloc] initWithFrame:
                  CGRectMake(
                             space_between,
                             self.view.frame.origin.y,
                             width,
                             height
                             )
                  ];
    
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(self.cell1.frame.origin.x, self.cell1.frame.origin.y - label_height, width, label_height)];
    label.text = @"Front-left";
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor grayColor];
    [self.grid addSubview:label];
    
    self.cell2 = [[CellView alloc] initWithFrame:
                  CGRectMake(
                             space_between*2 + (self.grid.frame.size.width-space_between*3)/2,
                             self.view.frame.origin.y,
                             width,
                             height
                             )
                  ];
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(self.cell2.frame.origin.x, self.cell2.frame.origin.y - label_height, width, label_height)];
    label.text = @"Front-right";
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor grayColor];
    [self.grid addSubview:label];
    
    self.cell3 = [[CellView alloc] initWithFrame:
                  CGRectMake(
                             space_between,
                             self.view.frame.origin.y + self.grid.frame.size.height/2,
                             width,
                             height
                             )
                  ];
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(self.cell3.frame.origin.x, self.cell3.frame.origin.y + height, width, label_height)];
    label.text = @"Bottom-left";
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor grayColor];
    [self.grid addSubview:label];
    
    
    self.cell4 = [[CellView alloc] initWithFrame:
                  CGRectMake(
                             space_between*2 + (self.grid.frame.size.width-space_between*3)/2,
                             self.view.frame.origin.y + self.grid.frame.size.height/2,
                             width, height
                             )
                  ];
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(self.cell4.frame.origin.x, self.cell4.frame.origin.y + height, width, label_height)];
    label.text = @"Bottom-right";
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor grayColor];
    [self.grid addSubview:label];
    
    
    [self.grid addSubview: self.cell1];
    [self.grid addSubview: self.cell2];
    [self.grid addSubview: self.cell3];
    [self.grid addSubview: self.cell4];
    [self.view addSubview: self.grid];
}


- (void) updatePressure: (NSDictionary*) pressureDict {
    
    NSLog(@"dict: %@", pressureDict);
    
    float flex1 = [[pressureDict objectForKey: @"flex1"] floatValue];
    float flex2 = [[pressureDict objectForKey: @"flex2"] floatValue];
    float flex3 = [[pressureDict objectForKey: @"flex3"] floatValue];
    float flex4 = [[pressureDict objectForKey: @"flex4"] floatValue];
    
    //        float min = MIN(MIN(flex1, flex2), MIN(flex3, flex4));
    float min = 945;
//    float total = flex1 + flex2 + flex3 + flex4 - min*4;
    float total = 1024.0 - min;
    if(total < 0) {
        total = 1;
    }
    
    flex1 = MAX(flex1-min, 0);
    flex2 = MAX(flex2-min, 0);
    flex3 = MAX(flex3-min, 0);
    flex4 = MAX(flex4-min, 0);
    
    //        NSLog(@"%.1f %.1f %.1f %.1f", flex1, flex2, flex3, flex4);
    
    [self.cell1 updatePressure: flex1/total];
    [self.cell2 updatePressure: flex2/total];
    [self.cell3 updatePressure: flex3/total];
    [self.cell4 updatePressure: flex4/total];
}

- (void) getPressure {
    NSURL *baseURL = [NSURL URLWithString:@"http://buttpad.herokuapp.com"];
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager manager] initWithBaseURL:baseURL];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:@"/getPressure" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError* error;
        NSDictionary* pressureDict = [NSJSONSerialization JSONObjectWithData:responseObject
                                                                     options:kNilOptions
                                                                       error:&error
                                      ];


        [self updatePressure: pressureDict];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}


- (void) calibrateButtonClick: (id) sender {
    UIButton *calibrateButton = (UIButton *)sender;
    calibrateButton.alpha = 0.5;
}

- (void) calibrateButtonRelease: (id) sender {
    UIButton *calibrateButton = (UIButton *)sender;
    calibrateButton.alpha = 1;
}


NSMutableString *currData = nil;
- (void) didReceiveData: (NSData*) data {
    if(currData == nil) {
        currData =  [[NSMutableString alloc] init];
    }
    // act on data
//    NSLog(@"received data: %@", [data stringRepresentation]);

    NSString *s = [data stringRepresentation];
    
    [currData appendString:s];
//    NSLog(@"currData: %@", currData);
    
    NSRange range = [s rangeOfString:@"}"];
    
    if(range.location != NSNotFound) {
        
        NSRange r1 = [currData rangeOfString:@"{"];
        if(r1.location != NSNotFound) {
            [currData setString:[currData substringFromIndex:r1.location]];
            
            NSRange range = [currData rangeOfString:@"}"];

            NSString *ss = [currData substringToIndex:range.location+1];
//            NSLog(@"%@", ss);
            
            NSData *d = [ss dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
            
            
            NSError* error;
            NSDictionary* pressureDict = [NSJSONSerialization JSONObjectWithData:d options:kNilOptions error:&error];
            
            [self updatePressure:pressureDict];
        }
        
        
        NSRange range = [currData rangeOfString:@"}"];
        [currData setString:[currData substringFromIndex:range.location+1]];
    }
}

@end
