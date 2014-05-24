//
//  ArrowViewController.h
//  PoloApp
//
//  Created by Matt Brenman on 2/2/14.
//  Copyright (c) 2014 mbrenman. All rights reserved.
//

@import UIKit;
@import QuartzCore;

#import <Parse/Parse.h>
@class ArrowView;

@interface ArrowViewController : UIViewController<CLLocationManagerDelegate>

@property (strong, nonatomic) IBOutlet ArrowView *compassView;
@property (nonatomic) NSString *targetUserName;
@property (weak, nonatomic) IBOutlet UILabel *DistanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *TargetLabel;

@property (nonatomic) id staticSender;
@property (nonatomic) BOOL staticLocation;

@end
