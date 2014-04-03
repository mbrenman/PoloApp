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
@property (nonatomic, strong) UIAlertView *alertNonexistent;
@property (nonatomic, strong) UIAlertView *alertAlreadyAdded;
@property (nonatomic, strong) UIAlertView *alertSelfAdded;

@end

@implementation AddFriendViewController

//this lets hide keyboard when a touch is outside the text area
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([_friendNameField isFirstResponder])// && [touch view] != (_friendNameField))
    {
        [_friendNameField resignFirstResponder];
    }
    [super touchesBegan:touches withEvent:event];
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (IBAction)AddButtonClick:(id)sender {
    NSString *newFriend = [_friendNameField text];
    [self AddFriendIfExistsinDB:newFriend];
    NSLog(@"ADDBUTTONCLOCK");
}

- (void)AddFriendIfExistsinDB: (NSString *)newFriend
{
    //TODO: can we make this faster?
    NSLog(@"101010101011001010101");

    PFQuery *query= [PFUser query];
    [query whereKey:@"username" equalTo: newFriend];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (object != nil){
            [self addFriendToFriends:newFriend];
        } else {
            NSLog(@"NOPE Frand");
            [_alertNonexistent show];
        }
    }];
}
     
- (void)addFriendToFriends: (NSString *)newFriend
{
    PFUser *me = [PFUser currentUser];
    _friends = me[@"friends"];
    if (_friends == nil){
        me[@"f  riends"] = [[NSMutableArray alloc] init];
        _friends = me[@"friends"];
    }
    //Only add new friend if user does not already have the friend
    if (![_friends containsObject:newFriend]){
        if (![[me username] isEqualToString:newFriend]){
            [_friends addObject:newFriend];
            //create a friend request object
            NSMutableArray *myFriendRequests = me[@"myFriendRequests"];
            
            PFObject *friendRequest = [PFObject objectWithClassName:@"friendRequest"];
            friendRequest[@"requester"] = [me username];
            friendRequest[@"target"] = newFriend;
            friendRequest[@"accepted"] = [NSNumber numberWithBool:NO];
            
            if (myFriendRequests == nil) {
                me[@"myFriendRequests"] = [[NSMutableArray alloc] initWithObjects:friendRequest, nil];
            } else {
                [myFriendRequests addObject:newFriend];
                [me saveInBackground];
            }
            me[@"myFriendRequests"] = [[NSMutableArray alloc] init];
            [me saveInBackground];
        } else {self.navigationController.navigationBar.tintColor = [UIColor blackColor];
            [_alertSelfAdded show];
        }
    } else {
        [_alertAlreadyAdded show];
    }
    [self.navigationController popViewControllerAnimated:YES];
}
        
- (void)viewDidLoad
{
    [super viewDidLoad];
    //An alert for if the user tries to add a nonexistent friend
    _alertNonexistent = [[UIAlertView alloc]
        initWithTitle:@"Error"
        message:@"No such user exists"
        delegate:self
        cancelButtonTitle:@"Dismiss"
        otherButtonTitles:nil];
    
    //An alert for if the user tries to add a friend that they already have
    _alertAlreadyAdded = [[UIAlertView alloc]
                         initWithTitle:@"Error"
                         message:@"Already friends with selcted user"
                         delegate:self
                         cancelButtonTitle:@"Dismiss"
                         otherButtonTitles:nil];

    //An alert for is the user tries to add themselves
    _alertSelfAdded = [[UIAlertView alloc]
                          initWithTitle:@"Error"
                          message:@"Cannot add yourself"
                          delegate:self
                          cancelButtonTitle:@"Dismiss"
                          otherButtonTitles:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
