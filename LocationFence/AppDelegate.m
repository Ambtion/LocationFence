//
//  AppDelegate.m
//  LocationFence
//
//  Created by quke on 16/3/30.
//  Copyright © 2016年 LJ. All rights reserved.
//

#import "AppDelegate.h"
#import "RootViewController.h"


@interface AppDelegate ()<CLLocationManagerDelegate>
@property(nonatomic,strong)CLLocation * curlocation;
@property(nonatomic,assign)UIBackgroundTaskIdentifier indetifer;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[RootViewController alloc] init]];
    [self.window makeKeyAndVisible];
    
    
//    [self postLocalNotificationWithMsg:@"启动"];
    
    [[UIApplication sharedApplication]registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound  categories:nil]];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    
    [self startLocation];
    
    return YES;
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    
    UIAlertController * alerC = [UIAlertController alertControllerWithTitle:[[notification userInfo] objectForKey:@"Msg"]  message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alerC addAction:action];
    
    [self.window.rootViewController presentViewController:alerC animated:YES completion:NULL];
}

- (void)startLocation
{
    if (!_locationManager) {
        
        _locationManager = [[CLLocationManager alloc] init];
        
        _locationManager.delegate = self;
        
        [_locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8) {
            [self.locationManager requestAlwaysAuthorization]; //
        }
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9) {
            _locationManager.allowsBackgroundLocationUpdates = YES;
        }
    }

    [_locationManager startUpdatingLocation];
    
}


- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    if (locations.count) {
        if (!self.curlocation) {
            self.curlocation = [locations firstObject];
            [self addFecnes];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
            if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
                [_locationManager requestWhenInUseAuthorization];
            }
            break;
        default:
            break;
    }
}


- (void)addFecnes
{
    
    CLLocationCoordinate2D companyCenter;
    
    if (self.curlocation) {
        companyCenter.latitude = self.curlocation.coordinate.latitude;
        companyCenter.longitude = self.curlocation.coordinate.longitude;
    }
    
    CLRegion *region = [[CLRegion alloc] initCircularRegionWithCenter:self.curlocation.coordinate radius:30.f identifier:@"fences"];
    [self startMonitoringForRegion:region];
}

- (void)startMonitoringForRegion:(CLRegion *)region
{
    
    NSMutableArray *regions = [[NSMutableArray alloc] initWithCapacity:0];
    for (CLRegion *monitored in [self.locationManager monitoredRegions])
    {
        [self.locationManager stopMonitoringForRegion:monitored];
        [regions addObject:monitored];
    }
    [regions addObject:region];
    
    if([CLLocationManager regionMonitoringEnabled])
    {
        for (CLRegion *region in regions)
        {
            [self.locationManager startMonitoringForRegion:region];
        }
    }else
    {
        
    }
}

- (void)startMonitoringForRegions:(NSArray *)regions
{
    
    for (CLRegion *monitored in [self.locationManager monitoredRegions])
    {
        [self.locationManager stopMonitoringForRegion:monitored];
    }
    
    if([CLLocationManager regionMonitoringEnabled])
    {
        for (CLRegion *region in regions)
        {
            [self.locationManager startMonitoringForRegion:region];
        }
    }else{
        
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [self postLocalNotificationWithMsg:@"定位失败"];
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error
{
    [self postLocalNotificationWithMsg:@"围栏注册失败"];
    
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(nonnull CLRegion *)region
{
    [self postLocalNotificationWithMsg:@"离开围栏"];
    [self qauryInBackGroud];
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(nonnull CLRegion *)region
{
    [self postLocalNotificationWithMsg:@"进入围栏"];
    [self qauryInBackGroud];
    
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    [self postLocalNotificationWithMsg:@"开始监控地理围栏"];
}


- (void)postLocalNotificationWithMsg:(NSString *)msg
{
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    if (notification) {
        
        notification.timeZone = [NSTimeZone defaultTimeZone]; // 使用本地时区
        notification.fireDate = [NSDate date];
        
        notification.repeatInterval = kCFCalendarUnitDay;
        notification.alertBody   = msg;
        notification.soundName = UILocalNotificationDefaultSoundName;
        //        notification.applicationIconBadgeNumber++;
        NSMutableDictionary *aUserInfo = [[NSMutableDictionary alloc] init];
        aUserInfo[@"Msg"] = msg;
        notification.userInfo = aUserInfo;
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
}

- (void)qauryInBackGroud
{
    self.indetifer = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.indetifer];
        self.indetifer = UIBackgroundTaskInvalid;
    }];
    
    
    //执行网络请求
    NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.baidu.com"] cachePolicy:NSURLErrorBackgroundSessionInUseByAnotherProcess timeoutInterval:20.f];
    
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request
                                               returningResponse:nil error:nil];
    if (returnData.length) {
        [self postLocalNotificationWithMsg:@"发起网络,请求成功"];
    }else{
        [self postLocalNotificationWithMsg:@"发起网络,请求失败"];
    }
}

@end
