//
//  RootViewController.m
//  FenceDemon
//
//  Created by kequ on 15/11/29.
//  Copyright © 2015年 ke. All rights reserved.
//

#import "RootViewController.h"
#import "AppDelegate.h"


@interface RootViewController ()
@end

@implementation RootViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    UIButton * button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(100, self.view.frame.size.width/2.f - 50, 100, 40);
    [button addTarget:self action:@selector(buttoonCLick:) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"删除围栏" forState:UIControlStateNormal];
    button.backgroundColor = [UIColor redColor];
    [self.view addSubview:button];
    button.center = CGPointMake(self.view.frame.size.width/2.f, button.center.y);
}

- (void)buttoonCLick:(UIButton *)button
{
    CLLocationManager * loc = [(AppDelegate *)[[UIApplication sharedApplication] delegate] locationManager];
    NSMutableArray *regions = [[NSMutableArray alloc] initWithCapacity:0];
    for (CLRegion *monitored in [loc monitoredRegions])
    {
        [loc stopMonitoringForRegion:monitored];
    }
    
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] qauryInBackGroud];
    
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"删除成功" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alert show];
}

@end
