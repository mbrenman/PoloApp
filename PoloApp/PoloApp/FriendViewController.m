//
//  FriendViewController.m
//  PoloApp
//
//  Created by Matt Brenman on 2/1/14.
//  Copyright (c) 2014 mbrenman. All rights reserved.
//

#import "FriendViewController.h"

@interface FriendViewController ()

@end

@implementation FriendViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    PFUser *me = [PFUser currentUser];
    if (!me[@"friends"]){
        me[@"friends"] = @[@"matt", @"julian"];
    }
    [me saveInBackground];
    NSLog(@"YYEAAAHHHHHHHHH");
	// Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    PFUser *me = [PFUser currentUser];
    NSMutableArray *friends = me[@"friends"];
    for (NSString *friend in friends){
        NSLog(friend);
    }
    NSLog(@"WOOOOOOOT");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
