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

-(CLLocationManager*)clLocationManager{
    if (!_clLocationManager){
        _clLocationManager = [[CLLocationManager alloc] init];
        _clLocationManager.delegate = self;
    }
    return _clLocationManager;
}

-(void)startUpdatingMyLocation {
    NSLog(@"in PLM: %@", self.clLocationManager);
    [self.clLocationManager startUpdatingHeading];
    [self.clLocationManager startUpdatingLocation];
    NSLog(@"in PLM2: %@", self.clLocationManager);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    NSLog(@"in did Update");
    CLLocation *newLoc = [locations lastObject];
    self.myLat = newLoc.coordinate.latitude;
    self.myLong = newLoc.coordinate.longitude;
    NSLog(@" -- myLat = %f", self.myLat);
    NSLog(@" -- myLong = %f", self.myLong);

}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading{
    
    self.myHeading = newHeading;
    NSLog(@" -- myHeading - %@", self.myHeading);
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    NSLog(@"Error while getting core location : %@",[error localizedFailureReason]);
    if ([error code] == kCLErrorDenied) {
        //you had denied
    }
    [manager stopUpdatingLocation];
}

-(void)stopUpdatingMyLocation {
    _clLocationManager = nil;
}

@end
