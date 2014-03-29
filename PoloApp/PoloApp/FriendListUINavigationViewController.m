//
//  MyUINavigationViewController.m
//  PoloApp
//
//  Created by Susanne Heincke on 2/28/14.
//  Copyright (c) 2014 mbrenman. All rights reserved.
//

#import "FriendListUINavigationViewController.h"

@interface FriendListUINavigationViewController ()

@end

@implementation FriendListUINavigationViewController

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
    //enabled for now so I can see on add friend page, we need a better image for this
    //  [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"rect4445.png"] forBarMetrics:UIBarMetricsDefault];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
