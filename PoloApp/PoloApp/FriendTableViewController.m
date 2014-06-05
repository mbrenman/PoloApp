//
//  FriendTableViewController.m
//  PoloApp
//
//  Created by Matt Brenman on 2/1/14.
//  Copyright (c) 2014 mbrenman. All rights reserved.
//

#import "FriendTableViewController.h"
#import "FriendCell.h"
#import "ArrowViewController.h"
#import "FriendRequestTableViewController.h"
#import "iAd/iAd.h"
#import "PoloLocationManager.h"
#import "PoloAppDelegate.h"

@interface FriendTableViewController ()
@property (strong, nonatomic) IBOutlet UIButton *numOfFriendRequestsLabel;
@property (nonatomic) NSMutableArray *friends;
@property (nonatomic) NSMutableArray *friendRequests;
@property (nonatomic) NSMutableArray *acceptedFriendRequests;
@end

@implementation FriendTableViewController

- (IBAction)friendRequestButtonPush:(id)sender {
    if([_friendRequests count] != 0) {
        [self performSegueWithIdentifier:@"friendTableToFriendTableRequests" sender:nil];
    } else {
        //TODO: else display alert WHY DID I WRITE THIS?
    }
}

- (void) updateButtonText{
    int numOfFriendReqs = (int)[_friendRequests count];
    if (numOfFriendReqs == 0) {
        [_numOfFriendRequestsLabel setTitle:@"" forState:UIControlStateNormal];
    } else if (numOfFriendReqs == 1){
        [_numOfFriendRequestsLabel setTitle:@"1 Friend Request" forState:UIControlStateNormal];
    } else {
        NSString *stringNumFriendReqs = [[NSNumber numberWithInt:numOfFriendReqs] stringValue];
        NSMutableString *title = [[NSMutableString alloc] initWithString:[stringNumFriendReqs stringByAppendingString:@" Friend Requests"]];
        [_numOfFriendRequestsLabel setTitle:title forState:UIControlStateNormal];
    }
    [_numOfFriendRequestsLabel setNeedsDisplay];
    
   //TODO: find a way to make this appear immediately
}

- (void) findFriendRequesters{
    PFUser *me = [PFUser currentUser];
    PFQuery* requesterQuery = [PFQuery queryWithClassName:@"friendRequest"];
    [requesterQuery whereKey:@"accepted" equalTo:[NSNumber numberWithBool:NO]];
    [requesterQuery whereKey:@"target" equalTo:me.username];
    [requesterQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                _friendRequests = (NSMutableArray*)objects;
                [self updateButtonText];
            } else {
                //handle error
            }
        }
     ];
}

- (void) handleAcceptedFriendRequests{
    PFUser *me = [PFUser currentUser];
    PFQuery* requesterQuery = [PFQuery queryWithClassName:@"friendRequest"];
    
    [requesterQuery whereKey:@"accepted" equalTo:[NSNumber numberWithBool:YES]];
    [requesterQuery whereKey:@"requester" equalTo:me.username];
    
    [requesterQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            _acceptedFriendRequests = (NSMutableArray*)objects;
        } else {
            //handle error
        }
    }];
    //loop through accepted friend requests and add them all then delete all the objects
    for (PFObject* request in _acceptedFriendRequests) {
        _friends = me[@"friends"];
        if (_friends == nil) {
            me[@"friends"] = [[NSMutableArray alloc] initWithObjects:request[@"target"], nil];
        } else if (![_friends containsObject:request[@"target"]]) {
            [me[@"friends"] addObject:request[@"target"]];
        }
        [me saveInBackground];
        [request deleteInBackground];
        [self.tableView reloadData];
        //TODO: make this appear immediately (nonvital)
    }
}


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)tableView:(UITableView *)tv commitEditingStyle:    (UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog([_friends objectAtIndex:indexPath.row]);
    
    // If row is deleted, remove it from the list.
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        //remove from local NSArray
        [_friends removeObjectAtIndex:indexPath.row];
        // remove from database
        PFUser *me = [PFUser currentUser];
        me[@"friends"] = _friends;
        [me saveInBackground];
        //remove from local table
         [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView reloadData];
    }
}

- (void)logoutUser
{
    [PFInstallation.currentInstallation removeObjectForKey:@"user"];
    [PFInstallation.currentInstallation saveEventually];
    
    [PFUser logOut];
    //Segue back to the login screen
    [self performSegueWithIdentifier:@"LogOutSegue" sender:nil];
}

- (void)addFriendScreen
{
    NSLog(@"Go to Add Friend Screen");
    [self performSegueWithIdentifier:@"AddFriendSegue" sender:nil];
}

- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath{
    //TODO: Later on3, pull the data from the sender and use that to customize the arrow
    NSString *user = [_friends objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"PersonToArrow" sender:user];
}

- (IBAction)editTable:(id)sender {
    [self setEditing:YES animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.canDisplayBannerAds = YES;
    
    PoloLocationManager *myLocationManager = [PoloAppDelegate delegate].locationManager;
    [myLocationManager startUpdatingMyLocation];
    
    //Set device to be associated with user
    [PFInstallation.currentInstallation setObject:PFUser.currentUser forKey:@"user"];
    [PFInstallation.currentInstallation saveInBackground];
    
    //Set up buttons with their targets
    [_logoutButton setTarget:self];
    [_logoutButton setAction:@selector(logoutUser)];
    
    [_addFriendButton setTarget:self];
    [_addFriendButton setAction:@selector(addFriendScreen)];
    
    PFUser *me = [PFUser currentUser];
    _friends = me[@"friends"];
}

- (void)viewWillAppear:(BOOL)animated
{
    PFUser *me = [PFUser currentUser];
    _friends = [NSMutableArray arrayWithArray:[me[@"friends"] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
    
    [self findFriendRequesters];
    [self handleAcceptedFriendRequests];
    
    [self.tableView reloadData];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.tabBarController.tabBar setHidden:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return _friends.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"FriendCell";
    FriendCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    //  We can use this method if we want to round the corners of the cells
    //    cell.layer.cornerRadius = 10;
    //    cell.clipsToBounds = YES;
    
    // Configure the cell...
    
    int row = [indexPath row];
    
    cell.friendLabel.text = [_friends objectAtIndex:row];
    
    return cell;
}

#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"PersonToArrow"]){
        //Find the user
        PFQuery *userQuery = [PFUser query];
        [userQuery whereKey:@"username" equalTo:sender];
        
        // Find the device
        PFQuery *devicesFilter = [PFInstallation query];
        [devicesFilter whereKey:@"user" matchesQuery:userQuery];
        
        //Create the message
        NSString *pushMessage = [NSString stringWithFormat:@"%@ would like to connect with you", [[PFUser currentUser] username]];
        
        //Send the message
        [PFPush sendPushMessageToQueryInBackground:devicesFilter
                                       withMessage:pushMessage]; //TODO: add username here and payload that auto connects the receiver with the caller.

        //Send information to next view controller
        [segue.destinationViewController setTargetUserName:sender];
        [segue.destinationViewController setStaticLocation:NO];
    }
    if ([segue.identifier isEqualToString:@"friendTableToFriendTableRequests"]){
        [segue.destinationViewController setRequesters:_friendRequests];
    }
}

@end
