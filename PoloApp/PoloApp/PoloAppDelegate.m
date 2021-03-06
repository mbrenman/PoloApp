//
//  PoloAppDelegate.m
//  PoloApp
//
//  Created by Matt Brenman on 2/1/14.
//  Copyright (c) 2014 mbrenman. All rights reserved.
//

#import "PoloAppDelegate.h"
#import <Parse/Parse.h>
#import "PoloLocationManager.h"
#import "ArrowViewController.h"
#import "FriendListUINavigationViewController.h"
#import "FriendTableViewController.h"
#import "TTAlertView.h"
#import "PoloFriendManager.h"

@interface PoloAppDelegate()

@property (strong, nonatomic) PoloLocationManager *locationManager;
@property (strong, nonatomic) PoloFriendManager *friendManager;


@end

@implementation PoloAppDelegate

+(instancetype)delegate {
    return (PoloAppDelegate *)([UIApplication sharedApplication].delegate);
}

- (PoloLocationManager *)locationManager{
    if (!_locationManager) {
        _locationManager = [[PoloLocationManager alloc] init];
    }
    return _locationManager;
}

- (PoloFriendManager *)friendManager{
    if (!_friendManager) {
        _friendManager = [[PoloFriendManager alloc] init];
    }
    return _friendManager;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [Parse setApplicationId:@"3TMKj6bB7P5K6gGFz4mqCNDwKmQ39WUnYRgc2Y7N"
                  clientKey:@"M74KXveZwc6Y7nOauXRKmGwml38vRUOCo8Mmx3l4"];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    // Register for push notifications
    [application registerForRemoteNotificationTypes:
     UIRemoteNotificationTypeBadge |
     UIRemoteNotificationTypeAlert |
     UIRemoteNotificationTypeSound];

    return YES;
}

- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)newDeviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:newDeviceToken];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo {

    NSString *alert = [[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
    
    TTAlertView *connectRequest = [[TTAlertView alloc]
                                   initWithTitle:@"Friend!"
                                   message:alert
                                   delegate:self
                                   cancelButtonTitle:@"Dismiss"
                                   otherButtonTitles:@"Connect", nil];
    
    UITabBarController *tbc = [self tabBarController];
    
    //Don't show the popup if you are already on the arrow screen
    if ( ![(NSStringFromClass([[[[tbc selectedViewController] childViewControllers] lastObject] class])) isEqualToString: @"ArrowViewController"]){
        [connectRequest show];
    }
}

- (void)alertView:(TTAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        NSLog(@"Button 1 was selected.");
        UITabBarController *existingTabBarController = [self tabBarController];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ArrowViewController *newArrowVC = (ArrowViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ArrowViewController"];
        
        UIViewController *existingFriendTableVC = [[[existingTabBarController selectedViewController] childViewControllers] firstObject];
        
        //This should be not a literal. We should have a place where the pushing of notifications and here can see. Maybe app delegate property?
        NSString *target = [alertView.message stringByReplacingOccurrencesOfString:@" would like to connect with you" withString:@""];
        [newArrowVC setTargetUserName:target];
        
        [[existingFriendTableVC navigationController] pushViewController:newArrowVC animated:YES];
        
    } else if(buttonIndex == 0) {
        //dismissed connection request
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[NSNotificationCenter defaultCenter] postNotificationName:@"terminatingApp" object:nil];
}

@end
