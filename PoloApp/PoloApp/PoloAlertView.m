//
//  PoloAlertView.m
//  PoloApp
//
//  Created by Julian Locke on 7/30/14.
//  Copyright (c) 2014 mbrenman. All rights reserved.
//

#import "PoloAlertView.h"

@implementation PoloAlertView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization cod
        self.window.layer.cornerRadius = 50;
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/



@end
