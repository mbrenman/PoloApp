//
//  FriendRequestTableViewController.m
//  PoloApp
//
//  Created by Susanne Heincke on 4/2/14.
//  Copyright (c) 2014 mbrenman. All rights reserved.
//

#import "FriendRequestTableViewController.h"
#import "Parse/Parse.h"
#import "FriendCell.h"

@interface FriendRequestTableViewController ()
@property (nonatomic) UIActionSheet *actionSheet;

@end

@implementation FriendRequestTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    PFObject *temp = [_requesters objectAtIndex:indexPath.row];
    _actionSheet.accessibilityValue = [temp objectId];   
    _actionSheet.tag = indexPath.row;

    [_actionSheet showInView:[UIApplication sharedApplication].keyWindow];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    for (PFObject* each in _requesters){
        NSLog(@"requester: %@", each[@"requester"]);
    }
    
    _actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                delegate:self
                cancelButtonTitle:@"Cancel"
                destructiveButtonTitle:nil
                otherButtonTitles:@"Confirm Friend",@"Reject Friend",nil];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0){
        //Confirm Friend Clicked
        // 1. add the friend

        PFQuery *friendRequestQuery = [PFQuery queryWithClassName:@"friendRequest"];
        PFObject *friendRequest = [friendRequestQuery getObjectWithId:_actionSheet.accessibilityValue];
        
        NSString *newFriend = friendRequest[@"requester"];

        PFUser* me = [PFUser currentUser];
        NSMutableArray *friends = me[@"friends"];
        if (![friends containsObject:newFriend]){
            if (![[me username] isEqualToString:newFriend]){
                if ([friends.count  == 0]) {
                    friends = [[NSMutableArray alloc] init];
                }
                [friends addObject:newFriend];
                [me saveInBackground];
            } else {
                //display alert
            }
        } else {
            //dislay alert
        }
        // 2. remove them from the local table
        [_requesters removeObjectAtIndex:_actionSheet.tag];
        [self.tableView reloadData];
        // 3. set the bool to accepted
        friendRequest[@"accepted"] = [NSNumber numberWithBool:YES];
        [friendRequest saveInBackground];
        
    } else if (buttonIndex == 1){
        //Reject Friend Clicked
        //simply remove the object
        [_requesters removeObjectAtIndex:_actionSheet.tag];
        [self.tableView reloadData];
        
        PFQuery *friendRequestQuery = [PFQuery queryWithClassName:@"friendRequest"];
        PFObject *friendRequest = [friendRequestQuery getObjectWithId:_actionSheet.accessibilityValue];
        [friendRequest saveInBackground];
        [friendRequest deleteInBackground];
    }
    //Otherwise cancel was clicked, so we do nothing

    //Deselect the friend when a choice is made
    [[self tableView] deselectRowAtIndexPath:(NSIndexPath *)[[self tableView] indexPathForSelectedRow] animated:YES];
    if (_requesters.count == 0) {
        [self.navigationController popViewControllerAnimated:YES];
    }
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
    return _requesters.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"FriendCell";
    FriendCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    int row = [indexPath row];
    
    PFObject *temp = [_requesters objectAtIndex:row];
    cell.friendLabel.text = temp[@"requester"];

    return cell;
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
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
