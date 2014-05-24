//
//  AddLocationViewController.m
//  PoloApp
//
//  Created by Susanne Heincke on 3/10/14.
//  Copyright (c) 2014 mbrenman. All rights reserved.
//

#import "AddLocationViewController.h"
#import <Parse/Parse.h>
#import "PoloLocationManager.h"
#import "PoloAppDelegate.h"

@interface AddLocationViewController ()

@property (nonatomic) PoloLocationManager *locationManager;
@property (nonatomic, strong) NSMutableArray *locations;
@property (nonatomic, strong) NSMutableArray *locationNames;
@property (strong, nonatomic) IBOutlet UITextField *locationField;

@end

@implementation AddLocationViewController

- (IBAction)addLocationClick:(id)sender {
    //get name and coordinates of new location
    NSString *newLocationName = [self.locationField text];
    
    NSString *locLat = [NSString stringWithFormat:@"%f", self.locationManager.myLat];
    NSString *locLong =[NSString stringWithFormat:@"%f", self.locationManager.myLong];
    
    PFUser *me = [PFUser currentUser];
    
    self.locationNames = me[@"myLocationNames"];
    BOOL nameAlreadyUsed = false;
    for (NSString *name in self.locationNames) {
        if ([name isEqualToString:newLocationName]){
            nameAlreadyUsed = true;
        }
    }
    
    //Only add name if the name hasn't been used already (for this user)
    if (nameAlreadyUsed){
        //Alert the user to choose a different name
        UIAlertView *alert = [[UIAlertView alloc]                           initWithTitle:@"Name Already Used"
                  message:@"Please use a different name"
                 delegate:self
        cancelButtonTitle:@"Dismiss"
        otherButtonTitles:nil];
        
        //Present alert
        [alert show];
    } else {
        //Create the new location object
        PFObject *newLocation = [PFObject objectWithClassName:@"myLocationsObject"];
        newLocation[@"name"] = newLocationName;
        newLocation[@"lat"] = locLat;
        newLocation[@"long"] = locLong;
        
        //Add object to locations
        self.locations = me[@"myLocations"];
        if (self.locations == nil) {
            me[@"myLocations"] = [[NSMutableArray alloc] initWithObjects:newLocation, nil];
        } else {
            [self.locations addObject:newLocation];
            [me saveInBackground];
        }
    
        //Add location name to location name list
        if (self.locationNames == nil) {
            me[@"myLocationNames"] = [[NSMutableArray alloc] initWithObjects:newLocationName, nil];
        } else {
            [self.locationNames addObject:newLocationName];
            [self.navigationController popViewControllerAnimated:YES];
        }
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
    self.locationManager = [PoloAppDelegate delegate].locationManager;
    [self.locationManager startUpdatingMyLocation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.locationManager stopUpdatingMyLocation];
}

@end