//
//  FriendTableViewController.h
//  PoloApp
//
//  Created by Matt Brenman on 2/1/14.
//  Copyright (c) 2014 mbrenman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "FriendCell.h"

@interface FriendTableViewController : UITableViewController
@property (weak, nonatomic) IBOutlet UIBarButtonItem *logoutButton;

@end
