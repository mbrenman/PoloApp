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
#import "PoloAppDelegate.h"
#import "PoloLocationManager.h"
#import "TTAlertView.h"

const unsigned int SECONDS_BETWEEN_TARGET_UPDATES = 1;
const float EARTH_RADIUS = 3963.1676;
const float FEET_PER_MILE = 5280;
const float KM_PER_MILE = 1.60934;
const float METERS_PER_MILE = 1609.34;

@interface ArrowViewController() <PoloLocationManagerDelegate>
@property (nonatomic, strong) PoloLocationManager *locationManager;
@property (strong, nonatomic) PFUser *me;
@property float otherLat, otherLong;
@property PFUser *otherUser;
@property PFObject *connection;
@property BOOL haveMyLoc, haveTargetLoc, haveTarget;
@property BOOL visible;
@property BOOL isMileOrKM;
@property BOOL useMetricUnits;
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cleanArrowData) name:@"terminatingApp" object:nil];
    
    self.DistanceLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:50];
    self.TargetLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:30];
    
    self.haveMyLoc = NO;
    self.otherUser = nil;
    self.connection = nil;
    
    if (self.staticLocation){
        self.TargetLabel.text = self.staticSender;
        self.haveTarget = NO;
        self.haveTargetLoc = NO;
        self.otherLat = 0.0f;
        self.otherLong = 0.0f;
        [self performSelectorInBackground:@selector(getStaticTargetInBackground) withObject:nil];
    } else {
        self.TargetLabel.text = self.targetUserName;
        self.haveTarget = NO;
        self.haveTargetLoc = NO;
        self.otherLat = 0.0f;
        self.otherLong = 0.0f;
        [self getTargetInBackground];
    }
    
    self.visible = YES;
    
    [self performSelectorInBackground:@selector(regularTargetInfoUpdate) withObject:nil];
    
	self.locationManager = [[PoloAppDelegate delegate] locationManager];
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingMyLocation];
    if (self.locationManager.myLat != 0) {
        self.haveMyLoc = YES;
    }
    [self headingWasUpdated];
    self.me = [PFUser currentUser];
}

- (IBAction)toggleDistanceGranularity:(id)sender {
    if (self.isMileOrKM) {
        self.isMileOrKM = false;
    } else {
        self.isMileOrKM = true;
    }
    [self updateDistance];
}

- (void) viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self.navigationController setToolbarHidden:YES animated:NO];
    [self.tabBarController.tabBar setHidden:YES];
    [self setUnitsBasedOnSettings];
}

- (void) setUnitsBasedOnSettings {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.useMetricUnits = [defaults boolForKey:@"units_preference"];
}

- (void) getStaticTargetInBackground {
    self.me = [PFUser currentUser];
    NSMutableArray *locations = self.me[@"myLocations"];
    PFObject *target;
    
    NSString *senderName = (NSString *)self.staticSender;
    for (PFObject *temp in locations) {
        [temp fetchIfNeeded];
        
        NSString *tempName = temp[@"name"];
        
        if ([tempName isEqualToString:senderName]) {
            target = temp;
            break;
        }
    }
    self.otherLat = [target[@"lat"] floatValue];
    self.otherLong = [target[@"long"] floatValue];
    self.haveTarget = YES;
    self.haveTargetLoc = YES;
}


