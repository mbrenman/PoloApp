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

const unsigned int UPDATE_SECONDS = 1;
const float EARTH_RADIUS = 3963.1676;

@interface ArrowViewController ()
@property float radChange;
@property float myLat, myLong;
@property (nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) PFUser *me;
@property (retain, nonatomic) CLHeading *currentHeading;
@property float otherLat, otherLong;
@property NSString *otherUsername;
@property PFUser *otherUser;
@property PFObject *connection;
@property BOOL haveMyLoc, haveTargetLoc, haveTarget;
@property BOOL visible;
@property int testNum;
@property NSMutableArray *locations;
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

- (void) viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self.navigationController setToolbarHidden:YES animated:NO];
    [self.tabBarController.tabBar setHidden:YES];
}

- (void) getStaticTargetInBackground {
    _me = [PFUser currentUser];
    _locations = _me[@"myLocations"];
    PFObject *target;
    
    for (PFObject *temp in _locations) {
        [temp fetchIfNeeded];
        
        NSString *tempName = temp[@"name"];
        NSString *senderName = (NSString *)_staticSender;
        
        if ([tempName isEqualToString:senderName]) {
            target = temp;
            break;
        }
    }
    _otherLat = [target[@"lat"] floatValue];
    _otherLong = [target[@"long"] floatValue];
    _haveTarget = YES;
    _haveTargetLoc = YES;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    [self locationManagerShouldDisplayHeadingCalibration:_locationManager];
    _DistanceLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:60];
    
    [_compassView setArrowImage:[UIImage imageNamed:@"chevron.jpeg"]];
    
    _haveMyLoc = NO;
    _otherUsername = nil;
    _otherUser = nil;
    _connection = nil;
    
    if (_staticLocation){
        _haveTarget = NO;
        _haveTargetLoc = NO;
        _otherLat = 0.0f;
        _otherLong = 0.0f;
        [self performSelectorInBackground:@selector(getStaticTargetInBackground) withObject:nil];
    } else {
        _haveTarget = NO;
        _haveTargetLoc = NO;
        _otherLat = 0.0f;
        _otherLong = 0.0f;
        [self getTargetInBackground]; //Find the target user
    }
    
    _visible = YES;
    
    _radChange = 0.0f;
    
    //Open a new thread to update the target angle regularly
    [self performSelectorInBackground:@selector(regularInfoUpdate) withObject:nil];
    
	_locationManager=[[CLLocationManager alloc] init];
	_locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	_locationManager.headingFilter = 1;
    [_locationManager setDelegate:self];
    [_locationManager startUpdatingHeading];
    [_locationManager startUpdatingLocation];
    
    _me = [PFUser currentUser];
}

- (void)getTargetInBackground
{
    PFQuery *query= [PFUser query];
    [query whereKey:@"username" equalTo:_targetUserName];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error){
        if (!error){
            _otherUsername = [(PFUser *)object username];
            _otherUser = (PFUser *)object;
            _haveTarget = YES;
        } else {
            //Let the user know that they cannot connect
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unknown User"
                                                            message:@"The user is either private or does not exist"
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }];
}

- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager
{
    if (self.currentHeading == nil){
        return YES;
    } else {
        return NO;
    }
}

- (void)regularInfoUpdate
{
    while (_visible)
    {
        [self updateLocations];
        [self updateDistance];
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
    _me[@"connections"] = [[NSNull alloc] init];
    [_connection deleteInBackground]; //Removes object from parse
    _connection = nil;
    [_me saveInBackground];
    NSLog(@"should be zero");
    
    //Stop the view from trying to update when we turn the device
    [_locationManager stopUpdatingHeading];
    [_locationManager stopUpdatingLocation];
    
    //Purge whitelist
}

- (IBAction)ArrowBackButtonPushed:(id)sender {
    NSLog(@"Pushed");
    [self popBackAViewController];
//    [self performSegueWithIdentifier:@"ArrowToPerson" sender:nil];
}

- (void)popBackAViewController
{
    [self.navigationController popViewControllerAnimated:YES];
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

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *newLoc = [locations lastObject];
    _myLat = newLoc.coordinate.latitude;
    _myLong = newLoc.coordinate.longitude;
    
    _haveMyLoc = YES;
}

- (void)updateDistance
{
    if (_haveTargetLoc && _haveMyLoc){
        float lat1 = [self degreesToRadians:_myLat];
        float lat2 = [self degreesToRadians:_otherLat];
        float long1 = [self degreesToRadians:_myLong];
        float long2 = [self degreesToRadians:_otherLong];
    
    
        float dLat = lat1 - lat2;
        float dLong = long1 - long2;
    
        float a = sinf(dLat/2.0f) * sinf(dLat/2.0f) + sinf(dLong/2.0f) * sinf(dLong/2.0f) * cosf(lat1) * cosf(lat2);
        float c = 2.0f * atan2((sqrtf(a)), (sqrtf(1.0f-a)));
        float d = EARTH_RADIUS * c;
        
        NSNumber *distance = [[NSNumber alloc] initWithFloat:d];
        
        [self performSelectorOnMainThread:@selector(updateLabelWithDistance:) withObject:distance waitUntilDone:YES];
    }
}

- (void)updateLabelWithDistance:(NSNumber *)distance
{
    _DistanceLabel.text = [NSString stringWithFormat:@"%.3f mi", [distance floatValue]];
    NSLog([NSString stringWithFormat:@"%f", [distance floatValue]]);
}

- (float)degreesToRadians: (float)degrees
{
    return degrees * M_PI / 180.0f;
}

- (float)findNewRadChangeForTarget
{
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
    if (!_staticLocation){
        PFQuery *connectionQuery = [PFQuery queryWithClassName:@"Connection"];
        [connectionQuery whereKey:@"user" equalTo:_targetUserName];
        [connectionQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            if (object){
                float otherLat = [[object objectForKey:@"lat"] floatValue];
                float otherLong = [[object objectForKey:@"long"] floatValue];
                
                [self setOtherLat:otherLat];
                [self setOtherLong:otherLong];
                
                _haveTargetLoc = YES;
                [_compassView setNeedsDisplay];
            }
            if (error) {
                if (_haveTargetLoc){
                    [self popBackAViewController];
                }
            }
        }];
    }
    
    if (!_staticLocation && _haveTarget){
        if (!_connection){
            _connection = [[PFObject alloc] initWithClassName:@"Connection"];
        }
        
        _connection[@"user"] = [[PFUser currentUser] username];
        _connection[@"lat"] = [NSString stringWithFormat:@"%f", _myLat];
        _connection[@"long"] = [NSString stringWithFormat:@"%f", _myLong];
        
        PFACL *acl = [PFACL ACLWithUser:[PFUser currentUser]];
        [acl setReadAccess:YES forUser:_otherUser];
        [_connection setACL:acl];
        
        _me[@"connections"] = _connection;
        
        if (_visible){
            [_me saveInBackground];
        }
    }
    
    NSLog(@"my location set");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
