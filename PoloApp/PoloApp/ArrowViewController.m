//
//  ArrowViewController.m
//  PoloApp
//
//  Created by Matt Brenman on 2/2/14.
//  Copyright (c) 2014 mbrenman. All rights reserved.
//

#import "ArrowViewController.h"
#import "ArrowView.h"
#import <Parse/Parse.h>

const float TIMER_MAX = 100;

@interface ArrowViewController ()
@property int timer;
@property float radChange;
@property int numberOfCalls;
@end

@implementation ArrowViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    [_compassView setArrowImage:[UIImage imageNamed:@"chevron.jpeg"]];
    
    _timer = TIMER_MAX;
    
    _numberOfCalls = 0;
    
    _radChange = 0.0f;
    _otherLat = 0.0f;
    _otherLong = 0.0f;
    
	_locationManager=[[CLLocationManager alloc] init];
	_locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	_locationManager.headingFilter = 1;
	_locationManager.delegate=self;
	[_locationManager startUpdatingHeading];
    
    _me = [PFUser currentUser];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    NSLog(@"will dissapear");
    
    //Zero out location data when we get off of the arrow
    _me[@"lat"] = @"0";
    _me[@"long"] = @"0";
    [_me saveInBackground];
    
    //Stop the view from trying to update when we turn the device
    [_locationManager stopUpdatingHeading];
    //Purge whitelist
}

- (IBAction)ArrowBackButtonPushed:(id)sender {
    NSLog(@"Pushed");
    [self performSegueWithIdentifier:@"ArrowToPerson" sender:nil];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading{
    // Convert Degree to Radian to point the arrow
	float newRad =  -newHeading.trueHeading * M_PI / 180.0f;
    
    if (_timer == TIMER_MAX){
        _radChange = [self findNewRadChangeForTarget];
        _timer = 0;
    } else {
        _timer++;
    }
    
    
    newRad += _radChange;
    [_compassView setNewRad:newRad];
    [_compassView setNeedsDisplay];
}

- (float)findNewRadChangeForTarget
{
    
    _numberOfCalls++;
    
    float radChange = 0;
    //Find my current location
    float myLat = _locationManager.location.coordinate.latitude;
    float myLong = _locationManager.location.coordinate.longitude;
    
    //Push my current location to the cloud (so partner can see it)
    _me[@"lat"] = [NSString stringWithFormat:@"%f", myLat];
    _me[@"long"] = [NSString stringWithFormat:@"%f", myLong];
    
    [_me saveInBackground];
    
    //TODO: Actually get this from somebody else
    
    PFQuery *query= [PFUser query];
    [query whereKey:@"username" equalTo:_targetUserName];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error){
        
        //TODO: Only get the rest of the information if currentUser is in the target's whitelist
        //      Otherwise, show the connecting pictures
        
        float otherLat = [[object objectForKey:@"lat"] floatValue];
        float otherLong = [[object objectForKey:@"long"] floatValue];
            
        NSLog([NSString stringWithFormat:@"SUP DUDE... %d", _numberOfCalls]);
            
        [self setOtherLat:otherLat];
        [self setOtherLong:otherLong];
            
        [_compassView setNeedsDisplay];
    }];
    
    float change = 0.0f;
    
    float dLat = _otherLat - myLat;
    float dLong = _otherLong - myLong;
    
    if ((_otherLat != 0.0) && (_otherLong != 0.0)){
        change = atan2(dLat, dLong);
        change -= M_PI_2;
    
        radChange -= change;
    }
    
    return radChange;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
