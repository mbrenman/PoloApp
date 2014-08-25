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
#import "Parse/Parse.h"
#import "PoloLocationManager.h"
#import "PoloAppDelegate.h"
#import "PoloFriendManager.h"

@interface FriendTableViewController ()

@property (strong, nonatomic) IBOutlet UIButton *friendRequestsLabel;
@property (nonatomic) NSMutableArray *friends;
@property (nonatomic) NSMutableArray *friendRequests;
@property (strong, nonatomic) PoloFriendManager *friendManager;

@end

@implementation FriendTableViewController

- (PoloFriendManager *)friendManager{
    if (!_friendManager) {
        _friendManager = [PoloAppDelegate delegate].friendManager;
    }
    return _friendManager;
}

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

- (void)tableView:(UITableView *)tv commitEditingStyle:  (UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        NSString *removedFriendName = [self.friends objectAtIndex:indexPath.row];
        
        [self.friendManager deleteFriendWithUsername:removedFriendName
                               WithCompletionHandler:^(BOOL success) {
                                   if (success) {
                                       [self.friends removeObject:removedFriendName];

                                       
                                       [self.tableView deleteRowsAtIndexPaths:@[indexPath]
                                                             withRowAnimation:UITableViewRowAnimationFade];
                                    }
                               }];
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
#warning move this to app delegate
    [PFInstallation.currentInstallation setObject:PFUser.currentUser forKey:@"user"];
    [PFInstallation.currentInstallation saveInBackground];
    
    PFUser *me = [PFUser currentUser];
    self.friends = me[@"friends"];
}

- (void)viewWillAppear:(BOOL)animated
{
    PFUser *me = [PFUser currentUser];
    
    self.friends = [NSMutableArray arrayWithArray:[me[@"friends"] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
    
    [self.friendManager getFriendRequestsWithCompletionHander:^(BOOL success, NSMutableArray *friendRequests) {
        self.friendRequests = friendRequests;
        [self updateButtonText];
    }];
    
    [self.friendManager handleIncomingAcceptedFriendRequests:^(BOOL success) {
        self.friends = me[@"friends"];
        [self.tableView reloadData];
    }];
    
    [self.friendManager handleDeletionRequestsWithCompletionHander:^(BOOL success) {
        self.friends = me[@"friends"];
        [self.tableView reloadData];
    }];
    
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

    NSInteger row = [indexPath row];
    
    cell.friendLabel.text = [self.friends objectAtIndex:row];
    
    return cell;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"PersonToArrow"]){
        
#warning talk to Matt about what the following two lines do
        PFQuery *userQuery = [PFUser query];
        [userQuery whereKey:@"username" equalTo:sender];
        
        PFQuery *devicesFilter = [PFInstallation query];
        [devicesFilter whereKey:@"user" matchesQuery:userQuery];
        
        NSString *pushMessage = [NSString stringWithFormat:@"%@ would like to connect with you", [[PFUser currentUser] username]];
        
        [PFPush sendPushMessageToQueryInBackground:devicesFilter
                                       withMessage:pushMessage];

        [segue.destinationViewController setTargetUserName:sender];
        [segue.destinationViewController setStaticLocation:NO];
    }
    if ([segue.identifier isEqualToString:@"friendTableToFriendTableRequests"]){
        [segue.destinationViewController setRequesters:self.friendRequests];
    }
}

#pragma mark - Friend Requests

- (void) findFriendRequesters{

}

-(NSMutableArray *)friendRequests{
    if (!_friendRequests) {
        _friendRequests = [[NSMutableArray alloc] init];
    }
    return _friendRequests;
}



@end
