//
//  ArrowView.m
//  PoloApp
//
//  Created by Matt Brenman on 2/2/14.
//  Copyright (c) 2014 mbrenman. All rights reserved.
//

#import "ArrowView.h"

@interface ArrowView ()

@property (strong, nonatomic) UIImageView *imageView;

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
    if (!_imageView){
        _imageView = [ [ UIImageView alloc ] initWithFrame:CGRectMake(60.0, 120.0, _arrowImage.size.width, _arrowImage.size.height) ];
        _imageView.image = _arrowImage;
        [self addSubview:_imageView];
    }
    CGAffineTransform rotate = CGAffineTransformMakeRotation( _newRad );
    [_imageView setTransform:rotate];
}


@end
