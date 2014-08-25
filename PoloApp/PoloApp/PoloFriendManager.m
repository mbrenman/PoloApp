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
                
                [self addFriendWithName:requester withCompeltionHandler:^(BOOL success){
                    if (success) {
                        NSLog(@"Success");
                    }
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

- (void)addFriendWithName: (NSString *)name withCompeltionHandler: (void (^)(BOOL success))completionBlock{
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
                    if (completionBlock) { completionBlock(YES); }
                }
            }];
            
        } else {
            if (completionBlock) { completionBlock(NO); }
        }
    } else {
        if (completionBlock) { completionBlock(NO); }
    }
}

- (void)sendFriendRequestTo: (NSString *)newFriend WithCompletionHandler:(void (^)(BOOL success, NSString *alertMessage))completionBlock {
    
    PFUser *me = [PFUser currentUser];
    NSMutableArray *friends = me[@"friends"];
    
    if (friends == nil){
        me[@"friends"] = [[NSMutableArray alloc] init];
        friends = me[@"friends"];
    }
    
    if ([friends containsObject:newFriend]){
        if (completionBlock) {
            completionBlock(NO, @"Already friends with selcted user");
        }
        return;
    }
    
    if (![[me username] isEqualToString:newFriend]){
        if (completionBlock) {
            completionBlock(NO, @"Cannot add yourself");
        }
        return;
    }
    
    PFQuery *query= [PFUser query];
    
    //check if other there is an existing request, if not, make and sent it
    [query whereKey:@"username" equalTo: newFriend];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (object != nil){
            
            __block NSMutableArray *existingFriendRequests;

            PFQuery* query = [PFQuery queryWithClassName:@"friendRequest"];
            
            [query whereKey:@"target" equalTo:newFriend];
            [query whereKey:@"requester" equalTo:me.username];
            
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                
                if (!error) {
                    NSLog(@"populating existingFriendRequests");
                    existingFriendRequests = (NSMutableArray*)objects;
                    
                    if (existingFriendRequests.count == 0){
                        NSLog(@"CREATING friend requestobject");

                        PFObject *friendRequest = [PFObject objectWithClassName:@"friendRequest"];
                        friendRequest[@"requester"] = [me username];
                        friendRequest[@"target"] = newFriend;
                        friendRequest[@"accepted"] = [NSNumber numberWithBool:NO];
                        [friendRequest saveInBackground];
                        
                        if (completionBlock) {
                            completionBlock(YES, nil);
                        }
                    } else {
                        if (completionBlock) {
                            completionBlock(NO, @"Friend request currently pending");
                        }
                    }
                } else {
                    //handle error
                }
            }];
            
        } else {
            if (completionBlock) {
                completionBlock(NO, @"There is no user with that name in our database, please double check your information");
            }
        }
    }];
}




@end
