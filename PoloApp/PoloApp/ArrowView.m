//
//  ArrowView.m
//  PoloApp
//
//  Created by Matt Brenman on 2/2/14.
//  Copyright (c) 2014 mbrenman. All rights reserved.
//

#import "ArrowView.h"
#import "ArrowPathView.h"

@interface ArrowView ()

@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIView *bezierArrowView;

@end

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
    if (!_bezierArrowView){
        NSLog(@"making again");
        
        CGFloat screenWidth = CGRectGetWidth(self.bounds);
        CGFloat screenHeight = CGRectGetHeight(self.bounds);
        
        //Rect sizes should change with the size of the screen for multi-device functionality
        
        CGFloat x_offset = screenWidth * .15f; //Allow 15 percent margin per side
        CGFloat y_offset = screenHeight * .30f; //Allow for a 30 percent top margin
        CGFloat width = screenWidth * 0.7f; //Only use 70 percent of available screen
        CGFloat height = width * .6f;
        
        _bezierArrowView = [[ArrowPathView alloc] initWithFrame:CGRectMake(x_offset, y_offset, width, height)];
        [self addSubview:_bezierArrowView];
    }
    CGAffineTransform rotate = CGAffineTransformMakeRotation(self.newRad);// - M_PI_2);
    [_bezierArrowView setTransform:rotate];
}


@end
