//
//  AppDelegate.h
//  LocationFence
//
//  Created by quke on 16/3/30.
//  Copyright © 2016年 LJ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property(nonatomic,strong)CLLocationManager * locationManager;

@end

