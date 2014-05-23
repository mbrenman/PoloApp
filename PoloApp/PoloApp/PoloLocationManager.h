//
//  PoloLocationManager.h
//  PoloApp
//
//  Created by Susanne Heincke on 5/22/14.
//  Copyright (c) 2014 mbrenman. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreLocation;

@interface PoloLocationManager : NSObject <CLLocationManagerDelegate>

@property (nonatomic, strong) CLHeading *myHeading;
@property float myLat, myLong;

-(void)startUpdatingMyLocation;
-(void)stopUpdatingMyLocation;

@end
