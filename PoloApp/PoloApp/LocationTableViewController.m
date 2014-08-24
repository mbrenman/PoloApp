//
//  LocationTableViewController.m
//  PoloApp
//
//  Created by Susanne Heincke on 3/10/14.
//  Copyright (c) 2014 mbrenman. All rights reserved.
//

#import "LocationTableViewController.h"
#import "Parse/Parse.h"
#import "FriendCell.h"
#import "ArrowViewController.h"
#import "iAd/iAd.h"

@interface LocationTableViewController ()
@property (nonatomic) NSMutableArray *locations;
@property (nonatomic) NSMutableArray *locationNames;

@end

@implementation LocationTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)logOutUser:(id)sender {
    //Remove user and device association
    [PFInstallation.currentInstallation removeObjectForKey:@"user"];
    [PFInstallation.currentInstallation saveEventually];
    
    [PFUser logOut];
    [self performSegueWithIdentifier:@"LocationLogoutSegue" sender:nil];
}

- (IBAction)goToLocationScreen:(id)sender {
    [self performSegueWithIdentifier:@"addLocationSegue" sender:nil];
}

- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    PFObject *location = [self.locationNames objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"LocationToArrow" sender:location];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"FriendCell";
    FriendCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    NSInteger row = [indexPath row];
    NSString *location = [self.locationNames objectAtIndex:row];
    cell.friendLabel.text = location;
    return cell;
}

- (void)tableView:(UITableView *)tv commitEditingStyle:    (UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // If row is deleted, remove it from the list.
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {        
        BOOL found = false;
        NSString *deleteName = [self.locationNames objectAtIndex:indexPath.row];
        for (PFObject *temp in self.locations) {
            if (!found){
                [temp fetch];
                NSString *tempName = temp[@"name"];
                
                
                if ([tempName isEqualToString:deleteName]) {
                    //Delete the actual object
                    [temp deleteInBackground];
                    [self.locations removeObject:temp];
                    found = true;
                    NSLog(@"SHOULD BE DELETED");
                }
            }
            if (found) {
                break;
            }
        }
        
        //remove from local NSArray
        if (found){
            [self.locationNames removeObjectAtIndex:indexPath.row];
        }
        
        //remove from database
         PFUser *me = [PFUser currentUser];
         me[@"myLocations"] = self.locations;
         me[@"myLocationNames"] = self.locationNames;
         [me saveInBackground];
        
        //remove from local table
        if (found){
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView reloadData];
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.backgroundColor = [UIColor blackColor];
    
    UIBarButtonItem *myButton2 = [[UIBarButtonItem alloc]init];
    myButton2.action = @selector(goToLocationScreen:);
    myButton2.title = @"Add Loc";
    [myButton2 setTitleTextAttributes:
     @{NSForegroundColorAttributeName  : [UIColor lightTextColor]}
                            forState:normal];
    myButton2.target = self;
    self.navigationItem.rightBarButtonItem = myButton2;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.canDisplayBannerAds = YES;
    PFUser *me = [PFUser currentUser];
    self.locations = me[@"myLocations"];
    
    self.locationNames = me[@"myLocationNames"];
    self.locationNames = [NSMutableArray arrayWithArray:[self.locationNames sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.locationNames.count;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"LocationToArrow"]){
        [segue.destinationViewController setStaticSender:sender];
        [segue.destinationViewController setStaticLocation:YES];
    }
}

@end
