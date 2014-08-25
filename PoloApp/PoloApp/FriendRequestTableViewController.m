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
#import "PoloFriendManager.h"
#import "PoloAppDelegate.h"

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
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Confirm Friend",@"Reject Friend",nil];
    
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
    PoloFriendManager *friendManager = [PoloAppDelegate delegate].friendManager;
    NSString *requester = [self.requesters objectAtIndex:[actionSheet tag]];

    if (buttonIndex == 0){
        //Confirm Friend Clicked

        [friendManager handleFriendRequestFrom:requester
                                  WithResponse:YES
                         WithCompletionHandler:^(BOOL success) {
                             if (success) {
                                 [self.requesters removeObjectAtIndex:actionSheet.tag];
                                 [self.tableView reloadData];
                                 if (self.requesters.count < 1) {
                                     [self.navigationController popViewControllerAnimated:YES];
                                 }
                             }
                         }];
        
    } else if (buttonIndex == 1){
        //Reject Friend Clicked
        
        [friendManager handleFriendRequestFrom:requester
                                  WithResponse:NO
                         WithCompletionHandler:^(BOOL success) {
                             if (success) {
                                 [self.requesters removeObjectAtIndex:actionSheet.tag];
                                 [self.tableView reloadData];
                                 if (self.requesters.count < 1) {
                                     [self.navigationController popViewControllerAnimated:YES];
                                 }
                             }
                         }];
    }
    //Otherwise cancel was clicked, so we do nothing

    //Deselect the friend when a choice is made
    [[self tableView] deselectRowAtIndexPath:(NSIndexPath *)[[self tableView] indexPathForSelectedRow] animated:YES];
    if (self.requesters.count == 0) {
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
    
    return self.requesters.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"FriendCell";
    FriendCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSInteger row = [indexPath row];
    
    cell.friendLabel.text = [self.requesters objectAtIndex:row];

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
