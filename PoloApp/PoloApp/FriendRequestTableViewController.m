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
    
    PFObject *temp = [self.requesters objectAtIndex:indexPath.row];
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Confirm Friend",@"Reject Friend",nil];
    
    actionSheet.accessibilityValue = [temp objectId];
    actionSheet.tag = indexPath.row;

    [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView.backgroundColor = [UIColor blackColor];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0){
        //Confirm Friend Clicked
        // 1. add the friend
        PFQuery *friendRequestQuery = [PFQuery queryWithClassName:@"friendRequest"];
        PFObject *friendRequest = [friendRequestQuery getObjectWithId:actionSheet.accessibilityValue];
        
        NSString *newFriend = friendRequest[@"requester"];
        [self addFriend:newFriend];
        
        // 2. remove them from the local request table
        [self.requesters removeObjectAtIndex:actionSheet.tag];
        [self.tableView reloadData];
        
        // 3. set the bool to accepted
        friendRequest[@"accepted"] = [NSNumber numberWithBool:YES];
        [friendRequest saveInBackground];
        
    } else if (buttonIndex == 1){
        //Reject Friend Clicked
        [self.requesters removeObjectAtIndex:actionSheet.tag];
        [self.tableView reloadData];
        
        PFQuery *friendRequestQuery = [PFQuery queryWithClassName:@"friendRequest"];
        PFObject *friendRequest = [friendRequestQuery getObjectWithId:actionSheet.accessibilityValue];
        [friendRequest saveInBackground];
        [friendRequest deleteInBackground];
    }
    //Otherwise cancel was clicked, so we do nothing

    //Deselect the friend when a choice is made
    [[self tableView] deselectRowAtIndexPath:(NSIndexPath *)[[self tableView] indexPathForSelectedRow] animated:YES];
    if (self.requesters.count == 0) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)addFriend: (NSString *)newFriend{
    PFUser* me = [PFUser currentUser];
    NSMutableArray *friends = me[@"friends"];
    
    if (![friends containsObject:newFriend]){
        NSLog(@"prepreinitializing");
        if (![[me username] isEqualToString:newFriend]){
            if (!friends) {
                friends = [[NSMutableArray alloc] init];
            }
            if (friends.count  == 0) {
                friends = [[NSMutableArray alloc] init];
            }
            [friends addObject:newFriend];
            me[@"friends"] = friends;
            [me saveInBackground];
        } else {
            //display alert
        }
    } else {
        //dislay alert
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
    return self.requesters.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"FriendCell";
    FriendCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    NSInteger row = [indexPath row];
    
    PFObject *temp = [self.requesters objectAtIndex:row];
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
