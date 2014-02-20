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
const unsigned int UPDATE_SECONDS = 1;

@interface ArrowViewController ()
@property int timer;
@property float radChange;
@property BOOL visible;
@property float myLat, myLong;
@property int numberOfCalls; //Not actually used for anything helpful
@property BOOL haveMyLoc, haveTargetLoc;
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
    
    _haveMyLoc = NO;
    _haveTargetLoc = NO;
    
    _numberOfCalls = 0;
    
    _visible = YES;
    
    _radChange = 0.0f;
    _otherLat = 0.0f;
    _otherLong = 0.0f;
    
    //Open a new thread to update the target angle regularly
    [self performSelectorInBackground:@selector(regularInfoUpdate) withObject:nil];
    
	_locationManager=[[CLLocationManager alloc] init];
	_locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	_locationManager.headingFilter = 1;
	_locationManager.delegate=self;
	[_locationManager startUpdatingHeading];
    
    _me = [PFUser currentUser];
}

- (void)regularInfoUpdate
{
    while (_visible)
    {
        [self updateLocations];
        NSLog(@"while");
        sleep(UPDATE_SECONDS);
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    NSLog(@"will dissapear");
    
    _visible = FALSE;
    
    //Zero out location data when we get off of the arrow
    _me[@"lat"] = [NSString stringWithFormat:@"%f", 0.0f];
    _me[@"long"] = [NSString stringWithFormat:@"%f", 0.0f];
    [_me saveInBackground];
    NSLog(@"should be zero");
    
    //Stop the view from trying to update when we turn the device
    [_locationManager stopUpdatingHeading];
    
    //Purge whitelist
}

- (IBAction)ArrowBackButtonPushed:(id)sender {
    NSLog(@"Pushed");
    [self performSegueWithIdentifier:@"ArrowToPerson" sender:nil];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading{
    
    if (_haveMyLoc && _haveTargetLoc){
        // Convert Degree to Radian to point the arrow
        float newRad =  -newHeading.trueHeading * M_PI / 180.0f;
    
        _radChange = [self findNewRadChangeForTarget];
        newRad += _radChange;

        [_compassView setNewRad:newRad];
        [_compassView setNeedsDisplay];
    } else {
        NSLog(@"denied.");
    }
}

- (float)findNewRadChangeForTarget
{
//    NSLog(@"findNewRad");
    
    float radChange = 0;
    float change = 0.0f;
    
    float dLat = _otherLat - _myLat;
    float dLong = _otherLong - _myLong;
    
    change = atan2(dLat, dLong);
    change -= M_PI_2;
    
    radChange -= change;
    
    return radChange;
}

- (void)updateLocations
{
    PFQuery *query= [PFUser query];
    [query whereKey:@"username" equalTo:_targetUserName];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error){
        
        //TODO: Only get the rest of the information if currentUser is in the target's whitelist
        //      Otherwise, show the connecting pictures
        
        float otherLat = [[object objectForKey:@"lat"] floatValue];
        float otherLong = [[object objectForKey:@"long"] floatValue];
        
        [self setOtherLat:otherLat];
        [self setOtherLong:otherLong];
        
        NSLog([NSString stringWithFormat:@"target location set %f, %f", otherLat, otherLong]);
        
        _haveTargetLoc = YES;
        
        [_compassView setNeedsDisplay];
    }];
    
    
    //Find my current location
    _myLat = _locationManager.location.coordinate.latitude;
    _myLong = _locationManager.location.coordinate.longitude;
    
    //Push my current location to the cloud (so partner can see it)
    _me[@"lat"] = [NSString stringWithFormat:@"%f", _myLat];
    _me[@"long"] = [NSString stringWithFormat:@"%f", _myLong];
    
    if (_visible){
        [_me saveInBackground];
    }
    _haveMyLoc = YES;
    
    NSLog(@"my location set");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
