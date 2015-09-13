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
    self.grid = [[UIView alloc] initWithFrame:
        CGRectMake(
            0,
            (self.view.frame.size.height - self.view.frame.size.width)/2,
            self.view.frame.size.width,
            self.view.frame.size.width
        )
    ];
    
    [self.grid setBackgroundColor: [UIColor blackColor]];
    
    self.cell1 = [[CellView alloc] initWithFrame:
        CGRectMake(
            0,
            self.view.frame.origin.y,
            self.grid.frame.size.width/2,
            self.grid.frame.size.height/2
        )
    ];
    self.cell2 = [[CellView alloc] initWithFrame:
         CGRectMake(
            self.view.frame.size.width/2,
            self.view.frame.origin.y,
            self.grid.frame.size.width/2,
            self.grid.frame.size.height/2
        )
    ];
    self.cell3 = [[CellView alloc] initWithFrame:
        CGRectMake(
            0,
            self.view.frame.origin.y + self.grid.frame.size.height/2,
            self.grid.frame.size.width/2,
            self.grid.frame.size.height/2
        )
    ];
    self.cell4 = [[CellView alloc] initWithFrame:
        CGRectMake(
            self.view.frame.size.width/2,
            self.view.frame.origin.y + self.grid.frame.size.height/2,
            self.grid.frame.size.width/2,
            self.grid.frame.size.height/2
        )
    ];
    [self.grid addSubview: self.cell1];
    [self.grid addSubview: self.cell2];
    [self.grid addSubview: self.cell3];
    [self.grid addSubview: self.cell4];
    [self.view addSubview: self.grid];
}

- (void) updatePressure {
    NSURL *baseURL = [NSURL URLWithString:@"http://localhost:3000"];
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager manager] initWithBaseURL:baseURL];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:@"/getPressure" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError* error;
        NSDictionary* pressureDict = [NSJSONSerialization JSONObjectWithData:responseObject
            options:kNilOptions
            error:&error
        ];
        NSNumber *flex1 = [pressureDict objectForKey: @"flex1"];
        NSNumber *flex2 = [pressureDict objectForKey: @"flex2"];
        NSNumber *flex3 = [pressureDict objectForKey: @"flex3"];
        NSNumber *flex4 = [pressureDict objectForKey: @"flex4"];
        NSLog(@"%@", flex1);
        
        [self.cell1 updatePressure: flex1];
//        [self.cell1 removeFromSuperview];
//        [self.grid addSubview: self.cell1];
        [self.cell2 updatePressure: flex2];
        [self.cell3 updatePressure: flex3];
        [self.cell4 updatePressure: flex4];
        [self.grid setNeedsDisplay];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
