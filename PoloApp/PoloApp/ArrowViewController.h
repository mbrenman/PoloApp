//
//  ArrowViewController.h
//  PoloApp
//
//  Created by Matt Brenman on 2/2/14.
//  Copyright (c) 2014 mbrenman. All rights reserved.
//

@import UIKit;
@import CoreLocation;
@import QuartzCore;

#import <Parse/Parse.h>
@class ArrowView;

@interface ArrowViewController : UIViewController<CLLocationManagerDelegate>

    @property (strong, nonatomic) PFUser *me;
    @property (strong, nonatomic) IBOutlet ArrowView *compassView;
	@property (nonatomic) CLLocationManager *locationManager;
    @property (nonatomic) CGFloat otherLat, otherLong;
    @property (nonatomic) NSString *targetUserName;
@end
