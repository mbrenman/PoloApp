//
//  ArrowPathView.m
//  PoloApp
//
//  Created by Matt Brenman on 3/2/14.
//  Copyright (c) 2014 mbrenman. All rights reserved.
//

#import "ArrowPathView.h"

@interface ArrowPathView ()
    @property bool drawn;
@end

@implementation ArrowPathView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _drawn = NO;
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    if (!_drawn){
        NSLog(@"redraw");
        CGFloat height = CGRectGetHeight(self.bounds);
        CGFloat width = CGRectGetWidth(self.bounds);
        
        UIBezierPath *arrow = [UIBezierPath bezierPath];
        CGFloat padding = 30;
        
        [arrow moveToPoint:CGPointMake(0.0f + padding, height - padding)];
        [arrow addLineToPoint:CGPointMake(width/2, 0.0f + padding)];
        [arrow addLineToPoint:CGPointMake(width - padding, height - padding)];
        
        [[UIColor whiteColor] set];
        [arrow setLineWidth:padding];
        [arrow stroke];
        
        _drawn = YES;
    }
}


@end
