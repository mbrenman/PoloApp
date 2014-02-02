//
//  AddFriendViewController.m
//  PoloApp
//
//  Created by Matt Brenman on 2/2/14.
//  Copyright (c) 2014 mbrenman. All rights reserved.
//

#import "AddFriendViewController.h"
#import <Parse/Parse.h>

@interface AddFriendViewController ()
@property (nonatomic) NSMutableArray *friends;
@end

@implementation AddFriendViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (IBAction)AddFriendClick:(id)sender {
    NSLog(@"So friends. Much wow");
}
- (IBAction)AddButtonClick:(id)sender {
    PFUser *me = [PFUser currentUser];
    _friends = me[@"friends"];

    NSString *newFriend = [_friendNameField text];
    
    //TODO: Check if friend exists as a user in the app
    
    //Only add new friend if user does not already have the friend
    if (![_friends containsObject:newFriend]){
        [_friends addObject:newFriend];
        NSLog(@"New Frand");
        [me saveInBackground];
        [self performSegueWithIdentifier:@"FriendAdded" sender:nil];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
