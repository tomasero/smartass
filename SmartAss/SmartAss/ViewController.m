//
//  ViewController.m
//  SmartAss
//
//  Created by Tomas Vega on 9/12/15.
//  Copyright (c) 2015 Tomas Vega. All rights reserved.
//

#import "ViewController.h"
#import "AFNetworking.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self setUI];
    
    [NSTimer scheduledTimerWithTimeInterval:.25
                                     target:self
                                   selector:@selector(updatePressure)
                                   userInfo:nil
                                    repeats:YES];
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

- (void) updatePressure {
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
        float flex1 = [[pressureDict objectForKey: @"flex1"] floatValue];
        float flex2 = [[pressureDict objectForKey: @"flex2"] floatValue];
        float flex3 = [[pressureDict objectForKey: @"flex3"] floatValue];
        float flex4 = [[pressureDict objectForKey: @"flex4"] floatValue];

//        float min = MIN(MIN(flex1, flex2), MIN(flex3, flex4));
        float min = 3800;
        float total = flex1 + flex2 + flex3 + flex4 - min*4;
        if(total < 0) {
            total = 1;
        }
        
        flex1 = MAX(flex1-min, 0);
        flex2 = MAX(flex2-min, 0);
        flex3 = MAX(flex3-min, 0);
        flex4 = MAX(flex4-min, 0);
        
        NSLog(@"%.1f %.1f %.1f %.1f", flex1, flex2, flex3, flex4);
        
        [self.cell1 updatePressure: flex1/total];
        [self.cell2 updatePressure: flex2/total];
        [self.cell3 updatePressure: flex3/total];
        [self.cell4 updatePressure: flex4/total];
//        [self.grid setNeedsDisplay];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
