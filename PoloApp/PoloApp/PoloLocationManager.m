//
//  PoloLocationManager.m
//  PoloApp
//
//  Created by Susanne Heincke on 5/22/14.
//  Copyright (c) 2014 mbrenman. All rights reserved.
//

#import "PoloLocationManager.h"
@import CoreLocation;

@interface PoloLocationManager()

@property (nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation PoloLocationManager

-(CLLocationManager*)locationManager{
    if (!_locationManager){
        _locationManager = [[CLLocationManager alloc] init];
    }
    return _locationManager;
}

-(void)startUpdatingMyLocation {
    //doshit
    [self.locationManager startUpdatingHeading];
    [self.locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    self.myLat = manager.location.coordinate.latitude;
    self.myLong = manager.location.coordinate.longitude;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading{
    self.myHeading = manager.heading;
}

-(void)stopUpdatingMyLocation {
    _locationManager = nil;
}

@end
