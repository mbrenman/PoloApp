//
//  FriendTableViewController.h
//  PoloApp
//
//  Created by Matt Brenman on 2/1/14.
//  Copyright (c) 2014 mbrenman. All rights reserved.
//

@import UIKit;
@class FriendCell;
#import <Parse/Parse.h>

@interface FriendTableViewController : UITableViewController
@property (weak, nonatomic) IBOutlet UIBarButtonItem *logoutButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addFriendButton;

@end
