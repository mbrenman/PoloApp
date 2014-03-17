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

@interface LocationTableViewController ()
@property (nonatomic) NSMutableArray *locations;
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

/*- (IBAction)beginEditingTable:(id)sender {
    if (self.editing==NO) {
        [self setEditing:YES animated:YES];
    } else {
        [self setEditing:NO animated:YES];
    }
}
 - (void)tableView:(UITableView *)tv commitEditingStyle:    (UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // If row is deleted, remove it from the list.
 if (editingStyle == UITableViewCellEditingStyleDelete)
 {
 for (NSString *i in _friends){
 NSLog(@"%@", i);
 }
 //remove from local NSArray
 [self.friends removeObjectAtIndex:indexPath.row];
 // remove from database
 PFUser *me = [PFUser currentUser];
 me[@"friends"] = _friends;
 [me saveInBackground];
 //remove from local table
 [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 [self.tableView reloadData];
 }
 }
 
*/

- (IBAction)logOutUser:(id)sender {
    [PFUser logOut];
    [self performSegueWithIdentifier:@"LocationLogoutSegue" sender:nil];
}

- (IBAction)goToLocationScreen:(id)sender {
    [self performSegueWithIdentifier:@"addLocationSegue" sender:nil];
}

- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    PFObject *location = [_locations objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"LocationToArrow" sender:location];
//    [self performSegueWithIdentifier:@"locationToArrowSegue" sender:location];
}

- (IBAction)editTable:(id)sender {
    [self setEditing:YES animated:YES];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"FriendCell";
    FriendCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    
    // Configure the cell...
    int row = [indexPath row];
    PFObject *location = [_locations objectAtIndex:row];
    [location fetchIfNeeded];
    cell.friendLabel.text = location[@"name"];
    
    return cell;
}






- (void)viewDidLoad
{
    [super viewDidLoad];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
//    NSLog(_locations[1][@"name"]);
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    PFUser *me = [PFUser currentUser];
    _locations = me[@"myLocations"];
//    [self.view setNeedsDisplay];
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
    return _locations.count;
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
    PFObject *loc = sender;
    if ([segue.identifier isEqualToString:@"LocationToArrow"]){
        [segue.destinationViewController setStaticLat:[(loc[@"lat"]) floatValue]];
        [segue.destinationViewController setStaticLong:[(loc[@"long"]) floatValue]];
        [segue.destinationViewController setStaticLocation:YES];
    }
}



@end
