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
//- (IBAction)AddFriendClick:(id)sender {
//    NSLog(@"So friends. Much wow");
//}
- (IBAction)AddButtonClick:(id)sender {

    
    NSString *newFriend = [_friendNameField text];
    [self AddFriendIfExistsinDB:newFriend];
}

- (void)AddFriendIfExistsinDB: (NSString *)newFriend
{
    //TODO: can we make this faster?
    
    PFQuery *query= [PFUser query];
    [query whereKey:@"username" equalTo: newFriend];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (object != nil){
            [self addFriendToFriends:newFriend];
        }
    }];
}
     
- (void)addFriendToFriends: (NSString *)newFriend
{
    PFUser *me = [PFUser currentUser];
    _friends = me[@"friends"];
    if (_friends == nil){
        NSLog(@"ha ha. no friends for you. geek.");
        me[@"friends"] = [[NSMutableArray alloc] initWithObjects:newFriend, nil];
    } else {
        //TODO: Check if friend exists as a user in the app
        
        //Only add new friend if user does not already have the friend
        if (![_friends containsObject:newFriend]){
            [_friends addObject:newFriend];
            NSLog(@"New Frand");
        }
    }
    
    [me saveInBackground];
    [self performSegueWithIdentifier:@"FriendAdded" sender:nil];
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
