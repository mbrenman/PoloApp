//
//  ArrowView.m
//  PoloApp
//
//  Created by Matt Brenman on 2/2/14.
//  Copyright (c) 2014 mbrenman. All rights reserved.
//

#import "ArrowView.h"

@implementation ArrowView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    UIImage *image = [UIImage imageNamed:@"compass_needle.png"];
    UIImageView *imageView = [ [ UIImageView alloc ] initWithFrame:CGRectMake(0.0, 100.0, image.size.width, image.size.height) ];
    imageView.image = image;
    [self addSubview:imageView];
    CGAffineTransform rotate = CGAffineTransformMakeRotation( _newRad );
    [imageView setTransform:rotate];
}


@end
