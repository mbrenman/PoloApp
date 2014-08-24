//
//  PoloLocationManager.m
//  PoloApp
//
//  Created by Susanne Heincke on 5/22/14.
//  Copyright (c) 2014 mbrenman. All rights reserved.
//

#import "PoloLocationManager.h"
#import "PoloAppDelegate.h"

@interface PoloLocationManager()

@property (nonatomic, strong) CLLocationManager *clLocationManager;

@end

@implementation PoloLocationManager

-(void)setMyHeading:(CLHeading*)heading{
    _myHeading = heading;
    if (self.delegate) {
        [self.delegate headingWasUpdated];
    }
}

-(CLLocationManager*)clLocationManager{
    if (!_clLocationManager){
        _clLocationManager = [[CLLocationManager alloc] init];
        _clLocationManager.delegate = self;
    }
    return _clLocationManager;
}

-(void)startUpdatingMyLocation {
    [self locationManagerShouldDisplayHeadingCalibration:self.clLocationManager];
    self.clLocationManager.desiredAccuracy = kCLLocationAccuracyBest;
	self.clLocationManager.headingFilter = 1;
    [self.clLocationManager startUpdatingHeading];
    [self.clLocationManager startUpdatingLocation];
}

- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager
{
    return YES;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *newLoc = [locations lastObject];
    self.myLat = newLoc.coordinate.latitude;
    self.myLong = newLoc.coordinate.longitude;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading{
    self.myHeading = newHeading;
}

-(void)stopUpdatingMyLocation {
    [self.clLocationManager stopUpdatingHeading];
    [self.clLocationManager stopUpdatingLocation];
}

@end
