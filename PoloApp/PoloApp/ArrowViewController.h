//
//  ArrowViewController.h
//  PoloApp
//
//  Created by Matt Brenman on 2/2/14.
//  Copyright (c) 2014 mbrenman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ArrowView.h"
#import <CoreLocation/CoreLocation.h>
#import <QuartzCore/QuartzCore.h>
#import <Parse/Parse.h>

@interface ArrowViewController : UIViewController<CLLocationManagerDelegate>

    @property (strong, nonatomic) PFUser *me;
    @property (strong, nonatomic) IBOutlet ArrowView *compassView;
	@property (nonatomic) CLLocationManager *locationManager;

@end
