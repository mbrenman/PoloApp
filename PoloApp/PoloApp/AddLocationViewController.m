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
@property (strong, nonatomic) IBOutlet UITextField *locationField;


@end

@implementation AddLocationViewController

- (IBAction)addLocationClick:(id)sender {
    //get name and coordinates of new location
    NSString *newLocationName = [_locationField text];
    NSString *locLat = [NSString stringWithFormat:@"%f",_locationManager.location.coordinate.latitude];
    NSString *locLong =[NSString stringWithFormat:@"%f",_locationManager.location.coordinate.longitude];
    
    PFObject *newLocation = [PFObject objectWithClassName:@"myLocationsObject"];
    newLocation[@"name"] = newLocationName;
    newLocation[@"lat"] = locLat;
    newLocation[@"long"] = locLong;
    
    PFUser *me = [PFUser currentUser];
    _locations = me[@"myLocations"];
    if (_locations == nil) {
        me[@"myLocations"] = [[NSMutableArray alloc] initWithObjects:newLocation, nil];
    } else {
        [_locations addObject:newLocation];
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
    self.locationManager.delegate=self;
    
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
