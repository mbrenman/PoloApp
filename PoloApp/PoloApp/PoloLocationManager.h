//
//  PoloLocationManager.h
//  PoloApp
//
//  Created by Susanne Heincke on 5/22/14.
//  Copyright (c) 2014 mbrenman. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CLLocationManager;
@class CLHeading;

@interface PoloLocationManager : NSObject

@property (nonatomic, strong) CLLocationManager *manager;
@property (nonatomic, strong) CLHeading *heading;

@property float myLat, myLong;

-(void)startUpdatingMyLocation;
-(void)stopUpdatingMyLocation;

@end
