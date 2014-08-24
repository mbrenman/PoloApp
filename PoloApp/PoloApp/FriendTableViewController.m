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
@property (strong, nonatomic) IBOutlet UIButton *friendRequestsLabel;
@property (nonatomic) NSMutableArray *friends;
@property (nonatomic) NSMutableArray *friendRequests;
@property (nonatomic) NSMutableArray *toBeDeleted;
@end

@implementation FriendTableViewController

- (IBAction)friendRequestButtonPush:(id)sender {
    if([self.friendRequests count] > 0) {
        [self performSegueWithIdentifier:@"friendTableToFriendTableRequests" sender:nil];
    }
}

- (void) updateButtonText{
    int numOfFriendReqs = (int)[self.friendRequests count];
    
    if (numOfFriendReqs == 0) {
        [self.friendRequestsLabel setTitle:@"" forState:UIControlStateNormal];
        
    } else if (numOfFriendReqs == 1) {
        [self.friendRequestsLabel setTitle:@"1 Friend Request" forState:UIControlStateNormal];
        
    } else {
        NSString *stringNumFriendReqs = [[NSNumber numberWithInt:numOfFriendReqs] stringValue];
        
        NSMutableString *title = [[NSMutableString alloc] initWithString:[stringNumFriendReqs stringByAppendingString:@" Friend Requests"]];
        
        [self.friendRequestsLabel setTitle:title forState:UIControlStateNormal];
    }
    [self.friendRequestsLabel setNeedsDisplay];
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
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        //remove from local array
        NSString *removedFriendName = [self.friends objectAtIndex:indexPath.row];
        PFUser *me = [PFUser currentUser];
        
        PFObject *friendDeletionRequest = [PFObject objectWithClassName:@"friendDeletionRequest"];
        friendDeletionRequest[@"requester"] = [me username];
        friendDeletionRequest[@"target"] = removedFriendName;
        [friendDeletionRequest saveInBackground];
        
        [self.friends removeObjectAtIndex:indexPath.row];
        
        // remove from database
        me[@"friends"] = self.friends;
        [me saveInBackground];
        
        //remove from local table
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView reloadData];
    }
}

- (void)segueToAddFriendScreen
{
    [self performSegueWithIdentifier:@"AddFriendSegue" sender:nil];
}

- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath{
    NSString *user = [self.friends objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"PersonToArrow" sender:user];
}

