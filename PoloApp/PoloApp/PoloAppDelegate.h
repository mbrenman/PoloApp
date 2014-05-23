//
//  PoloAppDelegate.h
//  PoloApp
//
//  Created by Matt Brenman on 2/1/14.
//  Copyright (c) 2014 mbrenman. All rights reserved.
//

@import UIKit;
@class PoloLocationManager;

@interface PoloAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (readonly, strong, nonatomic) PoloLocationManager *locationManager;

+(instancetype)delegate;

@end
