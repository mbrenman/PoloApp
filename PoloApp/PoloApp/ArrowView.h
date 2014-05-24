//
//  ArrowView.h
//  PoloApp
//
//  Created by Matt Brenman on 2/2/14.
//  Copyright (c) 2014 mbrenman. All rights reserved.
//

@import UIKit;
@import QuartzCore;

@interface ArrowView : UIView
@property (nonatomic) CGFloat newRad;
@property (nonatomic) IBOutlet UIImageView *compassImageView;
@property (strong, nonatomic) UIImage *arrowImage;
@end