- (IBAction)editTable:(id)sender {
    [self setEditing:YES animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.canDisplayBannerAds = YES;
    self.tableView.backgroundColor = [UIColor blackColor];

    UIBarButtonItem *myButton2 = [[UIBarButtonItem alloc]init];
    myButton2.action = @selector(segueToAddFriendScreen);
    myButton2.title = @"Add Friend";
    [myButton2 setTitleTextAttributes:
     @{NSForegroundColorAttributeName  : [UIColor lightTextColor]}
                            forState:normal];
    myButton2.target = self;
    self.navigationItem.rightBarButtonItem = myButton2;

    
    PoloLocationManager *myLocationManager = [PoloAppDelegate delegate].locationManager;
    [myLocationManager startUpdatingMyLocation];
    
    //Set device to be associated with user
    [PFInstallation.currentInstallation setObject:PFUser.currentUser forKey:@"user"];
    [PFInstallation.currentInstallation saveInBackground];
    
    //Set up buttons with their targets
    
    [self.addFriendButton setTarget:self];
    [self.addFriendButton setAction:@selector(addFriendScreen)];
    
    PFUser *me = [PFUser currentUser];
    self.friends = me[@"friends"];
}

- (void)viewWillAppear:(BOOL)animated
{
    PFUser *me = [PFUser currentUser];
    self.friends = [NSMutableArray arrayWithArray:[me[@"friends"] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
    
    [self findFriendRequesters];
    [self handleAcceptedFriendRequests];
    [self handleDeletedFriends];
    
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
    return self.friends.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"FriendCell";
    FriendCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    // Configure the cell...    
    NSInteger row = [indexPath row];
    
    cell.friendLabel.text = [self.friends objectAtIndex:row];
    
    return cell;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"PersonToArrow"]){

        PFQuery *userQuery = [PFUser query];
        [userQuery whereKey:@"username" equalTo:sender];
        
        PFQuery *devicesFilter = [PFInstallation query];
        [devicesFilter whereKey:@"user" matchesQuery:userQuery];
        
        NSString *pushMessage = [NSString stringWithFormat:@"%@ would like to connect with you", [[PFUser currentUser] username]];
        
        [PFPush sendPushMessageToQueryInBackground:devicesFilter
                                       withMessage:pushMessage]; //TODO: add username here and payload that auto connects the receiver with the caller.

        [segue.destinationViewController setTargetUserName:sender];
        [segue.destinationViewController setStaticLocation:NO];
    }
    if ([segue.identifier isEqualToString:@"friendTableToFriendTableRequests"]){
        [segue.destinationViewController setRequesters:self.friendRequests];
    }
}

#pragma mark - Friend Requests

- (void) findFriendRequesters{
    PFUser *me = [PFUser currentUser];
    PFQuery* requesterQuery = [PFQuery queryWithClassName:@"friendRequest"];
    [requesterQuery whereKey:@"accepted" equalTo:[NSNumber numberWithBool:NO]];
    [requesterQuery whereKey:@"target" equalTo:me.username];
    
    [requesterQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            self.friendRequests = (NSMutableArray*)objects;
            for (PFObject *friendrequest in self.friendRequests) {
                NSString *requester = friendrequest[@"requester"];
                for (NSString *friend in self.friends) {
                    if ([requester isEqualToString:friend]) {
                        [self.friendRequests removeObject:friendrequest];
                        friendrequest[@"accepted"] = [NSNumber numberWithBool:YES];
                        [friendrequest saveInBackground];
                        [me saveInBackground];
                    }
                }
            }
            [self updateButtonText];
        } else {
            //handle error
        }
    }
     ];
}

-(void) handleDeletedFriends{
    PFUser *me = [PFUser currentUser];
    PFQuery* requesterQuery = [PFQuery queryWithClassName:@"friendDeletionRequest"];
    [requesterQuery whereKey:@"target" equalTo:me.username];
    
    [requesterQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            self.toBeDeleted = (NSMutableArray*)objects;
            //NSLog(@"OBJECTS: %@",objects);
        } else {
            //handle error
        }
    }];
    
    for (PFObject *object in self.toBeDeleted) {
        [self.friends removeObject:object[@"requester"]];
        me[@"friends"] = self.friends;
        [me saveInBackground];
        [object deleteInBackground];
    }
}

- (void) handleAcceptedFriendRequests{
    PFUser *me = [PFUser currentUser];
    PFQuery* requesterQuery = [PFQuery queryWithClassName:@"friendRequest"];
    
    [requesterQuery whereKey:@"accepted" equalTo:[NSNumber numberWithBool:YES]];
    [requesterQuery whereKey:@"requester" equalTo:me.username];
    
    [requesterQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            
            NSMutableArray *acceptedFriendRequests = (NSMutableArray*)objects;
            
            //loop through accepted friend requests and add them all then delete all the objects

            for (PFObject* request in acceptedFriendRequests) {
                self.friends = me[@"friends"];
                if (self.friends == nil) {
                    me[@"friends"] = [[NSMutableArray alloc] initWithObjects:request[@"target"], nil];
                } else if (![self.friends containsObject:request[@"target"]]) {
                    [me[@"friends"] addObject:request[@"target"]];
                } else {
                    [request deleteInBackground];
                }
                [me saveInBackground];
                [request deleteInBackground];
                [self.tableView reloadData];
                
            }
        } else {
            //handle error
        }
    }];

}


@end