- (void)getTargetInBackground
{
    PFQuery *query= [PFUser query];
    [query whereKey:@"username" equalTo:self.targetUserName];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error){
        if (!error){
            self.otherUser = (PFUser *)object;
            self.haveTarget = YES;
            
        } else {
            //Let the user know that they cannot connect
            if (error.code == 101) {
                //other user does not exist
                [self removeFriend:self.targetUserName];
            }
             TTAlertView *alert = [[TTAlertView alloc] initWithTitle:@"Unknown User"
                                                            message:@"The user is either private or does not exist"
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}

- (void)removeFriend: (NSString *)friend
{
    PFUser *currentUser = [PFUser currentUser];
    NSMutableArray *friends = currentUser[@"friends"];
    [friends removeObject:friend];
    currentUser[@"friends"] = friends;
    [currentUser saveInBackground];
}

- (void)regularTargetInfoUpdate
{
    while (self.visible)
    {
        if (!self.staticLocation) {
            [self pullTargetLocation];
            [self pushMyLocation];
        }

        [self updateDistance];
        
        sleep(SECONDS_BETWEEN_TARGET_UPDATES);
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self cleanArrowData];
}

- (void)cleanArrowData {
    self.visible = FALSE;
    
    //Zero out location data when we get off of the arrow
    self.me[@"connections"] = [[NSNull alloc] init];
    [self.connection deleteInBackground];
    self.connection = nil;
    [self.me saveInBackground];
    
    [self.locationManager stopUpdatingMyLocation];
}

- (IBAction)ArrowBackButtonPushed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)headingWasUpdated{
    if (self.haveMyLoc && self.haveTargetLoc){
        float reversedTrueHeading = - [self degreesToRadians: self.locationManager.myHeading.trueHeading];
        
        float dLat = self.otherLat - self.locationManager.myLat;
        float dLong = self.otherLong - self.locationManager.myLong;

        float offsetFromNorth = atan2(dLat, dLong) - M_PI_2;

        float arrowRotation =  reversedTrueHeading - offsetFromNorth;

        [self.compassView setNewRad:arrowRotation];
        [self.compassView setNeedsDisplay];
    }
}

- (void)updateDistance
{
    if (self.haveTargetLoc && self.haveMyLoc){
        
        float myLat = [self degreesToRadians:self.locationManager.myLat];
        float otherLat = [self degreesToRadians:self.otherLat];
        float myLong = [self degreesToRadians:self.locationManager.myLong];
        float otherLong = [self degreesToRadians:self.otherLong];
    
        float dLat = myLat - otherLat;
        float dLong = myLong - otherLong;
    
        float a = sinf(dLat/2.0f) * sinf(dLat/2.0f) + sinf(dLong/2.0f) * sinf(dLong/2.0f) * cosf(myLat) * cosf(otherLat);
        
        float c = 2.0f * atan2((sqrtf(a)), (sqrtf(1.0f-a)));
        
        float d = EARTH_RADIUS * c;
        
        NSNumber *distance = [[NSNumber alloc] initWithFloat:d];
        
        [self performSelectorOnMainThread:@selector(updateLabelWithDistance:) withObject:distance waitUntilDone:YES];
    }
}

- (void)updateLabelWithDistance:(NSNumber *)distanceInMiles
{
    if (self.useMetricUnits){
        if (self.isMileOrKM) {
            self.DistanceLabel.text = [NSString stringWithFormat:@"%.3f km", [distanceInMiles floatValue] * KM_PER_MILE];
        } else {
            self.DistanceLabel.text = [NSString stringWithFormat:@"%.0f m", [distanceInMiles floatValue] * METERS_PER_MILE];
        }
    } else {
        if (self.isMileOrKM) {
            self.DistanceLabel.text = [NSString stringWithFormat:@"%.3f mi", [distanceInMiles floatValue]];
        } else {
            self.DistanceLabel.text = [NSString stringWithFormat:@"%.0f ft", [distanceInMiles floatValue] * FEET_PER_MILE];
        }
    }
}

- (float)degreesToRadians: (float)degrees
{
    return degrees * M_PI / 180.0f;
}

- (void)pullTargetLocation
{
    PFQuery *connectionQuery = [PFQuery queryWithClassName:@"Connection"];
    [connectionQuery whereKey:@"user" equalTo:self.targetUserName];
    [connectionQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        
        if (object){
            float otherLat = [[object objectForKey:@"lat"] floatValue];
            float otherLong = [[object objectForKey:@"long"] floatValue];
            
            [self setOtherLat:otherLat];
            [self setOtherLong:otherLong];
            
            self.haveTargetLoc = YES;
            [self.compassView setNeedsDisplay];
        }
        //this handles the case where the other user disconnects
        if (error) {
            if (self.haveTargetLoc){
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
    }];
}

- (void)pushMyLocation{
    if (self.haveTarget){
        
        if (!self.connection){
            self.connection = [[PFObject alloc] initWithClassName:@"Connection"];
        }
        
        self.connection[@"user"] = [[PFUser currentUser] username];
        self.connection[@"lat"] = [NSString stringWithFormat:@"%f", self.locationManager.myLat];
        self.connection[@"long"] = [NSString stringWithFormat:@"%f", self.locationManager.myLong];
        
        PFACL *acl = [PFACL ACLWithUser:[PFUser currentUser]];
        [acl setReadAccess:YES forUser:self.otherUser];
        [self.connection setACL:acl];
        
        self.me[@"connections"] = self.connection;
        
        if (self.visible){
            [self.me saveInBackground];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
