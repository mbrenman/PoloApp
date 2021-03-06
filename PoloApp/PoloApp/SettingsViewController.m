//
//  SettingsViewController.m
//  PoloApp
//
//  Created by Matt Brenman on 5/20/14.
//  Copyright (c) 2014 mbrenman. All rights reserved.
//

#import "SettingsViewController.h"
#import "iAd/iAd.h"
#import "Parse/Parse.h"
#import "TTAlertView.h"

@interface SettingsViewController ()

@property (strong, nonatomic) IBOutlet UITextField *phoneNumberTextField;

@end

@implementation SettingsViewController

- (void)getUserSettings {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _unitsSwitch.on = [defaults boolForKey:@"units_preference"];
}

- (IBAction)pressedDeleteAccount:(id)sender {
    
     TTAlertView *deleteCheck = [[TTAlertView alloc]
                                   initWithTitle:@"Delete Account"
                                   message:@"Are you sure you want to delete your account?"
                                   delegate:self
                                   cancelButtonTitle:@"Cancel"
                                otherButtonTitles:@"Yes", nil];

        [deleteCheck show];
}

- (void)alertView:(TTAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        PFUser *me = [PFUser currentUser];

        NSArray *myLocations =me[@"myLocations"];
        for (PFObject *location in myLocations) {
            [location deleteInBackground];
        }
        
        [me saveInBackground];
        
        [me delete];
        [me saveInBackground];
        [self performSegueWithIdentifier:@"settingsToLogout" sender:nil];
    }
}

- (void)saveUserSettings
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:_unitsSwitch.on forKey:@"units_preference"];
}

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
    // Do any additional setup after loading the view.
    
    self.canDisplayBannerAds = YES;
    [self.unitsSwitch addTarget:self action:@selector(setState) forControlEvents:UIControlEventValueChanged];
    
    UIBarButtonItem *myButton = [[UIBarButtonItem alloc] init];
        myButton.action = @selector(logoutUser);
        myButton.title = @"Log Out";
        [myButton setTitleTextAttributes:@{
                                       NSForegroundColorAttributeName  : [UIColor lightTextColor]}
                            forState:normal];
    
    myButton.target = self;
    [self getPhoneNumber];

    self.navigationItem.leftBarButtonItem = myButton;
}

- (IBAction)updatePhoneNumber:(id)sender {
    PFUser *me = [PFUser currentUser];
    me[@"additional"] = self.phoneNumberTextField.text;
    [me saveInBackground];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([self.phoneNumberTextField isFirstResponder])
    {
        [self.phoneNumberTextField resignFirstResponder];
    }
    [super touchesBegan:touches withEvent:event];
}

- (void)logoutUser{
    [PFInstallation.currentInstallation removeObjectForKey:@"user"];
    [PFInstallation.currentInstallation saveEventually];
    
    [PFUser logOut];
    [self performSegueWithIdentifier:@"settingsToLogout" sender:nil];
}

- (void)setState{
    [self saveUserSettings];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self getUserSettings];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
//    [self.navigationController setToolbarHidden:NO animated:NO];
    [self.tabBarController.tabBar setHidden:NO];
}

-(void)getPhoneNumber{
    PFUser *me = [PFUser currentUser];
    
    self.phoneNumberTextField.text = me[@"additional"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



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
