//
//  AddFriendViewController.m
//  PoloApp
//
//  Created by Matt Brenman on 2/2/14.
//  Copyright (c) 2014 mbrenman. All rights reserved.
//

#import "AddFriendViewController.h"
#import <Parse/Parse.h>
#import "PoloAppDelegate.h"
#import "PoloFriendManager.h"
#import "TTAlertView.h"

@interface AddFriendViewController () <UITextFieldDelegate>
@property (nonatomic, strong) TTAlertView *alert;

@end

@implementation AddFriendViewController

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([_friendNameField isFirstResponder])
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

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)AddButtonClick:(id)sender {
    NSString *newFriend = [_friendNameField text];
    PoloFriendManager *friendManager = [PoloAppDelegate delegate].friendManager;
    
    [friendManager sendFriendRequestTo:newFriend
                 WithCompletionHandler:^(BOOL success, NSString *alertMessage) {
                     if (!success) {
                         [self.alert setMessage:alertMessage];
                         [self.alert show];
                     } else {
                         [self.navigationController popViewControllerAnimated:YES];
                     }
                 }];
    
    [self.friendNameField resignFirstResponder];
}


        
- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    [self.friendNameField setReturnKeyType:UIReturnKeyDefault];
    [self.friendNameField setDelegate:self];
    
    _alert = [[TTAlertView alloc]
        initWithTitle:@"Error"
        message:@""
        delegate:self
        cancelButtonTitle:@"Dismiss"
        otherButtonTitles:nil];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
