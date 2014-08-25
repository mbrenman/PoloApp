//
//  PoloFriendManager.m
//  PoloApp
//
//  Created by Julian Locke on 8/24/14.
//  Copyright (c) 2014 mbrenman. All rights reserved.
//

#import "PoloFriendManager.h"

@implementation PoloFriendManager

- (void)getFriendsWithCompletionHandler: (void (^)(BOOL success, NSMutableArray* friends))completionBlock
{
    
}

- (void)getFriendRequestsWithCompletionHander: (void (^)(BOOL success, NSMutableArray* friends))completionBlock{
    
}

- (void)handleFriendRequestFrom: (NSString *)requester
                   WithResponse: (BOOL)isResponseYes
          WithCompletionHandler: (void (^)(BOOL success))completionBlock
{
    PFQuery *friendRequestQuery = [PFQuery queryWithClassName:@"friendRequest"];
    [friendRequestQuery whereKey:@"requester" equalTo:requester];

    [friendRequestQuery getFirstObjectInBackgroundWithBlock:^(PFObject *friendRequest, NSError *error) {
        if (!error) {
            if (isResponseYes) {
                
                [self addFriendWithName:requester withCompeltionHandler:^(BOOL success,NSString* alert){
                    NSLog(alert);
                }];

                friendRequest[@"accepted"] = [NSNumber numberWithBool:YES];
                [friendRequest saveInBackground];

                if (completionBlock) {
                    completionBlock(YES);
                }
            } else {
                [friendRequest saveInBackground];
                [friendRequest deleteInBackground];
                
                if (completionBlock) {
                    completionBlock(YES);
                }
            }
        }
    }];
}

- (void)addFriendWithName: (NSString *)name withCompeltionHandler: (void (^)(BOOL success, NSString* alertMessage))completionBlock{
    PFUser* me = [PFUser currentUser];
    NSMutableArray *friends = me[@"friends"];
    
    if (![friends containsObject:name]){
        if (![[me username] isEqualToString:name]){
            if ((!friends) || (friends.count == 0)) {
                friends = [[NSMutableArray alloc] init];
            }
            
            [friends addObject:name];
            
            me[@"friends"] = friends;
            
            [me saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    if (completionBlock) { completionBlock(YES, @"Success"); }
                }
            }];
            
        } else {
            if (completionBlock) { completionBlock(NO, @"Can't add yourself"); }
        }
    } else {
        if (completionBlock) { completionBlock(NO, @"Can't add an existing friend"); }
    }
}



@end
