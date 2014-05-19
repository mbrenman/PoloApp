//
//  AddLocationViewController.m
//  PoloApp
//
//  Created by Susanne Heincke on 3/10/14.
//  Copyright (c) 2014 mbrenman. All rights reserved.
//

#import "AddLocationViewController.h"
#import <Parse/Parse.h>

@interface AddLocationViewController ()

@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic, strong) NSMutableArray *locations;
@property (nonatomic, strong) NSMutableArray *locationNames;
@property (strong, nonatomic) IBOutlet UITextField *locationField;

@end

@implementation AddLocationViewController

- (IBAction)addLocationClick:(id)sender {
    //get name and coordinates of new location
    NSString *newLocationName = [_locationField text];
    NSString *locLat = [NSString stringWithFormat:@"%f",_locationManager.location.coordinate.latitude];
    NSString *locLong =[NSString stringWithFormat:@"%f",_locationManager.location.coordinate.longitude];
    
    //Get current user
    PFUser *me = [PFUser currentUser];
    
    //Check if location name already exists
    NSArray *names = me[@"myLocationNames"];
    BOOL nameAlreadyUsed = false;
    for (NSString *name in names) {
        if ([name isEqualToString:newLocationName]){
            nameAlreadyUsed = true;
        }
    }
    
    //Only add name if the name hasn't been used already (for this user)
    if (nameAlreadyUsed){
        //Alert the user to choose a different name
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Name Already Used"
                              message:@"Please use a different name"
                              delegate:self
                              cancelButtonTitle:@"Dismiss"
                              otherButtonTitles:nil];
        [alert show];
    } else {
        //Create new location
        PFObject *newLocation = [PFObject objectWithClassName:@"myLocationsObject"];
        newLocation[@"name"] = newLocationName;
        newLocation[@"lat"] = locLat;
        newLocation[@"long"] = locLong;
    
        //Add the new location
        [me addObject:newLocation forKey:@"myLocations"];

        //Add the new location name
        [me addObject:newLocationName forKey:@"myLocationNames"];
        
        //Save user and change screens
        [me saveInBackground];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    _locationManager=[[CLLocationManager alloc] init];
	_locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	_locationManager.headingFilter = 1;
    [_locationManager setDelegate:(id)self]; //silence warning
    
    [_locationManager startUpdatingHeading];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [_locationManager stopUpdatingHeading];
}

@end