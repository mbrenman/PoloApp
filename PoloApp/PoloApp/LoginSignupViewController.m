//
//  PoloViewController.m
//  PoloApp
//
//  Created by Matt Brenman on 2/1/14.
//  Copyright (c) 2014 mbrenman. All rights reserved.
//

#import "LoginSignupViewController.h"

@implementation PoloViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (![PFUser currentUser]) { // No user logged in
        // Create the log in view controller
        PFLogInViewController *logInViewController = [[PFLogInViewController alloc] init];
        [logInViewController setDelegate:self]; // Set ourselves as the delegate
        
        logInViewController.view.backgroundColor = [UIColor blackColor];
        logInViewController.logInView.usernameField.backgroundColor = [UIColor whiteColor];
        logInViewController.logInView.passwordField.backgroundColor = [UIColor whiteColor];
        logInViewController.logInView.usernameField.textColor = [UIColor blackColor];
        logInViewController.logInView.passwordField.textColor = [UIColor blackColor];
        
        CGRect bounds = logInViewController.logInView.logo.bounds;
        UILabel *label = [[UILabel alloc] initWithFrame: bounds];
        label.adjustsFontSizeToFitWidth = YES;
        label.textAlignment = UITextAlignmentCenter;
        [label setText:@"Polo"];
        [label setTextColor:[UIColor whiteColor]];
        label.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:35];
        [label setAdjustsFontSizeToFitWidth: YES];
        logInViewController.logInView.logo = label;
        
        logInViewController.fields = PFLogInFieldsUsernameAndPassword | PFLogInFieldsLogInButton | PFLogInFieldsSignUpButton | PFLogInFieldsPasswordForgotten;
        
        // Create the sign up view controller
        PFSignUpViewController *signUpViewController = [[PFSignUpViewController alloc] init];
        [signUpViewController setDelegate:self]; // Set ourselves as the delegate
        
        [signUpViewController setFields:PFSignUpFieldsDefault | PFSignUpFieldsAdditional];
        [[[signUpViewController signUpView] additionalField] setPlaceholder:@"Phone Number"];
        
        bounds = signUpViewController.signUpView.logo.bounds;
        label = [[UILabel alloc] initWithFrame: bounds];
        [label setText:@"Polo"];
        [label setTextColor:[UIColor orangeColor]];
        signUpViewController.signUpView.logo = label;
        
        signUpViewController.view.backgroundColor = [UIColor blackColor];
        signUpViewController.signUpView.usernameField.backgroundColor = [UIColor whiteColor];
        signUpViewController.signUpView.passwordField.backgroundColor = [UIColor whiteColor];
        signUpViewController.signUpView.usernameField.textColor = [UIColor blackColor];
        signUpViewController.signUpView.passwordField.textColor = [UIColor blackColor];
        
        signUpViewController.signUpView.emailField.backgroundColor = [UIColor whiteColor];
        signUpViewController.signUpView.emailField.textColor = [UIColor blackColor];
        signUpViewController.signUpView.additionalField.backgroundColor = [UIColor whiteColor];
        signUpViewController.signUpView.additionalField.textColor = [UIColor blackColor];
        
        // Assign our sign up controller to be displayed from the login controller
        [logInViewController setSignUpController:signUpViewController];

        
        // Present the log in view controller
        [self presentViewController:logInViewController animated:YES completion:NULL];
    } else {
        [self performSegueWithIdentifier:@"FriendsFromLogin" sender:nil];
    }
}

// Sent to the delegate to determine whether the log in request should be submitted to the server.
- (BOOL)logInViewController:(PFLogInViewController *)logInController shouldBeginLogInWithUsername:(NSString *)username password:(NSString *)password {
    // Check if both fields are completed
    if (username && password && username.length != 0 && password.length != 0) {
        return YES; // Begin login process
    }
    
    [[[UIAlertView alloc] initWithTitle:@"Missing Information"
                                message:@"Make sure you fill out all of the information!"
                               delegate:nil
                      cancelButtonTitle:@"ok"
                      otherButtonTitles:nil] show];
    return NO; // Interrupt login process
}

// Sent to the delegate when a PFUser is logged in.
- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

// Sent to the delegate when a PFUser is signed up.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
    //Go back to login screen
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
