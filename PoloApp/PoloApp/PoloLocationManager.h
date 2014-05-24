//
//  PoloLocationManager.h
//  PoloApp
//
//  Created by Susanne Heincke on 5/22/14.
//  Copyright (c) 2014 mbrenman. All rights reserved.
//
//
//how to use:
//when you want it to start do:
//
//PoloLocationManager *myLocationManager = [PoloAppDelegate delegate].locationManager;
//[myLocationManager startUpdatingMyLocation];
//
//to end do:
//
//PoloLocationManager *myLocationManager = [PoloAppDelegate delegate].locationManager;
//[myLocationManager startUpdatingMyLocation];
//
//to get info:
//
//PoloLocationManager *myLocationManager = [PoloAppDelegate delegate].locationManager;
//float temp = myLocationManager.myLong;
//
//if you include PoloAppDelegate.h and PoloLocationManager.h you can do this in any VC
//
//since the location manager lives in a property in the delegate it can be started in one VC...
//and ended or referenced in another.

#import <Foundation/Foundation.h>
@import CoreLocation;

@protocol PoloLocationManagerDelegate <NSObject>
-(void)headingWasUpdated;
@end

@interface PoloLocationManager : NSObject <CLLocationManagerDelegate>

@property (weak, nonatomic) id<PoloLocationManagerDelegate> delegate;

@property (nonatomic, strong) CLHeading *myHeading;
@property float myLat, myLong;

-(void)startUpdatingMyLocation;
-(void)stopUpdatingMyLocation;

@end
