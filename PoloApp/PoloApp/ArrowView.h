//
//  ArrowView.h
//  PoloApp
//
//  Created by Matt Brenman on 2/2/14.
//  Copyright (c) 2014 mbrenman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <QuartzCore/QuartzCore.h>

@interface ArrowView : UIView
@property float newRad;
@property (nonatomic) IBOutlet UIImageView *compassImage;
@end
